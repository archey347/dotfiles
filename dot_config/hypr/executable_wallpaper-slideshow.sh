#!/bin/bash
# Wallpaper slideshow for hyprpaper
# Change INTERVAL to control how often the wallpaper rotates (in seconds)

WALLPAPER_DIR="$HOME/Pictures/desktop-photos"
INTERVAL=300  # 5 minutes

# Wait for hyprpaper IPC socket to be available
for i in $(seq 1 20); do
    if hyprctl hyprpaper listloaded &>/dev/null; then
        break
    fi
    sleep 1
done

# Collect all images
mapfile -d '' images < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    -print0 | sort -z)

if [ ${#images[@]} -eq 0 ]; then
    echo "No images found in $WALLPAPER_DIR" >&2
    exit 1
fi

idx=0
prev_img=""

while true; do
    img="${images[$idx]}"

    hyprctl hyprpaper preload "$img"
    hyprctl hyprpaper wallpaper ",$img"

    if [ -n "$prev_img" ] && [ "$prev_img" != "$img" ]; then
        hyprctl hyprpaper unload "$prev_img"
    fi

    prev_img="$img"
    idx=$(( (idx + 1) % ${#images[@]} ))

    sleep "$INTERVAL"
done
