#!/usr/bin/env python3
"""Local editor for lock-screen clock positions.

Serves dot_config/hypr/hyprlock.conf.tmpl's photo set from
~/Pictures/desktop-photos and lets you click each photo to place where the
clock should sit. Every change is saved immediately to export.json next to
this script (keyed by the untagged base filename), so nothing is lost if the
browser tab closes. Applying export.json to the actual filenames is a
separate, explicit step (see apply.py) — this tool never renames files.
"""
import json
import re
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote

PHOTOS_DIR = Path.home() / "Pictures" / "desktop-photos"
SCRIPT_DIR = Path(__file__).resolve().parent
EXPORT_PATH = SCRIPT_DIR / "export.json"
INDEX_PATH = SCRIPT_DIR / "index.html"

TAG_RE = re.compile(r"^(?P<base>.+?)(?:__clockpos_(?P<xs>n?\d+)_(?P<ys>n?\d+))?(?P<ext>\.[A-Za-z0-9]+)$")


def signed(s):
    return -int(s[1:]) if s.startswith("n") else int(s)


def parse_photo(name):
    m = TAG_RE.match(name)
    if not m:
        return None
    base = m.group("base") + m.group("ext")
    x = signed(m.group("xs")) if m.group("xs") else None
    y = signed(m.group("ys")) if m.group("ys") else None
    return {"base": base, "filename": name, "x": x, "y": y}


def load_state():
    if EXPORT_PATH.exists():
        return json.loads(EXPORT_PATH.read_text())
    return {}


def list_photos():
    # state[base] is a dict for a placed clock, or explicit None for
    # "cleared" (as opposed to absent, meaning untouched — apply.py tells
    # these apart to decide whether to strip an existing on-disk tag).
    state = load_state()
    photos = []
    for p in sorted(PHOTOS_DIR.iterdir()):
        if p.suffix.lower() not in (".jpg", ".jpeg", ".png"):
            continue
        info = parse_photo(p.name)
        if info is None:
            continue
        if info["base"] in state:
            pos = state[info["base"]]
            info["x"], info["y"] = (pos["x"], pos["y"]) if pos else (None, None)
        photos.append(info)
    return photos


CONTENT_TYPES = {".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".png": "image/png"}


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def _json(self, obj, status=200):
        body = json.dumps(obj).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/":
            body = INDEX_PATH.read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", "text/html")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        elif self.path == "/api/photos":
            self._json(list_photos())
        elif self.path.startswith("/photos/"):
            name = unquote(self.path[len("/photos/"):])
            target = (PHOTOS_DIR / name).resolve()
            if PHOTOS_DIR.resolve() not in target.parents or not target.is_file():
                self.send_response(404)
                self.end_headers()
                return
            body = target.read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", CONTENT_TYPES.get(target.suffix.lower(), "application/octet-stream"))
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path != "/api/save":
            self.send_response(404)
            self.end_headers()
            return
        length = int(self.headers.get("Content-Length", 0))
        payload = json.loads(self.rfile.read(length))
        base = payload["base"]
        state = load_state()
        if payload.get("x") is None or payload.get("y") is None:
            state[base] = None
        else:
            state[base] = {"x": payload["x"], "y": payload["y"]}
        EXPORT_PATH.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n")
        self._json({"ok": True, "count": len(state)})


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8731
    if not PHOTOS_DIR.is_dir():
        sys.exit(f"no such directory: {PHOTOS_DIR}")
    server = ThreadingHTTPServer(("127.0.0.1", port), Handler)
    print(f"clockpos editor: http://127.0.0.1:{port}/")
    print(f"saving to: {EXPORT_PATH}")
    server.serve_forever()


if __name__ == "__main__":
    main()
