#!/bin/bash
ICON_ON=$''   # fa-lock
ICON_OFF=$''  # fa-lock-open

entries=""

# WireGuard via NetworkManager
if command -v nmcli >/dev/null 2>&1; then
    while IFS= read -r conn; do
        [ -z "$conn" ] && continue
        state=$(nmcli -t -f GENERAL.STATE connection show "$conn" 2>/dev/null | cut -d: -f2)
        if [ "$state" = "activated" ]; then
            entries+="$ICON_ON $conn\n"
        else
            entries+="$ICON_OFF $conn\n"
        fi
    done <<< "$(nmcli -t -f NAME,TYPE connection show 2>/dev/null | awk -F: '$2=="wireguard"{print $1}')"
fi

# Tailscale
if command -v tailscale >/dev/null 2>&1; then
    ts_state=$(tailscale status --json 2>/dev/null | sed -n 's/.*"BackendState": *"\([^"]*\)".*/\1/p' | head -n1)
    if [ "$ts_state" = "Running" ]; then
        entries+="$ICON_ON Tailscale\n"
    else
        entries+="$ICON_OFF Tailscale\n"
    fi
fi

[ -z "$entries" ] && notify-send "VPN" "No VPN profiles available" && exit 0

chosen=$(printf "%b" "$entries" | wofi --dmenu --prompt "VPN" --width 350 --height 200 --cache-file /dev/null)
[ -z "$chosen" ] && exit 0

# Strip icon prefix to get name
conn=$(echo "$chosen" | sed 's/^[^ ]* //')

if [ "$conn" = "Tailscale" ]; then
    ts_state=$(tailscale status --json 2>/dev/null | sed -n 's/.*"BackendState": *"\([^"]*\)".*/\1/p' | head -n1)
    if [ "$ts_state" = "Running" ]; then
        tailscale down && notify-send "VPN" "Disconnected Tailscale" --icon=network-vpn-disconnected
    else
        tailscale up --accept-routes && notify-send "VPN" "Connected Tailscale" --icon=network-vpn
    fi
else
    state=$(nmcli -t -f GENERAL.STATE connection show "$conn" 2>/dev/null | cut -d: -f2)
    if [ "$state" = "activated" ]; then
        nmcli connection down "$conn"
        notify-send "VPN" "Disconnected from $conn" --icon=network-vpn-disconnected
    else
        nmcli connection up "$conn"
        notify-send "VPN" "Connected to $conn" --icon=network-vpn
    fi
fi
