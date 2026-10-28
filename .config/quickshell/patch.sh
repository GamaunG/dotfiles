#!/bin/bash

TARGET_DIR="$HOME/.config/quickshell/dms"
PATCHES_DIR="$HOME/.config/quickshell/dmspatches"
SRC_QML="$HOME/.config/quickshell/dms-qml.tar.gz"
# DMS_QML="$HOME/.config/quickshell/dms-qml"


[[ ! -d "$PATCHES_DIR" ]] && echo "Error: $PATCHES_DIR not found." >&2 && exit 1
[[ ! -f "$SRC_QML" ]] && echo "Error: $SRC_QML not found. Download it from https://github.com/duxlabs-dev/dux-shell/releases" >&2 && exit 1

rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"

tar -xzf "$SRC_QML" -C "$TARGET_DIR"

for patchFile in "$PATCHES_DIR"/*.patch; do
	patch -d "$TARGET_DIR" -p1 --no-backup-if-mismatch < "$patchFile"
done
