#!/bin/bash
# Font Awesome Bluetooth button; replaces blueman's full-colour tray icon.
ICON=$''  # fa-bluetooth-b

if ! bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    printf '{"text":"%s","tooltip":"Bluetooth off","class":"off"}\n' "$ICON"
    exit 0
fi

mapfile -t names < <(bluetoothctl devices Connected 2>/dev/null | cut -d' ' -f3-)
if [ ${#names[@]} -eq 0 ]; then
    printf '{"text":"%s","tooltip":"Bluetooth on, nothing connected","class":"on"}\n' "$ICON"
else
    tooltip=$(printf '%s\\n' "${names[@]}")
    printf '{"text":"%s","tooltip":"%s","class":"connected"}\n' "$ICON" "${tooltip%\\n}"
fi
