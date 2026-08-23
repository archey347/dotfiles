#!/usr/bin/env bash
# random-lock-photo.sh: print the path of a random photo from the desktop
# slideshow set. Called once by ~/bin/lock at the start of each lock session
# to pick that session's photo.
set -euo pipefail

DIR="$HOME/Pictures/desktop-photos"          # same set as the wallpaper slideshow

mapfile -d '' photos < <(find "$DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0)

(( ${#photos[@]} == 0 )) && exit 0

printf '%s\n' "${photos[RANDOM % ${#photos[@]}]}"
