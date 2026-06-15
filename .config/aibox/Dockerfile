# aibox — OCR (PaddleOCR) + translation (NLLB), CPU-only, models kept warm.
FROM python:3.11-slim

# System libs needed by paddle/opencv at runtime. --no-install-recommends keeps
# the image lean (no docs, no extra suggested packages).
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgl1 libglib2.0-0 libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# CPU-only torch + transformers + paddle. Versions pinned.
RUN pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu \
 && pip install --no-cache-dir transformers sentencepiece langdetect \
        paddlepaddle==3.0.0 paddleocr==3.6.0 \
        "numpy<2" opencv-python-headless pillow

# Model caches live on a named volume (see compose). They are downloaded once by
# the `fetch` service and reused across rebuilds, so editing the code never
# re-downloads the ~11 GB of models.
ENV HF_HOME=/models/hf \
    PADDLE_PDX_CACHE_HOME=/models/paddlex \
    OMP_NUM_THREADS=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY app/cli.py app/worker.py app/download.py /app/

# CMD (not ENTRYPOINT): compose `command:` fully REPLACES it, so the fetch
# service can run download.py without argument duplication.
CMD ["python3", "/app/worker.py"]
