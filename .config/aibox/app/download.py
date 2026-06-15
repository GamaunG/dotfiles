#!/usr/bin/env python3
"""
Model downloader for the `fetch` service. Downloads exactly the models declared
in config.py into the model volume:
  - PaddleOCR engines for every language in PADDLE["download_langs"]
  - the NLLB translation model in NLLB["model"]

Fast path: if the model cache already holds at least FETCH_MIN_GB of data, the
models are assumed present and the script exits immediately (no loading into
memory). To force a re-download, delete the volume:  docker volume rm aibox_models
"""

import os
import sys

sys.path.insert(0, "/app")
import config as C

MODELS_DIR = "/models"


def dir_size_gb(path):
    total = 0
    for root, _, files in os.walk(path):
        for f in files:
            fp = os.path.join(root, f)
            try:
                total += os.path.getsize(fp)
            except OSError:
                pass
    return total / (1024**3)


def main():
    min_gb = float(getattr(C, "FETCH_MIN_GB", 10))
    size = dir_size_gb(MODELS_DIR)
    if size >= min_gb:
        print(
            f"[download] cache has {size:.1f} GB (>= {min_gb} GB) — already "
            f"present, skipping",
            flush=True,
        )
        return
    print(
        f"[download] cache has {size:.1f} GB (< {min_gb} GB) — downloading ...",
        flush=True,
    )

    # --- PaddleOCR ---
    from paddleocr import PaddleOCR

    lang_map = C.PADDLE.get("lang_map", {})
    langs = C.PADDLE.get("download_langs") or [C.PADDLE["lang"]]
    done = set()
    for name in langs:
        code = lang_map.get(name, name)
        if code in done:
            continue
        done.add(code)
        print(f"[download] PaddleOCR '{name}' -> lang={code}", flush=True)
        PaddleOCR(
            lang=code,
            device="cpu",
            use_textline_orientation=C.PADDLE["use_textline_orientation"],
            use_doc_orientation_classify=False,
            use_doc_unwarping=False,
        )

    # --- NLLB ---
    from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

    mid = C.NLLB["model"]
    print(f"[download] NLLB {mid}", flush=True)
    AutoTokenizer.from_pretrained(mid)
    AutoModelForSeq2SeqLM.from_pretrained(mid)

    print("[download] done", flush=True)


if __name__ == "__main__":
    main()
