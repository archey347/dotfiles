#!/usr/bin/env bash
# random-lock-photo.sh: print the path of a random photo from the desktop
# slideshow set. Used as hyprlock's image `reload_cmd` — hyprlock takes the
# stdout as the new image path, so each reload swaps to a fresh random photo.
# Each monitor's image block calls this independently, so monitors cycle
# independently.
set -euo pipefail

DIR="$HOME/Pictures/desktop-photos"          # same set as the wallpaper slideshow

mapfile -d '' photos < <(find "$DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0)

(( ${#photos[@]} == 0 )) && exit 0

printf '%s\n' "${photos[RANDOM % ${#photos[@]}]}"
