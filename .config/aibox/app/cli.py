#!/usr/bin/env python3
"""
Thin client for the background worker (Unix socket). Models are already warm.
Invoked via `podman exec -i`. All input is read from stdin.

Examples (with the alias  ai='podman exec -i aibox aibox /app/cli.py'):

  # OCR — pipe an image
  cat pic.png | ai ocr
  cat pic.png | ai ocr --lang en

  # Translate — pipe text (source language is auto-detected)
  echo "Hello world" | ai tr
  echo "Привет мир" | ai tr
  echo "Bonjour" | ai tr --tgt rus_Cyrl

  ai ping
"""

import argparse
import base64
import json
import socket
import sys
from typing import Any

SOCK = "/tmp/aibox.sock"
TIMEOUT = 900  # seconds


def call(req: dict[str, Any], timeout: float = TIMEOUT) -> dict[str, Any]:
    """Send one JSON request to the worker, return the JSON response."""
    buf = bytearray()
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(timeout)
            s.connect(SOCK)
            s.sendall((json.dumps(req) + "\n").encode())
            while b"\n" not in buf:
                chunk = s.recv(65536)
                if not chunk:
                    break
                buf += chunk
    except TimeoutError:
        sys.exit(f"[error] the worker did not answer within {timeout}s; try `podman logs aibox`")
    except OSError as e:
        sys.exit(
            f"[error] cannot reach the worker ({e}); is the aibox container "
            f"running? Try `podman logs aibox`"
        )
    if not buf:
        sys.exit("[error] the worker closed the connection without a response")
    try:
        return json.loads(bytes(buf).split(b"\n", 1)[0].decode())
    except (UnicodeDecodeError, ValueError) as e:
        sys.exit(f"[error] malformed worker response: {e}")


def stdin_bytes() -> bytes:
    return b"" if sys.stdin.isatty() else sys.stdin.buffer.read()


def main() -> None:
    ap = argparse.ArgumentParser(prog="aibox")
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("ocr", help="OCR via PaddleOCR (pipe an image to stdin)")
    p.add_argument(
        "--lang",
        help="force one language for best quality: ru, en, ch, "
        "japan, korean, latin, fr, german, es ... "
        "(default ru = Cyrillic+Latin+digits)",
    )

    p = sub.add_parser("tr", help="translate via NLLB (source auto-detected)")
    p.add_argument("--src", help="source FLORES code, e.g. eng_Latn (else auto)")
    p.add_argument("--tgt", help="target FLORES code, e.g. rus_Cyrl (else auto)")
    p.add_argument("--num-beams", type=int, dest="num_beams")
    p.add_argument(
        "--variants",
        type=int,
        default=0,
        help="dictionary mode: N variants for short input (1-2 words, else auto)",
    )
    p.add_argument(
        "--no-dict",
        action="store_true",
        dest="no_dict",
        help="disable the automatic dictionary mode for short input",
    )

    sub.add_parser("ping", help="show what is loaded / whether the worker is alive")

    a = ap.parse_args()

    if a.cmd == "ping":
        print(json.dumps(call({"action": "ping"}), ensure_ascii=False, indent=2))
        return

    if a.cmd == "ocr":
        data = stdin_bytes()
        if not data:
            sys.exit("no image: pipe one in, e.g. `cat img.png | ai ocr`")
        req: dict[str, Any] = {
            "action": "ocr",
            "image_b64": base64.b64encode(data).decode(),
        }
        if a.lang:
            req["lang"] = a.lang
    elif a.cmd == "tr":
        text = stdin_bytes().decode("utf-8", "replace").strip()
        if not text:
            sys.exit("no text: pipe it in, e.g. `echo hi | ai tr`")
        req = {"action": "translate", "text": text, "src": a.src, "tgt": a.tgt}
        if a.num_beams:
            req["num_beams"] = a.num_beams
        if a.variants:
            req["variants"] = a.variants
        if a.no_dict:
            req["no_dict"] = True
    else:
        ap.error("unknown")

    resp = call(req)
    if not resp.get("ok"):
        sys.stderr.write(f"[error] {resp.get('error')}\n")
        if resp.get("trace"):
            sys.stderr.write(resp["trace"] + "\n")
        sys.exit(1)
    if "elapsed" in resp:
        extra = f" {resp['src']}->{resp['tgt']}" if resp.get("tgt") else ""
        sys.stderr.write(f"[{resp['elapsed']}s{extra}]\n")
    print(resp["text"])


if __name__ == "__main__":
    main()
