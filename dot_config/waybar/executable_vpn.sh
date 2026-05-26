#!/bin/bash
ICON_ON=$''   # fa-lock
ICON_OFF=$''  # fa-lock-open

active_names=()
tooltip_lines=()
any_provider=0

# WireGuard via NetworkManager
if command -v nmcli >/dev/null 2>&1; then
    connections=$(nmcli -t -f NAME,TYPE connection show 2>/dev/null | awk -F: '$2=="wireguard"{print $1}')
    if [ -n "$connections" ]; then
        any_provider=1
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
    fi
fi

# Tailscale
if command -v tailscale >/dev/null 2>&1; then
    any_provider=1
    ts_state=$(tailscale status --json 2>/dev/null | sed -n 's/.*"BackendState": *"\([^"]*\)".*/\1/p' | head -n1)
    if [ "$ts_state" = "Running" ]; then
        ts_ip=$(tailscale ip -4 2>/dev/null | head -n1)
        active_names+=("Tailscale")
        tooltip_lines+=("$ICON_ON Tailscale  ${ts_ip:-up}")
    else
        tooltip_lines+=("$ICON_OFF Tailscale")
    fi
fi

if [ "$any_provider" = "0" ]; then
    # Neither WireGuard nor Tailscale available — emit nothing so waybar hides the module
    printf '{"text":"","tooltip":""}\n'
    exit 0
fi

tooltip=$(printf '%s\n' "${tooltip_lines[@]}" | head -c -1)  # trim trailing newline
tooltip="${tooltip//$'\n'/\\n}"

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
