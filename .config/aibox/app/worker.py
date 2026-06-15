#!/usr/bin/env python3
"""
Background worker: loads the models once and keeps them warm.
Listens on a Unix socket (/tmp/aibox.sock) and answers JSON requests.
Started automatically inside the container. The client is cli.py.

Models are baked into the image at build time by download.py, so nothing is
fetched at runtime (the container runs fully offline).
"""

import os, sys, json, socket, time, threading, queue, base64, tempfile, traceback

sys.path.insert(0, "/app")
import config as C

SOCK = "/tmp/aibox.sock"
_nllb = None  # (tok, model)
_nllb_lock = threading.Lock()

# PaddleOCR is NOT thread-safe (its predictor is bound to the thread that
# created it; calling from another thread -> std::exception). So all Paddle work
# lives in ONE owner thread, fed through a queue.
_paddle = {}  # lang -> PaddleOCR (one engine per language)
_paddle_jobs = queue.Queue()  # (lang, img_path, result_queue)


def log(*a):
    print("[worker]", *a, file=sys.stderr, flush=True)


# ------------------------------ PaddleOCR ---------------------------------
def _resolve_lang(name):
    """Map a friendly engine name (e.g. 'ruen') to a real PaddleOCR code."""
    return C.PADDLE.get("lang_map", {}).get(name, name)


def _paddle_build(lang):
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


def _page_items(page):
    """Return [(poly, text)] from a PaddleOCR 3.x result page."""
    d = getattr(page, "json", None)
    if isinstance(d, dict):
        page = d.get("res", d)
    if not isinstance(page, dict):
        return []
    texts = page.get("rec_texts", [])
    polys = page.get("rec_polys") or page.get("dt_polys") or page.get("rec_boxes") or []
    return [(polys[i] if i < len(polys) else None, t) for i, t in enumerate(texts)]


def _reconstruct_lines(items):
    """Group word boxes back into lines using their coordinates."""
    rows = []
    heights = []
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
    lines, cur, ref = [], [], None
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


def _extract(result):
    items = []
    for page in result:
        items.extend(_page_items(page))
    if C.PADDLE.get("reconstruct_lines", True):
        return _reconstruct_lines(items)
    return "\n".join(t for _, t in items)


def _preprocess(img_path):
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
        cv2.imwrite(tmp, up)
        return tmp, tmp
    except Exception as e:
        log(f"preprocess failed ({e}); using original")
        return img_path, None


def _paddle_owner_loop():
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
                try:
                    os.remove(tmp)
                except OSError:
                    pass


def do_ocr(req):
    lang = _resolve_lang(req.get("lang") or C.PADDLE["lang"])
    img_path = _materialize_image(req)
    try:
        rq = queue.Queue()
        _paddle_jobs.put((lang, img_path, rq))
        status, payload = rq.get()
        if status == "err":
            raise RuntimeError(payload)
        return {"ok": True, "text": payload}
    finally:
        _cleanup(req)


# -------------------------------- NLLB ------------------------------------
def _nllb_build():
    global _nllb
    if _nllb is not None:
        return _nllb
    import torch
    from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

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


def _lang_token_id(tok, code):
    cid = tok.convert_tokens_to_ids(code)
    if cid is not None and cid != getattr(tok, "unk_token_id", None):
        return cid
    lm = getattr(tok, "lang_code_to_id", None)
    if lm and code in lm:
        return lm[code]
    raise ValueError(f"unknown lang code {code}")


def _detect_src(text):
    """Detect the source language.
    Cyrillic is reliably caught by character class (even on 1-2 words) -> rus_Cyrl.
    For Latin script we do NOT assume English: es/fr/de are Latin too, so we let
    langdetect decide."""
    cyr = sum(1 for ch in text if "\u0400" <= ch <= "\u04ff")
    lat = sum(1 for ch in text if "a" <= ch.lower() <= "z")
    if cyr and cyr >= lat:
        return "rus_Cyrl"
    try:
        from langdetect import detect, DetectorFactory

        DetectorFactory.seed = 0
        mapped = C.NLLB["langdetect_map"].get(detect(text))
        if mapped:
            return mapped
    except Exception:
        pass
    return "rus_Cyrl" if cyr > lat else "eng_Latn"


def do_translate(req):
    import torch

    tok, model = _nllb_build()
    text = req["text"]
    src, tgt = req.get("src"), req.get("tgt")
    if not src:
        src = _detect_src(text)
    if not tgt:
        # default target depends on the detected source (configurable)
        tgt = C.NLLB.get("default_targets", {}).get(src) or C.NLLB.get(
            "default_target", "rus_Cyrl"
        )
    tok.src_lang = src

    # Dictionary mode: a single word automatically yields several translations.
    # Can be disabled (no_dict) or set explicitly (variants).
    one_word = len(text.split()) == 1 and "\n" not in text.strip()
    if req.get("no_dict"):
        n = 0
    elif req.get("variants"):
        n = int(req["variants"])
    elif one_word and C.NLLB.get("dict_auto", True):
        n = int(C.NLLB.get("dict_variants", 6))
    else:
        n = 0
    if n > 1 and one_word:
        enc = tok(text.strip(), return_tensors="pt", truncation=True, max_length=64)
        with _nllb_lock, torch.no_grad():
            gen = model.generate(
                **enc,
                forced_bos_token_id=_lang_token_id(tok, tgt),
                max_new_tokens=24,
                num_beams=max(n, C.NLLB["num_beams"]),
                num_return_sequences=n,
            )
        seen = []
        for o in tok.batch_decode(gen, skip_special_tokens=True):
            o = o.strip()
            if o and o.lower() not in [s.lower() for s in seen]:
                seen.append(o)
        return {"ok": True, "text": ", ".join(seen), "src": src, "tgt": tgt}

    # Normal mode: translate line by line.
    outs = []
    with _nllb_lock:
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
                    num_beams=req.get("num_beams", C.NLLB["num_beams"]),
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


def _guess_suffix(data):
    if data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        return ".webp"
    for sig, ext in _MAGIC:
        if data.startswith(sig):
            return ext
    return ".png"


def _materialize_image(req):
    """Image bytes always arrive base64-encoded over the socket (stdin pipe)."""
    if req.get("image_b64"):
        raw = base64.b64decode(req["image_b64"])
        fd, path = tempfile.mkstemp(suffix=_guess_suffix(raw))
        with os.fdopen(fd, "wb") as f:
            f.write(raw)
        req["_tmp"] = path
        return path
    raise ValueError("no image provided")


def _cleanup(req):
    if req.get("_tmp") and os.path.exists(req["_tmp"]):
        try:
            os.remove(req["_tmp"])
        except OSError:
            pass


# ------------------------------- server -----------------------------------
HANDLERS = {"ocr": do_ocr, "translate": do_translate}


def handle(req):
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


def _client(conn):
    try:
        buf = b""
        while b"\n" not in buf:
            chunk = conn.recv(65536)
            if not chunk:
                return
            buf += chunk
        req = json.loads(buf.split(b"\n", 1)[0].decode())
        conn.sendall((json.dumps(handle(req), ensure_ascii=False) + "\n").encode())
    except Exception as e:
        try:
            conn.sendall((json.dumps({"ok": False, "error": str(e)}) + "\n").encode())
        except OSError:
            pass
    finally:
        conn.close()


def serve():
    if os.path.exists(SOCK):
        os.remove(SOCK)
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.bind(SOCK)
    os.chmod(SOCK, 0o666)
    s.listen(8)
    log(f"listening on {SOCK}")
    while True:
        conn, _ = s.accept()
        threading.Thread(target=_client, args=(conn,), daemon=True).start()


if __name__ == "__main__":
    log("preloading models (one-time warm-up)...")
    threading.Thread(
        target=_paddle_owner_loop, daemon=True
    ).start()  # paddle owner thread
    if "nllb" in C.PRELOAD:
        try:
            _nllb_build()
        except Exception as e:
            log(f"preload nllb FAILED: {e}")
    log("warm-up done; ready for warm requests")
    serve()
