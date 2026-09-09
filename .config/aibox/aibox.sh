#!/usr/bin/env bash
#
# aibox — deployment helper (plain podman, no compose).
#
# Usage:
#   ./aibox.sh up               start the service (build and download only if needed)
#   ./aibox.sh restart          restart the service (applies config.py changes)
#   ./aibox.sh logs             follow the service logs (warm-up progress)
#   ./aibox.sh fetch            re-run the one-shot model downloader
#   ./aibox.sh refresh-models   wipe the model volume and re-download
#   ./aibox.sh down             stop and remove the service container
#   ./aibox.sh purge            remove the containers and the model volume
#
# `up` is idempotent and, once everything is installed, fully offline and
# near-instant: the image is only rebuilt when the sources baked into it
# (Containerfile + app/*.py) changed, and the model downloader is not even
# started when the model volume already holds the models.
#
# The service container is fully locked down (no network, read-only root
# filesystem, all capabilities dropped); the only step with network access is
# the model downloader — a one-shot container named aibox-download. Works
# rootless (recommended) and rootful.
#
set -euo pipefail

IMAGE="aibox:cpu"
CONTAINER="aibox"
FETCH_CONTAINER="aibox-download"
VOLUME="aibox_models"
# Image label in which the build records a hash of the baked sources; used to
# skip rebuilds when nothing changed.
CTX_LABEL="io.aibox.ctx"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${HERE}/config.py"

die() {
	echo "aibox: error: $*" >&2
	exit 1
}
log() { echo "aibox: $*"; }

[ -f "$CONFIG" ] || die "config.py not found in ${HERE}"
[ -f "${HERE}/Containerfile" ] || die "Containerfile not found in ${HERE}"
for f in app/worker.py app/cli.py app/download.py; do
	[ -f "${HERE}/${f}" ] || die "${f} not found in ${HERE}"
done
command -v podman >/dev/null 2>&1 || die "podman not found in PATH"

# ------------------------------- image --------------------------------------
# Rebuild only when the sources baked into the image changed. The hash of
# Containerfile + app/*.py is stored as an image label, so an unchanged image
# is never rebuilt — repeated `up` runs do not even touch the registry.
ctx_hash() {
	cat "${HERE}/Containerfile" "${HERE}"/app/*.py | sha256sum | cut -d' ' -f1
}

ensure_image() {
	local want have
	want="$(ctx_hash)"
	have="$(podman image inspect -f "{{index .Labels \"${CTX_LABEL}\"}}" "$IMAGE" 2>/dev/null || true)"
	if podman image exists "$IMAGE" 2>/dev/null && [ "$have" = "$want" ]; then
		log "image ${IMAGE} is up to date; skipping the build"
		return
	fi
	log "building image ${IMAGE} ..."
	podman build --label "${CTX_LABEL}=${want}" -t "$IMAGE" "$HERE"
}

# ------------------------------- models -------------------------------------
# The cache-size check runs on the host, so the downloader container is not
# started at all when the models are already cached. It mirrors the threshold
# check inside download.py (FETCH_MIN_GB in config.py).
fetch_min_gb() {
	local v
	v="$(sed -nE 's/^[[:space:]]*FETCH_MIN_GB[[:space:]]*:.*=[[:space:]]*([0-9]+([.][0-9]+)?).*/\1/p' \
		"$CONFIG" | head -n1)"
	printf '%s' "${v:-10}"
}

volume_gb() {
	local mp mb
	mp="$(podman volume inspect -f '{{.Mountpoint}}' "$VOLUME" 2>/dev/null)" || return 0
	[ -d "$mp" ] || return 0
	mb="$(du -sm --apparent-size "$mp" 2>/dev/null | cut -f1)" || return 0
	[ -n "$mb" ] || return 0
	awk -v m="$mb" 'BEGIN { printf "%.3f", m / 1024 }'
}

models_present() {
	awk -v a="$(volume_gb)" -v b="$(fetch_min_gb)" 'BEGIN { exit !(a + 0 >= b + 0) }'
}

ensure_volume() {
	podman volume exists "$VOLUME" 2>/dev/null || podman volume create "$VOLUME" >/dev/null
}

# Remove a leftover downloader container (normally --rm cleans it up itself;
# a crashed run can leave one behind holding the volume). Force-removal is
# fine here: the callers are explicit cleanup intents.
rm_fetch_container() {
	if podman container exists "$FETCH_CONTAINER" 2>/dev/null; then
		podman rm -f "$FETCH_CONTAINER" >/dev/null 2>&1 || true
	fi
}

# The ONLY step with network access: downloads the models declared in
# config.py into the $VOLUME volume, then exits (download.py hard-exits when
# done). Named aibox-download so it is identifiable while it runs; --rm makes
# it disappear after it finishes.
run_fetch() {
	if podman container exists "$FETCH_CONTAINER" 2>/dev/null; then
		if [ "$(podman container inspect -f '{{.State.Running}}' "$FETCH_CONTAINER" 2>/dev/null)" = "true" ]; then
			die "${FETCH_CONTAINER} is already running (a download in progress?); \
to force-remove it: podman rm -f ${FETCH_CONTAINER}"
		fi
		podman rm "$FETCH_CONTAINER" >/dev/null 2>&1
	fi
	podman run --rm \
		--name "$FETCH_CONTAINER" \
		-v "${VOLUME}":/models \
		-v "${CONFIG}":/app/config.py:ro \
		"$IMAGE" \
		aibox /app/download.py
}

# The long-running service: offline, read-only rootfs, dropped capabilities.
run_service() {
	podman run -d \
		--name "$CONTAINER" \
		--restart unless-stopped \
		--network none \
		--read-only \
		--tmpfs /tmp \
		--cap-drop ALL \
		--cap-add DAC_OVERRIDE \
		--security-opt no-new-privileges \
		--stop-timeout 5 \
		-e OMP_NUM_THREADS=1 \
		-e HF_HUB_OFFLINE=1 \
		-e TRANSFORMERS_OFFLINE=1 \
		-e HOME=/tmp \
		-e XDG_CACHE_HOME=/tmp \
		-e PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK=True \
		-v "${VOLUME}":/models:ro \
		-v "${CONFIG}":/app/config.py:ro \
		"$IMAGE"
}

container_running() {
	[ "$(podman container inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)" = "true" ]
}

# ------------------------------ commands ------------------------------------
cmd_up() {
	ensure_image
	ensure_volume
	if models_present; then
		log "models already cached; skipping the downloader"
	else
		log "fetching models (one-time, ~11 GB; the only networked step) ..."
		run_fetch
	fi
	if podman container exists "$CONTAINER"; then
		if container_running; then
			log "${CONTAINER} is already running; to apply config.py changes use: $0 restart"
		else
			log "starting existing container ${CONTAINER} ..."
			podman start "$CONTAINER"
		fi
	else
		run_service >/dev/null
		log "started ${CONTAINER}"
	fi
	log "watch the warm-up with: $0 logs   (ready when you see 'warm-up done')"
}

cmd_down() {
	podman container exists "$CONTAINER" || die "container ${CONTAINER} does not exist"
	podman stop "$CONTAINER"
	podman rm "$CONTAINER"
	log "stopped and removed ${CONTAINER} (model volume ${VOLUME} is kept)"
}

cmd_restart() {
	podman container exists "$CONTAINER" || die "container ${CONTAINER} does not exist"
	podman restart "$CONTAINER"
	log "restarted ${CONTAINER} (config.py changes applied; models re-warm)"
}

cmd_logs() {
	podman logs -f "$CONTAINER"
}

cmd_fetch() {
	ensure_image
	ensure_volume
	run_fetch
}

cmd_refresh_models() {
	if podman container exists "$CONTAINER"; then
		cmd_down
	fi
	rm_fetch_container # a crashed download can leave one holding the volume
	if podman volume exists "$VOLUME" 2>/dev/null; then
		podman volume rm "$VOLUME" >/dev/null
		log "removed volume ${VOLUME}"
	fi
	cmd_up
}

# Full cleanup: the service and downloader containers plus the downloaded
# models. The volume is only removed when no other container still uses it.
# The image is kept — remove it manually with `podman rmi ${IMAGE}`.
cmd_purge() {
	if podman container exists "$CONTAINER" 2>/dev/null; then
		podman rm -f "$CONTAINER" >/dev/null
		log "removed container ${CONTAINER}"
	else
		log "container ${CONTAINER} not present"
	fi
	if podman container exists "$FETCH_CONTAINER" 2>/dev/null; then
		podman rm -f "$FETCH_CONTAINER" >/dev/null
		log "removed container ${FETCH_CONTAINER}"
	else
		log "container ${FETCH_CONTAINER} not present"
	fi
	if ! podman volume exists "$VOLUME" 2>/dev/null; then
		log "volume ${VOLUME} not present; nothing left to remove"
		return
	fi
	local users
	users="$(podman ps -a --filter volume="${VOLUME}" --format '{{.Names}}' | tr '\n' ' ')"
	if [ -n "${users// /}" ]; then
		die "volume ${VOLUME} is still used by:${users}— remove those containers first"
	fi
	podman volume rm "$VOLUME" >/dev/null
	log "removed model volume ${VOLUME} (the downloaded models)"
	log "image ${IMAGE} kept; remove it with: podman rmi ${IMAGE}"
}

case "${1:-}" in
	up | start) cmd_up ;;
	down | stop) cmd_down ;;
	restart) cmd_restart ;;
	logs) cmd_logs ;;
	fetch) cmd_fetch ;;
	refresh-models) cmd_refresh_models ;;
	purge) cmd_purge ;;
	*)
		echo "usage: $0 {up|down|restart|logs|fetch|refresh-models|purge}" >&2
		exit 1
		;;
esac
