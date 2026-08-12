#!/usr/bin/env bash
# Re-establish the wallpaper on every connected monitor.
#
# hyprpaper binds a wallpaper to an output, and that binding dies with the
# output. Leaving focus mode brings monitors back with nothing painted on them,
# and wallpaper-slideshow.sh only repaints one monitor per rotation
# (INTERVAL/n seconds), so a returning monitor can sit black for minutes.
#
# monitor-setup.sh calls this after every layout change. Each monitor keeps
# whatever image it is already showing — only monitors without one get a fresh
# random pick — so this is a no-op visually when everything is already fine.

set -uo pipefail

WALLPAPER_DIR="$HOME/Pictures/desktop-photos"

mapfile -d '' images < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    -print0)
[[ ${#images[@]} -eq 0 ]] && exit 0

# hyprpaper may still be coming up (hyprland.conf delays it 2s at login).
for _ in $(seq 1 20); do
    hyprctl hyprpaper listactive &>/dev/null && break
    sleep 1
done

declare -A current
while IFS= read -r line; do
    [[ "$line" == *" = "* ]] || continue
    current["${line%% = *}"]="${line#* = }"
done < <(hyprctl hyprpaper listactive 2>/dev/null)

for monitor in $(hyprctl monitors -j 2>/dev/null | jq -r '.[].name'); do
    img="${current[$monitor]:-}"
    if [[ -z "$img" || ! -f "$img" ]]; then
        img="${images[$((RANDOM % ${#images[@]}))]}"
    fi
    # Re-issue both: the image may have been unloaded with the output, and
    # re-setting a wallpaper the monitor already has costs nothing.
    hyprctl hyprpaper preload "$img" >/dev/null
    hyprctl hyprpaper wallpaper "$monitor,$img" >/dev/null
done
