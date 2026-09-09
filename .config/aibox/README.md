# aibox

A single always-on [Podman](https://podman.io/) container that provides **OCR**
(PaddleOCR) and **machine translation** (NLLB-200) on the CPU. The models are
loaded once at startup and kept resident in memory, so requests are answered
warm (no per-call load time). You talk to the container over `podman exec` and
stdin.

- **OCR** — reads mixed Cyrillic + Latin + digits in one pass; optional
  per-language mode for maximum quality.
- **Translation** — automatic source-language detection, configurable target,
  and an automatic dictionary mode for short input (one or two words).
- **CPU-only**, no GPU required.
- **Offline at runtime** — the models are downloaded once into a Podman volume
  by a separate one-shot container (`aibox-download`), and the running service
  has no network access at all. Rebuilding the image never re-downloads the
  models, and editing the code triggers a rebuild only when it really changed.

## Requirements

- Linux host with [Podman](https://podman.io/) (on Arch Linux: `pacman -S podman`).
  Rootless use is the default and needs no extra setup or privileges.
- ~6–7 GB RAM free (PaddleOCR ≈ 1–1.5 GB, NLLB-1.3B ≈ 5 GB).
- ~11 GB disk space for the model volume.

## Repository layout

| File               | Purpose                                                            |
| ------------------ | ------------------------------------------------------------------ |
| `Containerfile`    | Image recipe (CPU-only torch, PaddleOCR, NLLB, pinned versions).   |
| `aibox.sh`         | Deployment helper: build, model fetch, service lifecycle (below).  |
| `config.py`        | All user-facing settings; mounted into the container read-only.    |
| `app/worker.py`    | The long-running worker: keeps the models warm, answers requests.  |
| `app/cli.py`       | The client executed via `podman exec`; reads stdin, prints results.|
| `app/download.py`  | One-shot model downloader used by the fetch step.                  |
| `pyproject.toml`   | Linter/type-checker configuration (ruff, ty).                      |

## Install

1. Build the image, fetch the models, and start the service:

   ```bash
   ./aibox.sh up
   ```

   On first run this builds the image, then runs the `aibox-download`
   one-shot container, which downloads the models declared in `config.py`
   into the `aibox_models` volume (the only step that uses the network) and
   exits; then the `aibox` container starts offline and loads the models into
   memory. On every later run the script checks the state first: the image is
   rebuilt only when the sources baked into it changed, the downloader is not
   even started when the volume already holds the models (≥ `FETCH_MIN_GB`),
   and an already-running service is left alone. Watch the service become
   ready:

   ```bash
   ./aibox.sh logs    # wait for "warm-up done; ready for warm requests"
   ```

2. Add a shell alias:

   ```bash
   alias aibox='podman exec -i aibox aibox /app/cli.py'
   ```

The service process shows up as `aibox`  in `ps`, `top` and `podman ps`.

## Usage

All input is read from stdin.

### OCR

```bash
cat image.png | aibox ocr                # default: ruen (Cyrillic + Latin + digits)
cat image.png | aibox ocr --lang en      # force one script for best quality
```

`--lang` accepts these engine names: `ruen` (default; the East-Slavic
recognizer, reads Cyrillic + Latin + digits), `en` (Latin only — best for pure
English/code), `ch`, `japan`, `korean`, `latin`, `fr`, `german`, `es`. Note:
PaddleOCR has no Cyrillic-only model — `ruen` is the engine for Russian text,
and `--lang en` will not read Cyrillic. Engines are loaded lazily on first use
and stay warm.

Only `ruen` is downloaded by default. To use another engine, add it to
`PADDLE.download_langs` in `config.py` and refresh the volume (see
"Updating the models").

> If `cat` is aliased to `bat`/`batcat` it will corrupt binary data in a pipe.
> Use the real one: `command cat image.png | aibox ocr` or `/bin/cat image.png | aibox ocr`.

### Translation

```bash
echo "Hello world"  | aibox tr                 # source auto-detected -> Russian
echo "Привет мир"   | aibox tr                 # Russian -> English
echo "Hola mundo"   | aibox tr                 # Spanish -> Russian
echo "你好世界"     | aibox tr                 # Chinese -> Russian
echo "Bonjour"      | aibox tr --tgt eng_Latn  # force target
echo "text"         | aibox tr --src rus_Cyrl --tgt deu_Latn   # force both
```

Source detection: Cyrillic text is recognized by its characters (reliable even
on one or two words); other languages are detected with `langdetect`. The
default target is chosen from the detected source via `NLLB.default_targets`
(out of the box: Russian→English, English→Russian) with `NLLB.default_target`
as the fallback (Russian). Languages are forced with FLORES-200 codes via
`--src` / `--tgt`.

#### Dictionary mode

When the input is short — **one or two words on a single line** — several
comma-separated translations are returned automatically, like a dictionary
entry:

```bash
echo "light"  | aibox tr            # -> свет, освещение, лёгкий, ...
echo "dock"  | aibox tr            # -> Док, Пристань, Дока
echo "light" | aibox tr --variants 3   # limit the number of variants
echo "light" | aibox tr --no-dict      # disable, translate as a normal phrase
```

Beam search often returns the same translation several times with different
punctuation (`Здравствуйте!` / `Здравствуйте.` / `- Здравствуйте!`) or as a
repeated word — these are duplicates of one translation and get merged, so
genuinely different senses survive in the list.

Input of three or more words, or text with line breaks, is always translated
normally.

### Status

```bash
aibox ping
```

## Managing the service

| Command                     | Effect                                                  |
| --------------------------- | -------------------------------------------------------- |
| `./aibox.sh up`             | Make sure the service runs: build and download only when something is missing. |
| `./aibox.sh restart`        | Restart `aibox` (applies `config.py` changes; models re-warm). |
| `./aibox.sh logs`           | Follow the service logs.                                |
| `./aibox.sh fetch`          | Re-run the model downloader once (skips when cached).   |
| `./aibox.sh refresh-models` | Delete the model volume and re-download everything.     |
| `./aibox.sh down`           | Stop and remove the `aibox` container (volume is kept). |
| `./aibox.sh purge`          | Remove the containers **and** the model volume (full cleanup). |

`purge` removes the `aibox` and `aibox-download` containers plus the
`aibox_models` volume with all downloaded models. The volume is only deleted
when no other container still uses it. The image is kept — remove it manually
with `podman rmi aibox:cpu` when desired.

## Configuration

Settings live in `config.py` next to `aibox.sh`, mounted into the container
read-only. The file can be moved elsewhere — just update the bind path in
`aibox.sh`. Edit it and apply with:

```bash
./aibox.sh restart
```

| Key                                       | Meaning                                                                  |
| ----------------------------------------- | ------------------------------------------------------------------------ |
| `FETCH_MIN_GB`                            | skip the download if the cache already holds at least this many GB       |
| `PRELOAD`                                 | which models to warm up at startup: `paddle`, `nllb`                     |
| `PADDLE.lang`                             | default OCR engine (`ruen` = Cyrillic + Latin + digits)                  |
| `PADDLE.lang_map`                         | friendly engine name → PaddleOCR code                                    |
| `PADDLE.download_langs`                   | which OCR engines to download _(refresh volume)_                         |
| `PADDLE.upscale`                          | upscale factor before OCR; main accuracy lever                           |
| `PADDLE.max_side`                         | cap on image size after upscaling (keeps big pages fast)                 |
| `PADDLE.cpu_threads`                      | CPU threads for OCR                                                      |
| `NLLB.model`                              | translation model _(refresh volume)_ (default `nllb-200-distilled-1.3B`) |
| `NLLB.default_targets` / `default_target` | default target per source / fallback                                     |
| `NLLB.num_beams`                          | 1 = faster, 5 = better quality                                           |
| `NLLB.langdetect_map`                     | langdetect code → FLORES code (add languages here)                       |
| `NLLB.dict_auto` / `dict_variants`        | auto dictionary mode for short input / number of variants               |
| `NLLB.dict_max_words`                     | how many input words count as "short" (default 2: one or two words)     |

Keys marked _(refresh volume)_ change which models are downloaded, so they take
effect only after refreshing the volume (see below). Application code
(`app/cli.py`, `app/worker.py`) is baked into the image; `./aibox.sh up`
rebuilds the image automatically whenever those files (or the `Containerfile`)
change, and skips the rebuild when they do not.

### OCR accuracy note

On small text, OCR engines confuse Cyrillic/Latin homoglyphs (e.g. Cyrillic `о`
vs Latin `o`), because the glyphs are nearly identical pixel-wise. Upscaling the
image (`PADDLE.upscale`) before recognition gives the engine enough detail to
tell them apart and largely removes the mixing. Binarization and sharpening
make results worse, so only plain resizing is used. Large screenshots are
capped at `PADDLE.max_side` so they are not over-upscaled (which would slow
the detector down and cause it to miss parts of the page).

## Updating the models

Models live in the `aibox_models` volume. Both the script and the downloader
itself skip downloading whenever the cache already holds at least
`FETCH_MIN_GB`, so to refresh or add models:

```bash
./aibox.sh refresh-models    # deletes the volume and re-downloads everything
```

(Alternatively, lower `FETCH_MIN_GB` below the current cache size and run
`./aibox.sh fetch` to force the full download again.)

## Security / isolation

The serving container is locked down: no network (`--network none`),
read-only root filesystem, all Linux capabilities dropped, `no-new-privileges`,
and a small `tmpfs` for scratch space. It needs only CPU, RAM, and the two
mounts (read-only model cache and read-only config). The model downloader is
the only part that uses the network, and only while downloading models — it is
a separate one-shot container (`aibox-download`) that exits when done. The
in-container Unix socket that carries the requests is reachable only by
processes running as the container's own user (i.e. `podman exec`).

## Development

The Python code runs on Python 3.11 (the container image interpreter — the
pinned PaddleOCR stack has no builds for newer CPythons), and is checked with
[ruff](https://docs.astral.sh/ruff/) (lint + format) and
[ty](https://docs.astral.sh/ty/) (type checker); both are configured in
`pyproject.toml` with that version pinned as the target:

```bash
uvx ruff check app config.py && uvx ruff format --check app config.py
uvx ty check app config.py
```
