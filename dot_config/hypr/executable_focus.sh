#!/usr/bin/env bash
# Focus mode toggle. With focus on, monitor-setup.sh disables every monitor in
# the matched profile except the one tagged `focus:` in chezmoi.toml.
#
# Usage:
#   focus               # toggle
#   focus on|off|toggle
#   focus status        # prints "on" or "off"
#   focus waybar        # prints JSON for a waybar custom module

set -euo pipefail

STATE="${XDG_RUNTIME_DIR}/hypr-focus"
MONITOR_SETUP="${HOME}/.config/hypr/monitor-setup.sh"

# Font Awesome glyphs: f066 = compress (focused), f065 = expand (all displays).
ICON_ON=$''
ICON_OFF=$''

cmd="${1:-toggle}"

case "$cmd" in
    on)
        touch "$STATE"
        ;;
    off)
        rm -f "$STATE"
        ;;
    toggle)
        if [[ -e "$STATE" ]]; then rm -f "$STATE"; else touch "$STATE"; fi
        ;;
    status)
        if [[ -e "$STATE" ]]; then echo "on"; else echo "off"; fi
        exit 0
        ;;
    waybar)
        if [[ -e "$STATE" ]]; then
            printf '{"text":"%s","tooltip":"Focus mode: on","class":"on","alt":"on"}\n' "$ICON_ON"
        else
            printf '{"text":"%s","tooltip":"Focus mode: off","class":"off","alt":"off"}\n' "$ICON_OFF"
        fi
        exit 0
        ;;
    *)
        echo "usage: focus [on|off|toggle|status|waybar]" >&2
        exit 2
        ;;
esac

"$MONITOR_SETUP" --apply
pkill -RTMIN+8 waybar 2>/dev/null || true
