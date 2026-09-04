#!/usr/bin/env python3
"""Rename photos in ~/Pictures/desktop-photos to match export.json.

export.json maps a base (untagged) filename to either {"x", "y", "w", "h"}
(tag it, replacing any existing tag) or null (strip an existing tag). Bases
absent from the file are left untouched. Run with --dry-run to preview.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from server import PHOTOS_DIR, EXPORT_PATH, parse_photo  # noqa: E402


def tag_component(n):
    return f"n{-n}" if n < 0 else str(n)


def target_name(base, x, y, w, h):
    stem, ext = base.rsplit(".", 1)
    if x is None or y is None:
        return f"{stem}.{ext}"
    tag = f"{stem}__clockpos_{tag_component(x)}_{tag_component(y)}"
    if w and h:
        tag += f"_{w}x{h}"
    return f"{tag}.{ext}"


def main():
    dry_run = "--dry-run" in sys.argv
    if not EXPORT_PATH.exists():
        sys.exit(f"no export file at {EXPORT_PATH}")
    state = json.loads(EXPORT_PATH.read_text())

    by_base = {}
    for p in sorted(PHOTOS_DIR.iterdir()):
        info = parse_photo(p.name)
        if info:
            by_base[info["base"]] = p.name

    changes = []
    for base, pos in state.items():
        current = by_base.get(base)
        if current is None:
            print(f"skip (not found): {base}", file=sys.stderr)
            continue
        if pos:
            x, y, w, h = pos["x"], pos["y"], pos.get("w"), pos.get("h")
        else:
            x = y = w = h = None
        new_name = target_name(base, x, y, w, h)
        if new_name != current:
            changes.append((current, new_name))

    if not changes:
        print("nothing to do")
        return

    for old, new in changes:
        print(f"{old}  ->  {new}")
    if dry_run:
        print(f"\n(dry run: {len(changes)} file(s) would be renamed)")
        return

    for old, new in changes:
        (PHOTOS_DIR / old).rename(PHOTOS_DIR / new)
    print(f"\nrenamed {len(changes)} file(s)")


if __name__ == "__main__":
    main()
