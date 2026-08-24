#!/usr/bin/env bash
# Default http(s) handler: open a link in the Firefox window on the workspace
# you are already on, instead of wherever Firefox last had focus.
#
# Firefox runs as one process, so `firefox <url>` is a remote command that lands
# in that process's most recently focused window — which is why a link clicked in
# a terminal on workspace 7 opens on workspace 5. Focusing the local window first
# is the only lever the CLI gives us over which window wins.
#
# Usage: open-url.sh [URL...]

set -euo pipefail

CLASS='org.mozilla.firefox'

# Nothing to ask about the layout (ssh, a tty, a non-Hyprland session).
if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] || ! command -v hyprctl >/dev/null; then
    exec firefox "$@"
fi

ws=$(hyprctl activeworkspace -j | jq -r '.id')

# Most recently focused window is the one with the lowest focusHistoryID. Skip
# pinned windows: Picture-in-Picture rides along on every workspace and must
# never swallow a link.
addr=$(hyprctl clients -j | jq -r --argjson ws "$ws" --arg class "$CLASS" '
    [ .[] | select(.class == $class and .workspace.id == $ws and .pinned == false) ]
    | min_by(.focusHistoryID) | .address // empty')

if [[ -z "$addr" ]]; then
    exec firefox --new-window "$@"
fi

hyprctl dispatch focuswindow "address:$addr" >/dev/null

# Firefox chooses its target from its own focus bookkeeping, which only updates
# once the compositor has actually handed the window keyboard focus.
for _ in {1..40}; do
    [[ "$(hyprctl activewindow -j | jq -r '.address // empty')" == "$addr" ]] && break
    sleep 0.025
done

[[ $# -eq 0 ]] && exit 0
exec firefox --new-tab "$@"
