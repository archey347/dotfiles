#!/bin/bash
# One glyph per connected physical link. Replaces waybar's network module, which
# mistakes routes on libvirt bridges for default routes and reports "Disconnected".
ICON_ETHERNET=$''  # fa-ethernet
ICON_WIFI=$''      # fa-wifi
ICON_MOBILE=$''    # fa-mobile-screen

# NM types ethernet/wifi/gsm already exclude bridges; this also catches taps and
# veths that NM sometimes manages as plain ethernet.
SKIP_RE='^(virbr|vnet|veth|docker|br-|podman|tap|tun|lxc|vboxnet|vmnet)'

# Main table only — policy tables (e.g. WireGuard's) don't say which link is up front.
primary=$(ip -4 route show default table main 2>/dev/null \
    | awk '{for (i=1;i<NF;i++) if ($i=="metric") m=$(i+1); if (m=="") m=0;
            for (i=1;i<NF;i++) if ($i=="dev") print m, $(i+1); m=""}' \
    | sort -n | awk 'NR==1{print $2}')

icons=()
tooltip_lines=()

while IFS=: read -r dev type state conn; do
    [ "$state" = "connected" ] || continue
    [[ "$dev" =~ $SKIP_RE ]] && continue
    case "$type" in
        ethernet) icon=$ICON_ETHERNET ;;
        wifi)     icon=$ICON_WIFI ;;
        gsm)      icon=$ICON_MOBILE ;;
        *)        continue ;;
    esac

    addr=$(ip -4 -br addr show dev "$dev" 2>/dev/null | awk '{print $3}')
    detail="$conn"
    if [ "$type" = "wifi" ]; then
        signal=$(nmcli -t -f IN-USE,SIGNAL dev wifi list ifname "$dev" --rescan no 2>/dev/null \
            | awk -F: '$1=="*"{print $2}')
        [ -n "$signal" ] && detail="$conn  ${signal}%"
    fi

    if [ "$dev" = "$primary" ]; then
        icons+=("$icon")
        tooltip_lines+=("$icon  $dev  ${addr:-no IP}  $detail  (default route)")
    else
        icons+=("<span fgalpha='40%'>$icon</span>")
        tooltip_lines+=("$icon  $dev  ${addr:-no IP}  $detail")
    fi
done < <(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device 2>/dev/null)

if [ ${#icons[@]} -eq 0 ]; then
    printf '{"text":"Offline","tooltip":"No connected network links","class":"disconnected"}\n'
    exit 0
fi

text=$(IFS=' '; echo "${icons[*]}")
tooltip=$(printf '%s\n' "${tooltip_lines[@]}" | head -c -1)
tooltip="${tooltip//&/&amp;}"
tooltip="${tooltip//$'\n'/\\n}"
tooltip="${tooltip//\"/\\\"}"
printf '{"text":"%s","tooltip":"%s","class":"connected"}\n' "$text" "$tooltip"
