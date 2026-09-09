#!/usr/bin/env python3
"""
Background worker: loads the models once and keeps them warm.
Listens on a Unix socket (/tmp/aibox.sock) and answers JSON requests.
Started automatically inside the container (image CMD). The client is cli.py.

The models are downloaded ahead of time into the model volume by download.py
(the fetch step in aibox.sh), so nothing is fetched at runtime — the serving
container runs fully offline.
"""

import base64
import json
import os
import queue
import re
import socket
import sys
import tempfile
import threading
import time
import traceback
from collections.abc import Sequence
from contextlib import suppress
from typing import Any, Protocol

sys.path.insert(0, "/app")
import config as C  # must come after the sys.path tweak above

SOCK = "/tmp/aibox.sock"

# The heavy ML libraries (paddleocr, torch, transformers) are untyped and
# imported lazily, so the objects they hand out are described by minimal
# structural types covering exactly the members the worker uses.


class _OcrEngine(Protocol):
    """A PaddleOCR instance."""

    def predict(self, img: str) -> Sequence[object]: ...


class _Tokenizer(Protocol):
    """An NLLB tokenizer."""

    unk_token_id: int | None

    def convert_tokens_to_ids(self, token: str) -> int | None: ...


# (tokenizer, model) once loaded; all tokenizer/model state is guarded by
# _nllb_lock (the tokenizer carries per-request state such as `src_lang`).
_nllb: tuple[Any, Any] | None = None
_nllb_lock = threading.Lock()

# PaddleOCR is NOT thread-safe (its predictor is bound to the thread that
# created it; calling from another thread -> std::exception). So all Paddle
# work lives in ONE owner thread, fed through a queue.
_paddle: dict[str, Any] = {}
# (lang, img_path, result_queue)
_paddle_jobs: queue.Queue[tuple[str, str, queue.Queue[tuple[str, str]]]] = queue.Queue()


def log(*a: object) -> None:
    print("[worker]", *a, file=sys.stderr, flush=True)


# ------------------------------ PaddleOCR ---------------------------------
def _resolve_lang(name: str) -> str:
    """Map a friendly engine name (e.g. 'ruen') to a real PaddleOCR code."""
    return C.PADDLE.get("lang_map", {}).get(name, name)


def _paddle_build(lang: str) -> _OcrEngine:
    if lang in _paddle:
        return _paddle[lang]
    from paddleocr import PaddleOCR

    log(f"loading paddle (lang={lang}) ...")
    t = time.time()
    _paddle[lang] = PaddleOCR(
        lang=lang,
        device="cpu",
        cpu_threads=C.PADDLE["cpu_threads"],
        use_textline_orientation=C.PADDLE["use_textline_orientation"],
        use_doc_orientation_classify=False,
        use_doc_unwarping=False,
    )
    log(f"paddle ready in {time.time() - t:.1f}s")
    return _paddle[lang]


def _page_items(page: object) -> list[tuple[Sequence[Sequence[float]] | None, str]]:
    """Return [(poly, text)] from a PaddleOCR 3.x result page."""
    d = getattr(page, "json", None)
    if isinstance(d, dict):
        page = d.get("res", d)
    if not isinstance(page, dict):
        return []
    texts = page.get("rec_texts", [])
    polys = page.get("rec_polys") or page.get("dt_polys") or page.get("rec_boxes") or []
    return [(polys[i] if i < len(polys) else None, t) for i, t in enumerate(texts)]


def _reconstruct_lines(items: list[tuple[Sequence[Sequence[float]] | None, str]]) -> str:
    """Group word boxes back into lines using their coordinates."""
    rows: list[tuple[float, float, str]] = []
    heights: list[float] = []
    for poly, txt in items:
        if not poly:
            rows.append((0.0, 0.0, txt))
            continue
        xs = [p[0] for p in poly]
        ys = [p[1] for p in poly]
        rows.append((sum(ys) / len(ys), min(xs), txt))
        heights.append(max(ys) - min(ys))
    if not rows:
        return ""
    lh = sorted(heights)[len(heights) // 2] if heights else 20.0
    rows.sort(key=lambda r: (r[0], r[1]))
    lines: list[list[tuple[float, str]]] = []
    cur: list[tuple[float, str]] = []
    ref: float | None = None
    for yc, x0, txt in rows:
        if ref is None or abs(yc - ref) <= lh * 0.6:
            cur.append((x0, txt))
            ref = yc if ref is None else (ref + yc) / 2
        else:
            lines.append(cur)
            cur = [(x0, txt)]
            ref = yc
    if cur:
        lines.append(cur)
    return "\n".join(" ".join(t for _, t in sorted(ln)) for ln in lines)


def _extract(result: Sequence[object]) -> str:
    items: list[tuple[Sequence[Sequence[float]] | None, str]] = []
    for page in result:
        items.extend(_page_items(page))
    if C.PADDLE.get("reconstruct_lines", True):
        return _reconstruct_lines(items)
    return "\n".join(t for _, t in items)


def _preprocess(img_path: str) -> tuple[str, str | None]:
    """Single-pass upscale before OCR (fights Cyrillic/Latin homoglyph mixups).
    One predict (fast) + a max_side cap so large screenshots are not blown up
    (which would make the detector drop parts of the page and slow down).
    Returns (path_for_ocr, temp_path_to_delete | None)."""
    scale = float(C.PADDLE.get("upscale", 1.0) or 1.0)
    if scale <= 1.0:
        return img_path, None
    try:
        import cv2

        img = cv2.imread(img_path)
        if img is None:
            return img_path, None
        h, w = img.shape[:2]
        max_side = int(C.PADDLE.get("max_side", 2600) or 0)
        eff = min(scale, max_side / max(h, w)) if max_side else scale
        if eff <= 1.05:
            return img_path, None  # already large -> no upscale needed
        up = cv2.resize(img, None, fx=eff, fy=eff, interpolation=cv2.INTER_CUBIC)
        fd, tmp = tempfile.mkstemp(suffix=".png")
        os.close(fd)
        if not cv2.imwrite(tmp, up):  # e.g. no space left in the tmpfs
            with suppress(OSError):
                os.remove(tmp)
            return img_path, None
        return tmp, tmp
    except Exception as e:
        log(f"preprocess failed ({e}); using original")
        return img_path, None


def _paddle_owner_loop() -> None:
    if "paddle" in C.PRELOAD:
        try:
            _paddle_build(_resolve_lang(C.PADDLE["lang"]))
        except Exception as e:
            log(f"preload paddle FAILED: {e}")
    while True:
        lang, img_path, rq = _paddle_jobs.get()
        proc, tmp = _preprocess(img_path)
        try:
            res = _paddle_build(lang).predict(proc)
            rq.put(("ok", _extract(res)))
        except Exception as e:
            rq.put(("err", f"{type(e).__name__}: {e}"))
        finally:
            if tmp and os.path.exists(tmp):
                with suppress(OSError):
                    os.remove(tmp)


def do_ocr(req: dict[str, Any]) -> dict[str, Any]:
    lang = _resolve_lang(req.get("lang") or C.PADDLE["lang"])
    img_path = _materialize_image(req)
    try:
        rq: queue.Queue[tuple[str, str]] = queue.Queue()
        _paddle_jobs.put((lang, img_path, rq))
        status, payload = rq.get()
        if status == "err":
            raise RuntimeError(payload)
        return {"ok": True, "text": payload}
    finally:
        _cleanup(req)


# -------------------------------- NLLB ------------------------------------
def _nllb_build() -> tuple[Any, Any]:
    global _nllb
    if _nllb is not None:
        return _nllb
    import torch
    from transformers import AutoModelForSeq2SeqLM, AutoTokenizer

    torch.set_num_threads(C.NLLB["torch_threads"])
    mid = C.NLLB["model"]
    log(f"loading nllb ({mid}) ...")
    t = time.time()
    tok = AutoTokenizer.from_pretrained(mid)
    model = AutoModelForSeq2SeqLM.from_pretrained(mid)
    model.eval()
    _nllb = (tok, model)
    log(f"nllb ready in {time.time() - t:.1f}s")
    return _nllb


def _lang_token_id(tok: _Tokenizer, code: str) -> int:
    cid = tok.convert_tokens_to_ids(code)
    if cid is not None and cid != getattr(tok, "unk_token_id", None):
        return cid
    lm = getattr(tok, "lang_code_to_id", None)
    if lm and code in lm:
        return lm[code]
    raise ValueError(f"unknown lang code {code}")


def _detect_src(text: str) -> str:
    """Detect the source language.
    Cyrillic is reliably caught by character class (even on 1-2 words) -> rus_Cyrl.
    For Latin script we do NOT assume English: es/fr/de are Latin too, so we let
    langdetect decide."""
    cyr = sum(1 for ch in text if "\u0400" <= ch <= "\u04ff")
    lat = sum(1 for ch in text if "a" <= ch.lower() <= "z")
    if cyr and cyr >= lat:
        return "rus_Cyrl"
    # Best-effort: if langdetect is missing or cannot decide, fall through to
    # the heuristic below.
    with suppress(Exception):
        from langdetect import DetectorFactory, detect

        DetectorFactory.seed = 0
        mapped = C.NLLB["langdetect_map"].get(detect(text))
        if mapped:
            return mapped
    return "rus_Cyrl" if cyr > lat else "eng_Latn"


# Everything that is not a letter or a digit (punctuation, dashes, quotes,
# whitespace) — used to build the dedup key for dictionary-mode variants.
_NON_WORD = re.compile(r"[\W_]+")


def _variant_key(variant: str) -> tuple[str, ...]:
    """Dedup key for dictionary-mode variants (punctuation-insensitive).

    Beam search happily returns the same translation several times with
    different punctuation ("word!" / "word." / "- word!"), or as a repeated
    word ("word word"). The key is case-folded, stripped of punctuation and
    whitespace-normalized; words that repeat inside one variant collapse to
    their first occurrence, so all these artifacts map to one key, while
    genuinely different translations (different senses of a word) stay
    distinct.
    """
    key: list[str] = []
    for word in _NON_WORD.split(variant.casefold()):
        if word and word not in key:
            key.append(word)
    return tuple(key)


def _dict_mode(text: str, req: dict[str, Any]) -> tuple[int, bool]:
    """Decide whether this request uses dictionary mode.

    Returns (n, short). `short` means the input is one or two words (up to
    `dict_max_words`) on a single line; n > 1 together with `short` means
    "generate several dictionary variants"; n == 0 means a normal translation.
    The explicit `variants` flag wins over the auto mode, `no_dict` wins over
    both.
    """
    short = len(text.split()) <= int(C.NLLB.get("dict_max_words", 2)) and "\n" not in text.strip()
    if req.get("no_dict"):
        return 0, short
    if req.get("variants"):
        return int(req["variants"]), short
    if short and C.NLLB.get("dict_auto", True):
        return int(C.NLLB.get("dict_variants", 6)), short
    return 0, short


def do_translate(req: dict[str, Any]) -> dict[str, Any]:
    import torch

    tok, model = _nllb_build()
    text = req["text"]
    src, tgt = req.get("src"), req.get("tgt")
    if not src:
        src = _detect_src(text)
    if not tgt:
        # default target depends on the detected source (configurable)
        tgt = C.NLLB.get("default_targets", {}).get(src) or C.NLLB.get("default_target", "rus_Cyrl")

    # Dictionary mode: one or two words automatically yield several
    # translations. Can be disabled (no_dict) or set explicitly (variants).
    n, short = _dict_mode(text, req)
    if n > 1 and short:
        # Beam search returns many near-identical candidates (punctuation-level
        # duplicates of the same translation), so a couple of extra sequences
        # are requested and the deduplicated list is cut back to n.
        cand = n + 2
        # The tokenizer carries per-request state (`src_lang`), so tokenizing
        # and generating must happen under the same lock, or two concurrent
        # requests could clobber each other's source language.
        with _nllb_lock, torch.no_grad():
            tok.src_lang = src
            enc = tok(text.strip(), return_tensors="pt", truncation=True, max_length=64)
            gen = model.generate(
                **enc,
                forced_bos_token_id=_lang_token_id(tok, tgt),
                max_new_tokens=32,  # two input words can exceed 24 tokens in Russian
                num_beams=max(cand, C.NLLB["num_beams"]),
                num_return_sequences=cand,
            )
        seen: list[str] = []
        keys: set[tuple[str, ...]] = set()
        for out in tok.batch_decode(gen, skip_special_tokens=True):
            out = out.strip()
            key = _variant_key(out)
            if not key or key in keys:  # empty output or a punctuation-level duplicate
                continue
            seen.append(out)
            keys.add(key)
            if len(seen) >= n:
                break
        return {"ok": True, "text": ", ".join(seen), "src": src, "tgt": tgt}

    # Normal mode: translate line by line. `tok.src_lang` is set under the
    # lock for the same reason as above.
    outs: list[str] = []
    with _nllb_lock:
        tok.src_lang = src
        for line in text.splitlines() or [text]:
            if not line.strip():
                outs.append("")
                continue
            enc = tok(line, return_tensors="pt", truncation=True, max_length=1024)
            with torch.no_grad():
                gen = model.generate(
                    **enc,
                    forced_bos_token_id=_lang_token_id(tok, tgt),
                    max_new_tokens=C.NLLB["max_new_tokens"],
                    num_beams=req.get("num_beams") or C.NLLB["num_beams"],
                )
            outs.append(tok.batch_decode(gen, skip_special_tokens=True)[0])
    return {"ok": True, "text": "\n".join(outs), "src": src, "tgt": tgt}


# ---------------------------- image helpers -------------------------------
_MAGIC = [
    (b"\x89PNG\r\n\x1a\n", ".png"),
    (b"\xff\xd8\xff", ".jpg"),
    (b"GIF87a", ".gif"),
    (b"GIF89a", ".gif"),
    (b"BM", ".bmp"),
    (b"%PDF", ".pdf"),
    (b"II*\x00", ".tif"),
    (b"MM\x00*", ".tif"),
]


def _guess_suffix(data: bytes) -> str:
    if data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        return ".webp"
    for sig, ext in _MAGIC:
        if data.startswith(sig):
            return ext
    return ".png"


def _materialize_image(req: dict[str, Any]) -> str:
    """Image bytes always arrive base64-encoded over the socket (stdin pipe)."""
    if req.get("image_b64"):
        raw = base64.b64decode(req["image_b64"])
        fd, path = tempfile.mkstemp(suffix=_guess_suffix(raw))
        with os.fdopen(fd, "wb") as f:
            f.write(raw)
        req["_tmp"] = path
        return path
    raise ValueError("no image provided")


def _cleanup(req: dict[str, Any]) -> None:
    if req.get("_tmp") and os.path.exists(req["_tmp"]):
        with suppress(OSError):
            os.remove(req["_tmp"])


# ------------------------------- server -----------------------------------
HANDLERS = {"ocr": do_ocr, "translate": do_translate}


def handle(req: dict[str, Any]) -> dict[str, Any]:
    action = req.get("action")
    if action == "ping":
        return {
            "ok": True,
            "loaded": {
                "paddle_langs": sorted(_paddle.keys()),
                "nllb": _nllb is not None,
            },
        }
    fn = HANDLERS.get(action)
    if not fn:
        return {"ok": False, "error": f"unknown action {action}"}
    try:
        t = time.time()
        out = fn(req)
        out["elapsed"] = round(time.time() - t, 2)
        return out
    except Exception as e:
        return {"ok": False, "error": str(e), "trace": traceback.format_exc()}


def _client(conn: socket.socket) -> None:
    try:
        buf = bytearray()
        while b"\n" not in buf:
            chunk = conn.recv(65536)
            if not chunk:
                return
            buf += chunk
        req = json.loads(bytes(buf).split(b"\n", 1)[0].decode())
        conn.sendall((json.dumps(handle(req), ensure_ascii=False) + "\n").encode())
    except Exception as e:
        # The peer is gone or the request is malformed: best effort reply.
        with suppress(OSError):
            conn.sendall((json.dumps({"ok": False, "error": str(e)}) + "\n").encode())
    finally:
        conn.close()


def serve() -> None:
    if os.path.exists(SOCK):
        os.remove(SOCK)
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.bind(SOCK)
    # Only processes running as the container's own user (podman exec) talk
    # to the worker.
    os.chmod(SOCK, 0o600)
    s.listen(8)
    log(f"listening on {SOCK}")
    while True:
        conn, _ = s.accept()
        threading.Thread(target=_client, args=(conn,), daemon=True).start()


if __name__ == "__main__":
    log("preloading models (one-time warm-up)...")
    threading.Thread(target=_paddle_owner_loop, daemon=True).start()  # paddle owner
    if "nllb" in C.PRELOAD:
        try:
            _nllb_build()
        except Exception as e:
            log(f"preload nllb FAILED: {e}")
    log("warm-up done; ready for warm requests")
    serve()
