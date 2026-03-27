#!/bin/bash
ICON_ON=$'\uf023'   # fa-lock
ICON_OFF=$'\uf3c1'  # fa-lock-open

# Build menu entries from all WireGuard connections
entries=""
while IFS= read -r conn; do
    [ -z "$conn" ] && continue
    state=$(nmcli -t -f GENERAL.STATE connection show "$conn" 2>/dev/null | cut -d: -f2)
    if [ "$state" = "activated" ]; then
        entries+="$ICON_ON $conn\n"
    else
        entries+="$ICON_OFF $conn\n"
    fi
done <<< "$(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="wireguard"{print $1}')"

[ -z "$entries" ] && notify-send "VPN" "No WireGuard profiles configured" && exit 0

chosen=$(printf "%b" "$entries" | wofi --dmenu --prompt "VPN" --width 350 --height 200 --cache-file /dev/null)
[ -z "$chosen" ] && exit 0

# Strip icon prefix to get connection name
conn=$(echo "$chosen" | sed 's/^[^ ]* //')
state=$(nmcli -t -f GENERAL.STATE connection show "$conn" 2>/dev/null | cut -d: -f2)

if [ "$state" = "activated" ]; then
    nmcli connection down "$conn"
    notify-send "VPN" "Disconnected from $conn" --icon=network-vpn-disconnected
else
    nmcli connection up "$conn"
    notify-send "VPN" "Connected to $conn" --icon=network-vpn
fi
