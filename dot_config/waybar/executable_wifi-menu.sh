#!/usr/bin/env bash
# WiFi menu using wofi + nmcli

# Signal strength to icon
signal_icon() {
    local sig=$1
    if   [ "$sig" -ge 80 ]; then echo "▂▄▆█"
    elif [ "$sig" -ge 60 ]; then echo "▂▄▆░"
    elif [ "$sig" -ge 40 ]; then echo "▂▄░░"
    elif [ "$sig" -ge 20 ]; then echo "▂░░░"
    else                         echo "░░░░"
    fi
}

# Get current connection
current=$(nmcli -t -f active,ssid dev wifi | awk -F: '/^yes/{print $2}')

# Scan (refresh list)
nmcli dev wifi rescan 2>/dev/null

# Build list: deduplicate by SSID, show signal + lock icon
entries=$(nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi list \
    | awk -F: '!seen[$1]++ && $1!=""' \
    | while IFS=: read -r ssid signal security inuse; do
        icon=$(signal_icon "$signal")
        lock=$([[ "$security" != "--" ]] && echo " [P]" || echo "")
        active=$([[ "$inuse" == "*" ]] && echo " ✓" || echo "")
        printf "%s %s%s%s\n" "$icon" "$ssid" "$lock" "$active"
    done)

# Add disconnect option if connected
if [ -n "$current" ]; then
    entries="[X] Disconnect from $current\n$entries"
fi

# Show wofi menu
chosen=$(printf "%b" "$entries" | wofi --dmenu --prompt "WiFi" --width 400 --height 300 --cache-file /dev/null)
[ -z "$chosen" ] && exit 0

# Handle disconnect
if [[ "$chosen" == *"Disconnect from"* ]]; then
    nmcli dev disconnect "$(nmcli -t -f DEVICE,TYPE dev | awk -F: '/wireless/{print $1}' | head -1)"
    notify-send "WiFi" "Disconnected" --icon=network-wireless-offline
    exit 0
fi

# Extract SSID (strip icon prefix and trailing markers)
ssid=$(echo "$chosen" | sed 's/^[^ ]* //' | sed 's/ \[P\]//' | sed 's/ ✓//')

# If already connected to this, do nothing
if [ "$ssid" = "$current" ]; then
    notify-send "WiFi" "Already connected to $ssid" --icon=network-wireless
    exit 0
fi

# Try to connect (saved profile first)
if nmcli con up id "$ssid" 2>/dev/null; then
    notify-send "WiFi" "Connected to $ssid" --icon=network-wireless
    exit 0
fi

# Need password?
security=$(nmcli -t -f SSID,SECURITY dev wifi list | awk -F: -v s="$ssid" '$1==s{print $2; exit}')
if [[ "$security" != "--" && "$security" != "" ]]; then
    password=$(wofi --dmenu --prompt "Password for $ssid" --width 400 --height 80 --password --cache-file /dev/null)
    [ -z "$password" ] && exit 0
    if nmcli dev wifi connect "$ssid" password "$password" 2>/dev/null; then
        notify-send "WiFi" "Connected to $ssid" --icon=network-wireless
    else
        notify-send "WiFi" "Failed to connect to $ssid" --icon=network-wireless-offline
    fi
else
    if nmcli dev wifi connect "$ssid" 2>/dev/null; then
        notify-send "WiFi" "Connected to $ssid" --icon=network-wireless
    else
        notify-send "WiFi" "Failed to connect to $ssid" --icon=network-wireless-offline
    fi
fi
