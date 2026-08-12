#!/usr/bin/env bash
# Focus mode toggle. With focus on, monitor-setup.sh disables every monitor in
# the matched profile except the one you are working on.
#
# Which monitor that is gets recorded here, at the moment focus mode is switched
# on: the state file holds the description of the monitor that was focused, so
# clicking the waybar button (or hitting the keybind) keeps the screen the mouse
# is on rather than always collapsing to the one tagged `focus:` in chezmoi.toml.
# That tag stays as the fallback for when the focused monitor can't be used.
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

# Description of the monitor Hyprland currently has focused. follow_mouse is on,
# so for a waybar click this is the monitor whose bar was clicked. If this comes
# out empty the state file is simply left empty and monitor-setup.sh falls back
# to the `focus:` tag.
focus_on() {
    hyprctl monitors -j 2>/dev/null \
        | jq -r 'first(.[] | select(.focused == true) | .description) // ""' \
        > "$STATE" 2>/dev/null || true
}

case "$cmd" in
    on)
        focus_on
        ;;
    off)
        rm -f "$STATE"
        ;;
    toggle)
        if [[ -e "$STATE" ]]; then rm -f "$STATE"; else focus_on; fi
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

# --apply restarts waybar (it does not survive an output being destroyed), so
# the new instance picks up the toggled state on its own — no RTMIN+8 needed.
"$MONITOR_SETUP" --apply
