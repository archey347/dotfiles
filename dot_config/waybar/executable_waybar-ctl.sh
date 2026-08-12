#!/usr/bin/env bash
# Start/stop waybar around a monitor layout change.
#
# waybar 0.14 segfaults when an output is destroyed while its bar is up. Each
# bar owns its own mpris module, and tearing the bar down frees the module
# without disconnecting its playerctl properties-changed handler — the next
# MPRIS update from a player then dispatches into freed memory:
#
#   Glib::DispatchNotifier::send_notification
#   playerctl_player_properties_changed_callback
#
# Both waybar coredumps on this machine have exactly that stack, which is why it
# only bites sometimes: it needs a media player to emit an update during the
# teardown window. Nothing supervises `exec-once = waybar`, so once it goes the
# bar stays gone until it is started by hand.
#
# So monitor-setup.sh takes the bar down before it touches the outputs and puts
# a fresh one up afterwards — waybar is never alive while an output disappears.
#
# Usage: waybar-ctl.sh [stop|start|restart]

set -uo pipefail

stop_waybar() {
    pkill -x waybar 2>/dev/null

    # Wait for it to actually exit — a new instance racing the old one's
    # teardown fights it for the layer surfaces.
    local _
    for _ in $(seq 1 50); do
        pgrep -x waybar >/dev/null || return 0
        sleep 0.1
    done
    pkill -KILL -x waybar 2>/dev/null
}

start_waybar() {
    # setsid so the bar outlives whatever called us — the hotplug watcher in
    # monitor-setup.sh, or focus.sh running as a child of the waybar we killed.
    setsid -f waybar >/dev/null 2>&1
}

case "${1:-restart}" in
    stop)    stop_waybar ;;
    start)   start_waybar ;;
    restart) stop_waybar; start_waybar ;;
    *)
        echo "usage: waybar-ctl.sh [stop|start|restart]" >&2
        exit 2
        ;;
esac
