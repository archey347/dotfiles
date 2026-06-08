#!/usr/bin/env bash
# Move the current workspace to the Nth monitor, where monitors are numbered
# left-to-right by physical x position (1 = leftmost). Only enabled monitors are
# counted, so the numbering matches what waybar shows. Bound to Alt+N in
# hyprland.conf; also used by the waybar custom/monitors module to label screens.
#
# Usage:
#   move-ws-to-monitor.sh <N>       # move current workspace to monitor N
#   move-ws-to-monitor.sh list      # print "<N>\t<name>\t<description>" per monitor
set -euo pipefail

# Enabled monitors, left-to-right. tab-separated: name<TAB>description
monitors() {
    hyprctl monitors -j 2>/dev/null \
        | jq -r 'sort_by(.x)[] | "\(.name)\t\(.description)"'
}

case "${1:-}" in
    ""|-h|--help)
        echo "usage: move-ws-to-monitor.sh <monitor-number|list>" >&2
        exit 2
        ;;
    list)
        monitors | nl -w1 -s$'\t'
        exit 0
        ;;
esac

n="$1"
if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 1 )); then
    echo "monitor number must be a positive integer" >&2
    exit 2
fi

name=$(monitors | sed -n "${n}p" | cut -f1)
if [[ -z "$name" ]]; then
    notify-send "Move workspace" "No monitor #$n" 2>/dev/null || true
    exit 1
fi

hyprctl dispatch movecurrentworkspacetomonitor "$name"
