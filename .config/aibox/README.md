# aibox

A single always-on Docker container that provides **OCR** (PaddleOCR) and
**machine translation** (NLLB-200) on the CPU. Models are loaded once at startup
and kept resident in memory, so requests are answered warm (no per-call load
time). You talk to it over `docker exec` and stdin.

- **OCR** — reads mixed Cyrillic + Latin + digits in one pass; optional
  per-language mode for maximum quality.
- **Translation** — automatic source-language detection, configurable target,
  and an automatic single-word dictionary mode.
- **CPU-only**, no GPU required.
- **Offline at runtime** — models are downloaded once into a Docker volume by a
  separate step, and the running container has no network access. Rebuilding the
  image (to edit the code) never re-downloads the models.

## Requirements

- Docker with Compose v2.
- ~6–7 GB RAM free (PaddleOCR ≈ 1–1.5 GB, NLLB-1.3B ≈ 5 GB).
- ~11 GB disk space.

## Install

1. Build the image and start the service:

   ```bash
   docker compose up -d --build
   ```

   On first run the `fetch` service downloads the models declared in `config.py`
   into the `aibox_models` volume (the only step that uses the network) and exits.
   Then `aibox` starts offline and loads them into memory. On later runs `fetch`
   sees the volume already holds the models (≥ `FETCH_MIN_GB`) and exits instantly
   without loading anything. Watch it become ready:

   ```bash
   docker compose logs -f aibox      # wait for "warm-up done; ready for warm requests"
   ```

2. Add a shell alias:

   ```bash
   alias ai='docker exec -i aibox python3 /app/cli.py'
   ```

## Usage

All input is read from stdin.

### OCR

```bash
cat image.png | ai ocr                # default: ruen (Cyrillic + Latin + digits)
cat image.png | ai ocr --lang en      # force one script for best quality
```

`--lang` accepts these engine names: `ruen` (default; the East-Slavic recognizer,
reads Cyrillic + Latin + digits), `en` (Latin only — best for pure English/code),
`ch`, `japan`, `korean`, `latin`, `fr`, `german`, `es`. Note: PaddleOCR has no
Cyrillic-only model — `ruen` is the engine for Russian text, and `--lang en` will
not read Cyrillic. Engines are loaded lazily on first use and stay warm.

Only `ruen` is downloaded by default. To use another engine, add it to
`PADDLE.download_langs` in `config.py` and refresh the volume (see
"Updating the models").

> If `cat` is aliased to `bat`/`batcat` it will corrupt binary data in a pipe.
> Use the real one: `command cat image.png | ai ocr` or `/bin/cat image.png | ai ocr`.

### Translation

```bash
echo "Hello world"  | ai tr                 # source auto-detected -> Russian
echo "Привет мир"   | ai tr                 # Russian -> English
echo "Hola mundo"   | ai tr                 # Spanish -> Russian
echo "你好世界"     | ai tr                 # Chinese -> Russian
echo "Bonjour"      | ai tr --tgt eng_Latn  # force target
echo "text"         | ai tr --src rus_Cyrl --tgt deu_Latn   # force both
```

Source detection: Cyrillic text is recognized by its characters (reliable even
on one or two words); other languages are detected with `langdetect`. The default
target is chosen from the detected source via `NLLB.default_targets` (out of the
box: Russian→English, English→Russian) with `NLLB.default_target` as the fallback
(Russian). Languages are forced with FLORES-200 codes via `--src` / `--tgt`.

#### Dictionary mode

When the input is a **single word**, several comma-separated translations are
returned automatically:

```bash
echo "light" | ai tr            # -> свет, освещение, лёгкий, ...
echo "light" | ai tr --variants 3   # limit the number of variants
echo "light" | ai tr --no-dict      # disable, translate as a normal phrase
```

Multi-word input is always translated normally.

### Status

```bash
ai ping
```

## Configuration

Settings live in `config.py` next to `compose.yaml`, mounted into the container
read-only. The file can be moved elsewhere — just update the bind path in
`compose.yaml`. Edit it and apply with:

```bash
docker compose restart aibox
```

| Key                                       | Meaning                                                                  |
| ----------------------------------------- | ------------------------------------------------------------------------ |
| `FETCH_MIN_GB`                            | skip the download if the cache already holds at least this many GB       |
| `PRELOAD`                                 | which models to warm up at startup: `paddle`, `nllb`                     |
| `PADDLE.lang`                             | default OCR engine (`ruen` = Cyrillic + Latin + digits)                  |
| `PADDLE.lang_map`                         | friendly engine name → PaddleOCR code                                    |
| `PADDLE.download_langs`                   | which OCR engines to download _(refresh volume)_                         |
| `PADDLE.upscale`                          | upscale factor before OCR; main accuracy lever (default 2.0)             |
| `PADDLE.max_side`                         | cap on image size after upscaling (keeps big pages fast)                 |
| `PADDLE.cpu_threads`                      | CPU threads for OCR                                                      |
| `NLLB.model`                              | translation model _(refresh volume)_ (default `nllb-200-distilled-1.3B`) |
| `NLLB.default_targets` / `default_target` | default target per source / fallback                                     |
| `NLLB.num_beams`                          | 1 = faster, 5 = better quality                                           |
| `NLLB.langdetect_map`                     | langdetect code → FLORES code (add languages here)                       |
| `NLLB.dict_auto` / `dict_variants`        | auto single-word dictionary / number of variants                         |

Keys marked _(refresh volume)_ change which models are downloaded, so they take
effect only after refreshing the volume (see "Updating the models"). Application code
(`cli.py`, `worker.py`) is baked
into the image and likewise requires a rebuild to change.

### OCR accuracy note

On small text, OCR engines confuse Cyrillic/Latin homoglyphs (e.g. Cyrillic `о`
vs Latin `o`), because the glyphs are nearly identical pixel-wise. Upscaling the
image (`PADDLE.upscale`) before recognition gives the engine enough detail to
tell them apart and largely removes the mixing. Binarization and sharpening were
tested and make results worse, so only plain resizing is used. Large screenshots
are capped at `PADDLE.max_side` so they are not over-upscaled (which would slow
the detector down and cause it to miss parts of the page).

## Updating the models

Models live in the `aibox_models` volume. `fetch` skips downloading whenever the
cache already holds at least `FETCH_MIN_GB`, so to refresh or add models, delete
the volume and let it re-download:

```bash
docker compose down
docker volume rm aibox_models
docker compose up -d              # fetch re-downloads everything in config.py
```

(Alternatively, lower `FETCH_MIN_GB` below the current cache size to force the
next `fetch` to run the full download again.)

## Security / isolation

The serving container is locked down: no network (`network_mode: none`),
read-only root filesystem, all Linux capabilities dropped, `no-new-privileges`,
and a small `tmpfs` for scratch space. It needs only CPU, RAM, and the two
volumes (read-only model cache and read-only config). The `fetch` step is the
only part that uses the network, and only while downloading models.
