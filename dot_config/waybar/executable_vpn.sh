#!/bin/bash
ICON_ON=$'\uf023'   # fa-lock
ICON_OFF=$'\uf3c1'  # fa-lock-open

# All WireGuard connections
connections=$(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="wireguard"{print $1}')

active_names=()
tooltip_lines=()

while IFS= read -r conn; do
    [ -z "$conn" ] && continue
    iface=$(nmcli -t -f connection.interface-name connection show "$conn" 2>/dev/null | cut -d: -f2)
    state=$(nmcli -t -f GENERAL.STATE connection show "$conn" 2>/dev/null | cut -d: -f2)

    if [ "$state" = "activated" ]; then
        rx=$(ip -s link show "$iface" 2>/dev/null | awk '/RX:/{getline; print $2}')
        tx=$(ip -s link show "$iface" 2>/dev/null | awk '/TX:/{getline; print $2}')
        active_names+=("$conn")
        tooltip_lines+=("$ICON_ON $conn  ↓ ${rx:-0} pkts  ↑ ${tx:-0} pkts")
    else
        tooltip_lines+=("$ICON_OFF $conn")
    fi
done <<< "$connections"

tooltip=$(printf '%s\n' "${tooltip_lines[@]}")

if [ ${#active_names[@]} -eq 0 ]; then
    printf '{"text":"%s VPN","tooltip":"%s","class":"disconnected"}\n' \
        "$ICON_OFF" "$tooltip"
elif [ ${#active_names[@]} -eq 1 ]; then
    printf '{"text":"%s %s","tooltip":"%s","class":"connected"}\n' \
        "$ICON_ON" "${active_names[0]}" "$tooltip"
else
    printf '{"text":"%s %d active","tooltip":"%s","class":"connected"}\n' \
        "$ICON_ON" "${#active_names[@]}" "$tooltip"
fi
