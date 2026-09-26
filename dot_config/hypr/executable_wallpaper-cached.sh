#!/usr/bin/env bash
# Prints a copy of the given photo shrunk to cover a 4K screen, creating it on first use.
#
# The originals are 20-24MP, and hyprpaper decoding and uploading one of those
# on the iGPU makes Hyprland drop frames at every slideshow rotation.

set -uo pipefail

src="$1"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/wallpapers/3840x2160"
dst="$cache/$(basename "$src")"

if [[ ! -f "$dst" || "$src" -nt "$dst" ]]; then
    if ! command -v magick >/dev/null; then
        echo "$src"
        exit 0
    fi
    mkdir -p "$cache"
    tmp="$dst.tmp.$$"
    if nice -n 19 ionice -c 3 magick "$src" -auto-orient -resize '3840x2160^' \
        -strip -quality 90 "JPEG:$tmp" 2>/dev/null; then
        mv -f "$tmp" "$dst"
    else
        rm -f "$tmp"
        echo "$src"
        exit 0
    fi
fi

echo "$dst"
