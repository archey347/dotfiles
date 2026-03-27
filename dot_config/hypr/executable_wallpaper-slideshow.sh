#!/bin/bash
# Wallpaper slideshow for hyprpaper
# Change INTERVAL to control how often the wallpaper rotates (in seconds)

WALLPAPER_DIR="$HOME/Pictures/desktop-photos"
INTERVAL=300       # seconds between wallpaper rotations
STAGGER=5          # seconds between each monitor update

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
    -print0)

if [ ${#images[@]} -eq 0 ]; then
    echo "No images found in $WALLPAPER_DIR" >&2
    exit 1
fi

declare -A prev_img
monitor_idx=0

# Set a random wallpaper on each monitor at startup
mapfile -t monitors < <(hyprctl monitors -j | jq -r '.[].name')
for monitor in "${monitors[@]}"; do
    img="${images[$((RANDOM % ${#images[@]}))]}"
    hyprctl hyprpaper preload "$img"
    hyprctl hyprpaper wallpaper "$monitor,$img"
    prev_img[$monitor]="$img"
done

while true; do
    mapfile -t monitors < <(hyprctl monitors -j | jq -r '.[].name')
    n=${#monitors[@]}

    sleep $(( INTERVAL / n ))

    monitor="${monitors[$((monitor_idx % n))]}"
    img="${images[$((RANDOM % ${#images[@]}))]}"

    hyprctl hyprpaper preload "$img"
    hyprctl hyprpaper wallpaper "$monitor,$img"

    if [ -n "${prev_img[$monitor]}" ] && [ "${prev_img[$monitor]}" != "$img" ]; then
        hyprctl hyprpaper unload "${prev_img[$monitor]}"
    fi

    prev_img[$monitor]="$img"
    monitor_idx=$(( monitor_idx + 1 ))
done
