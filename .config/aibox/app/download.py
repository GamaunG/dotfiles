#!/usr/bin/env python3
"""
Model downloader for the fetch step (aibox.sh). Downloads exactly the models
declared in config.py into the model volume:
  - PaddleOCR engines for every language in PADDLE["download_langs"]
  - the NLLB translation model in NLLB["model"]

Fast path: if the model cache already holds at least FETCH_MIN_GB of data, the
models are assumed present and the script exits immediately (no loading into
memory). To force a re-download:  ./aibox.sh refresh-models
"""

import os
import sys
from contextlib import suppress

sys.path.insert(0, "/app")
import config as C  # must come after the sys.path tweak above

MODELS_DIR = "/models"


def dir_size_gb(path: str) -> float:
    total = 0
    for root, _, files in os.walk(path):
        for f in files:
            fp = os.path.join(root, f)
            with suppress(OSError):
                total += os.path.getsize(fp)
    return total / (1024**3)


def main() -> None:
    min_gb = float(getattr(C, "FETCH_MIN_GB", 10))
    size = dir_size_gb(MODELS_DIR)
    if size >= min_gb:
        print(
            f"[download] cache has {size:.1f} GB (>= {min_gb} GB) — already present, skipping",
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
    done: set[str] = set()
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
    from transformers import AutoModelForSeq2SeqLM, AutoTokenizer

    mid = C.NLLB["model"]
    print(f"[download] NLLB {mid}", flush=True)
    AutoTokenizer.from_pretrained(mid)
    AutoModelForSeq2SeqLM.from_pretrained(mid)

    print("[download] done", flush=True)


if __name__ == "__main__":
    main()
    # Hard exit: after the downloads PaddleX leaves lingering non-daemon
    # threads, which can keep the interpreter (and with it the fetch container)
    # alive after the work is done. os._exit terminates immediately; every
    # message above is printed with flush=True, so nothing is lost.
    os._exit(0)
