#!/usr/bin/env bash
# Interactive editor for the monitor layout profiles monitor-setup.sh applies.
# The profiles live in ~/.config/chezmoi/chezmoi.toml — machine-local, and
# deliberately outside the dotfiles repo — so this edits that file in place, then
# re-bakes monitor-setup.sh and re-applies the layout.
#
# Usage:
#   monitor-profile          # whiptail UI for the connected screens
#   monitor-profile --show   # print the arrangement it would save, then exit
#
# Offsets are always recomputed from the left-to-right order, so loading a
# profile with hand-tweaked y offsets normalises them to top/centre/bottom.

set -uo pipefail

CHEZMOI_CFG="${HOME}/.config/chezmoi/chezmoi.toml"
MONITOR_SETUP="${HOME}/.config/hypr/monitor-setup.sh"
MONITOR_SETUP_SRC="${HOME}/.config/hypr/monitor-setup.sh"

TITLE="Monitor layout"

# newt's stock palette is red-on-blue; ANSI names instead so the box picks up
# whichever ghostty theme is in effect.
export NEWT_COLORS='
root=,black
window=,black
shadow=,black
border=cyan,black
title=cyan,black
textbox=lightgray,black
button=black,cyan
actbutton=black,white
listbox=lightgray,black
actlistbox=black,cyan
sellistbox=lightgray,black
actsellistbox=black,cyan
'

declare -a DESC=() NAME=() MW=() MH=() HZ=() SCALE=() XFORM=() ORDER=() LY=() WS=()
declare -a PX=() PY=()
VALIGN=centre
FOCUS=0
LOADED=false

die() {
    if [[ -t 2 ]]; then
        echo "monitor-profile: $*" >&2
    else
        whiptail --title "$TITLE" --msgbox "$*" 10 70 2>/dev/null \
            || echo "monitor-profile: $*" >&2
    fi
    exit 1
}

require() {
    local c
    for c in hyprctl jq python3 whiptail; do
        command -v "$c" >/dev/null || die "$c is not installed"
    done
    [[ -f "$CHEZMOI_CFG" ]] || die "no chezmoi config at $CHEZMOI_CFG"
}

# --- chezmoi.toml access -----------------------------------------------------

# get                -> one profile per line
# set <profile>      -> replace the profile matching its descriptor set, else append
# del <profile>      -> drop the profile matching that descriptor set
toml() {
    python3 - "$@" <<'PY'
import json, pathlib, re, sys, tomllib

action = sys.argv[1]
path = pathlib.Path.home() / ".config/chezmoi/chezmoi.toml"
text = path.read_text()

m = re.search(r'^([ \t]*monitor_profiles[ \t]*=[ \t]*)(\[.*\])[ \t]*$', text, re.M)
if not m:
    if action == "get":
        sys.exit(0)
    sys.exit("no monitor_profiles array in chezmoi.toml")

profiles = tomllib.loads("v = " + m.group(2))["v"] if m else []

def descs(profile):
    out = set()
    for rule in profile.split("|"):
        rule = rule.removeprefix("focus:")
        if rule.startswith("desc:"):
            out.add(rule[len("desc:"):].split(",")[0])
    return frozenset(out)

if action == "get":
    print("\n".join(profiles))
    sys.exit(0)

new = sys.argv[2]
target = descs(new)
kept, verb = [], "added"
for p in profiles:
    if descs(p) == target:
        if action == "set":
            kept.append(new)
            verb = "replaced"
        else:
            verb = "deleted"
        continue
    kept.append(p)
if action == "set" and verb == "added":
    kept.append(new)

array = "[" + ",".join(json.dumps(p) for p in kept) + "]"
pathlib.Path(str(path) + ".bak").write_text(text)
path.write_text(text[:m.start(2)] + array + text[m.end(2):])
print(verb)
PY
}

# --- model -------------------------------------------------------------------

load_monitors() {
    local json name desc w h hz scale xform focused ws i=0
    json=$(hyprctl monitors all -j 2>/dev/null) || die "hyprctl failed — is Hyprland running?"
    [[ -n "$json" && "$json" != "[]" ]] || die "hyprctl reported no monitors"

    while IFS=$'\t' read -r name desc w h hz scale xform focused ws; do
        DESC+=("$desc"); NAME+=("$name")
        MW+=("$w"); MH+=("$h"); HZ+=("$hz")
        SCALE+=("$scale"); XFORM+=("$xform")
        WS+=("$ws")
        ORDER+=("$i")
        [[ "$focused" == true ]] && FOCUS=$i
        i=$(( i + 1 ))
    done < <(printf '%s' "$json" | jq -r '
        sort_by(.x) | .[] |
        (if (.width // 0) > 0 then {w: .width, h: .height, hz: (.refreshRate // 60)}
         else ((.availableModes[0] // "1920x1080@60Hz")
               | capture("(?<w>\\d+)x(?<h>\\d+)@(?<hz>[0-9.]+)")
               | {w: (.w | tonumber), h: (.h | tonumber), hz: (.hz | tonumber)}) end) as $m
        | [ .name, .description, $m.w, $m.h, ($m.hz | round),
            (((.scale // 1) * 100 | round) / 100), (.transform // 0), (.focused // false),
            (.activeWorkspace.name // (.activeWorkspace.id | tostring) // "-") ]
        | @tsv')

    (( ${#DESC[@]} > 0 )) || die "could not read the connected monitors"
}

idx_of_desc() {
    local want=$1 i
    for i in "${!DESC[@]}"; do
        [[ "${DESC[$i]}" == "$want" ]] && { echo "$i"; return 0; }
    done
    for i in "${!DESC[@]}"; do
        [[ "${DESC[$i]}" == *"$want"* ]] && { echo "$i"; return 0; }
    done
    return 1
}

# Adopts the stored profile for exactly this set of screens, if there is one.
load_profile() {
    local profile rule connected
    connected=$(printf '%s\n' "${DESC[@]}" | sort)

    while IFS= read -r profile; do
        [[ -n "$profile" ]] || continue
        local -a rules=() got=()
        IFS='|' read -ra rules <<< "$profile"
        local d
        for rule in "${rules[@]}"; do
            rule="${rule#focus:}"
            [[ "$rule" == desc:* ]] || continue
            d="${rule#desc:}"
            got+=("${d%%,*}")
        done
        (( ${#got[@]} == ${#DESC[@]} )) || continue
        [[ "$(printf '%s\n' "${got[@]}" | sort)" == "$connected" ]] || continue

        # Matched. Re-read the rules for their modes, scales, transforms and order.
        local -a byx=()
        for rule in "${rules[@]}"; do
            local is_focus=false
            if [[ "$rule" == focus:* ]]; then is_focus=true; rule="${rule#focus:}"; fi
            [[ "$rule" == desc:* ]] || continue
            local -a f=()
            IFS=',' read -ra f <<< "${rule#desc:}"
            local i x y
            i=$(idx_of_desc "${f[0]}") || continue
            MW[$i]="${f[1]%%x*}"
            MH[$i]="$(echo "${f[1]#*x}" | cut -d@ -f1)"
            HZ[$i]="$(echo "${f[1]}" | cut -d@ -f2)"
            x="${f[2]%%x*}"; y="${f[2]#*x}"
            LY[$i]="$y"
            SCALE[$i]="${f[3]:-1}"
            XFORM[$i]=0
            [[ "${f[4]:-}" == transform ]] && XFORM[$i]="${f[5]:-0}"
            [[ "$is_focus" == true ]] && FOCUS=$i
            byx+=("$x:$i")
        done
        ORDER=()
        local pair
        while IFS= read -r pair; do ORDER+=("${pair#*:}"); done \
            < <(printf '%s\n' "${byx[@]}" | sort -t: -k1,1n)
        LOADED=true
        detect_valign
        return 0
    done < <(toml get)
    return 1
}

# Which of the three alignments the loaded profile's y offsets correspond to.
detect_valign() {
    local a
    for a in centre top bottom; do
        VALIGN=$a
        compute_positions
        local i ok=true
        for i in "${!DESC[@]}"; do
            [[ "${LY[$i]:-}" == "${PY[$i]}" ]] || { ok=false; break; }
        done
        [[ "$ok" == true ]] && return 0
    done
    VALIGN=centre
}

eff_w() {
    local i=$1 d=${MW[$1]}
    (( XFORM[i] == 1 || XFORM[i] == 3 )) && d=${MH[$1]}
    awk -v d="$d" -v s="${SCALE[$1]}" 'BEGIN { printf "%d", int(d / s + 0.5) }'
}

eff_h() {
    local i=$1 d=${MH[$1]}
    (( XFORM[i] == 1 || XFORM[i] == 3 )) && d=${MW[$1]}
    awk -v d="$d" -v s="${SCALE[$1]}" 'BEGIN { printf "%d", int(d / s + 0.5) }'
}

compute_positions() {
    local i x=0 maxh=0 ew eh
    PX=(); PY=()
    for i in "${ORDER[@]}"; do
        eh=$(eff_h "$i")
        (( eh > maxh )) && maxh=$eh
    done
    for i in "${ORDER[@]}"; do
        ew=$(eff_w "$i"); eh=$(eff_h "$i")
        PX[$i]=$x
        case "$VALIGN" in
            top)    PY[$i]=0 ;;
            bottom) PY[$i]=$(( maxh - eh )) ;;
            *)      PY[$i]=$(( (maxh - eh) / 2 )) ;;
        esac
        x=$(( x + ew ))
    done
}

rule_for() {
    local i=$1 out=""
    [[ "$FOCUS" == "$i" ]] && out="focus:"
    out+="desc:${DESC[$i]},${MW[$i]}x${MH[$i]}@${HZ[$i]},${PX[$i]}x${PY[$i]},${SCALE[$i]}"
    (( XFORM[i] != 0 )) && out+=",transform,${XFORM[$i]}"
    printf '%s' "$out"
}

profile_string() {
    compute_positions
    local i out=""
    for i in "${ORDER[@]}"; do
        [[ -n "$out" ]] && out+="|"
        out+="$(rule_for "$i")"
    done
    printf '%s' "$out"
}

# --- presentation ------------------------------------------------------------

# Scaled plan view of the layout, so the left-to-right order and the vertical
# alignment can be eyeballed before anything is applied.
diagram() {
    compute_positions
    local i tw=0 th=0 v
    for i in "${ORDER[@]}"; do
        v=$(( PX[i] + $(eff_w "$i") )); (( v > tw )) && tw=$v
        v=$(( PY[i] + $(eff_h "$i") )); (( v > th )) && th=$v
    done
    local i
    for i in "${ORDER[@]}"; do
        printf '%s\t%s\t%s\t%s\t%s\t%s\tworkspace %s\n' "${NAME[$i]}" "${PX[$i]}" "${PY[$i]}" \
            "$(eff_w "$i")" "$(eff_h "$i")" "$( [[ "$FOCUS" == "$i" ]] && echo '*' )" "${WS[$i]:--}"
    done | awk -F'\t' -v tw="$tw" -v th="$th" -v cols="${1:-58}" -v rows="${2:-8}" '
        function put(r, c, ch) { if (r >= 0 && r < rows && c >= 0 && c < cols) g[r, c] = ch }
        function draw(r, c0, c1, text,   start, n) {
            if (length(text) > c1 - c0 - 1) text = substr(text, 1, c1 - c0 - 1)
            start = c0 + 1 + int((c1 - c0 - 1 - length(text)) / 2)
            if (start <= c0) start = c0 + 1
            for (n = 1; n <= length(text) && start + n - 1 < c1; n++)
                put(r, start + n - 1, substr(text, n, 1))
        }
        BEGIN { for (r = 0; r < rows; r++) for (c = 0; c < cols; c++) g[r, c] = " " }
        {
            c0 = int($2 / tw * cols + 0.5); c1 = int(($2 + $4) / tw * cols + 0.5) - 1
            r0 = int($3 / th * rows + 0.5); r1 = int(($3 + $5) / th * rows + 0.5) - 1
            if (c1 <= c0 + 1) c1 = c0 + 2
            if (r1 <= r0)     r1 = r0 + 1
            if (c1 >= cols) c1 = cols - 1
            if (r1 >= rows) r1 = rows - 1
            for (c = c0 + 1; c < c1; c++) { put(r0, c, "─"); put(r1, c, "─") }
            for (r = r0 + 1; r < r1; r++) { put(r, c0, "│"); put(r, c1, "│") }
            put(r0, c0, "┌"); put(r0, c1, "┐"); put(r1, c0, "└"); put(r1, c1, "┘")
            # Name, then the workspace it is currently showing on the row under
            # it — that is what makes a box findable on the desk. Centred as a
            # block so a two-line label does not sit high in the box.
            inner = r1 - r0 - 1
            lines = (inner >= 2 ? 2 : 1)
            start = r0 + 1 + int((inner - lines) / 2)
            if (inner >= 1) {
                draw(start, c0, c1, $1 $6)
                if (lines == 2) draw(start + 1, c0, c1, $7)
            }
        }
        END {
            for (r = 0; r < rows; r++) {
                line = ""
                for (c = 0; c < cols; c++) line = line g[r, c]
                sub(/ +$/, "", line)
                print line
            }
        }'
}

# Model and serial — the vendor prefix is noise, and the output name is already
# in the column beside it.
short_desc() {
    local -a f=()
    read -ra f <<< "$1"
    if (( ${#f[@]} >= 2 )); then
        printf '%s %s' "${f[-2]}" "${f[-1]}"
    else
        printf '%s' "$1"
    fi
}

table() {
    compute_positions
    local i n=0 mark
    for i in "${ORDER[@]}"; do
        n=$(( n + 1 ))
        mark=""
        [[ "$FOCUS" == "$i" ]] && mark="   <- focus"
        printf '%d. %-6s %-5s %-17s %13s %11s%s%s\n' \
            "$n" "${NAME[$i]}" "ws${WS[$i]:--}" "$(short_desc "${DESC[$i]}")" \
            "${MW[$i]}x${MH[$i]}@${HZ[$i]}" "${PX[$i]}x${PY[$i]}" \
            "$( (( XFORM[i] != 0 )) && printf ' rot%s' "$(( XFORM[i] * 90 ))" )" "$mark"
    done
}

# A short terminal has to give the diagram back its rows or whiptail clips the
# table off the bottom of the box.
diagram_rows() {
    (( $(tput lines 2>/dev/null || echo 24) >= 34 )) && { echo 8; return; }
    echo 5
}

summary() {
    local cols=${1:-58} rows=${2:-$(diagram_rows)}
    diagram "$cols" "$rows"
    echo
    table
}

# --- whiptail helpers --------------------------------------------------------

# whiptail dies if the box is taller than the terminal, and this can be started
# from a launcher into whatever size the terminal opens at.
box_height() { local want=$1 max=$(( $(tput lines 2>/dev/null || echo 24) - 1 )); (( want > max )) && want=$max; echo "$want"; }
box_width()  { local want=$1 max=$(( $(tput cols 2>/dev/null || echo 80) - 2 )); (( want > max )) && want=$max; echo "$want"; }

# The workspace comes before the description: on a desk of identical panels it
# is the only part of the row you can match to a screen by looking up.
menu_label() {
    printf 'workspace %-4s %-8s %s' "${WS[$1]:--}" "${NAME[$1]}" "${DESC[$1]}"
}

pick_monitor() {
    local prompt=$1 i
    local -a items=()
    for i in "${ORDER[@]}"; do
        items+=("$i" "$(menu_label "$i")")
    done
    whiptail --title "$TITLE" --notags --menu "$prompt" \
        "$(box_height 16)" "$(box_width 74)" "${#items[@]}" "${items[@]}" 3>&1 1>&2 2>&3
}

edit_order() {
    local -a remaining=("${ORDER[@]}") new=() items=()
    local n=1 pick i
    while (( ${#remaining[@]} > 1 )); do
        items=()
        for i in "${remaining[@]}"; do
            items+=("$i" "$(menu_label "$i")")
        done
        pick=$(whiptail --title "$TITLE" --notags --menu \
            "Which screen is #${n} from the left?" \
            "$(box_height 16)" "$(box_width 74)" "${#items[@]}" "${items[@]}" 3>&1 1>&2 2>&3) || return 1
        new+=("$pick")
        local -a rest=()
        for i in "${remaining[@]}"; do
            [[ "$i" == "$pick" ]] || rest+=("$i")
        done
        remaining=("${rest[@]}")
        n=$(( n + 1 ))
    done
    new+=("${remaining[0]}")
    ORDER=("${new[@]}")
}

edit_valign() {
    local pick
    pick=$(whiptail --title "$TITLE" --notags --menu \
        "Vertical alignment of screens of different heights:" \
        "$(box_height 14)" "$(box_width 62)" 3 \
        centre "Centre (tops and bottoms both offset)" \
        top    "Tops level" \
        bottom "Bottoms level" 3>&1 1>&2 2>&3) || return 1
    VALIGN=$pick
}

edit_focus() {
    local pick
    pick=$(pick_monitor "Which screen should focus mode collapse onto by default?\n\n(~/bin/focus keeps whichever screen you are on, so this is only the fallback.)") || return 1
    FOCUS=$pick
}

edit_mode() {
    local i pick
    i=$(pick_monitor "Change the resolution of which screen?") || return 1
    local -a items=()
    local mode
    while IFS= read -r mode; do
        items+=("$mode" "$mode")
    done < <(hyprctl monitors all -j | jq -r --arg n "${NAME[$i]}" '
        .[] | select(.name == $n) | .availableModes[]
        | capture("(?<w>\\d+)x(?<h>\\d+)@(?<hz>[0-9.]+)")
        | "\(.w)x\(.h)@\(.hz | tonumber | round)"' | awk '!seen[$0]++')
    (( ${#items[@]} > 0 )) || { whiptail --title "$TITLE" --msgbox "No modes reported for ${NAME[$i]}." 9 60; return 1; }
    pick=$(whiptail --title "$TITLE" --notags --menu "Mode for ${NAME[$i]}:" \
        "$(box_height 20)" "$(box_width 46)" "${#items[@]}" "${items[@]}" 3>&1 1>&2 2>&3) || return 1
    MW[$i]="${pick%%x*}"
    MH[$i]="$(echo "${pick#*x}" | cut -d@ -f1)"
    HZ[$i]="${pick#*@}"
}

edit_scale() {
    local i pick
    i=$(pick_monitor "Change the scale of which screen?") || return 1
    pick=$(whiptail --title "$TITLE" --notags --menu \
        "Scale for ${NAME[$i]} (currently ${SCALE[$i]}):" \
        "$(box_height 16)" "$(box_width 50)" 5 \
        1    "1 — no scaling" \
        1.25 "1.25" \
        1.5  "1.5" \
        1.75 "1.75" \
        2    "2 — HiDPI" 3>&1 1>&2 2>&3) || return 1
    SCALE[$i]=$pick
}

edit_transform() {
    local i pick
    i=$(pick_monitor "Rotate which screen?") || return 1
    pick=$(whiptail --title "$TITLE" --notags --menu \
        "Rotation for ${NAME[$i]}\n\nIf a portrait screen comes out upside down, pick the other 90.\n" \
        "$(box_height 16)" "$(box_width 56)" 4 \
        0 "Normal (landscape)" \
        1 "90 — portrait" \
        2 "180 — landscape, upside down" \
        3 "270 — portrait, the other way" 3>&1 1>&2 2>&3) || return 1
    XFORM[$i]=$pick
}

# --- save --------------------------------------------------------------------

# The watcher started by hyprland.conf's exec-once has the old profile list baked
# into its PROFILES array, so it has to be replaced or the next hotplug re-applies
# the layout this just edited away.
restart_watcher() {
    local pid kids
    # The watcher is a pipeline, so it shows up as more than one process; take
    # the children too or its socat is left dangling.
    for pid in $(pgrep -f 'monitor-setup\.sh$'); do
        kids=$(pgrep -P "$pid" 2>/dev/null)
        kill "$pid" 2>/dev/null
        [[ -n "$kids" ]] && kill $kids 2>/dev/null
    done
    # Spawned via Hyprland so it outlives this script (and this terminal), the
    # same as the exec-once that normally starts it.
    hyprctl dispatch exec "$MONITOR_SETUP" >/dev/null 2>&1
}

save_and_apply() {
    local profile verb
    profile=$(profile_string)

    verb=$(toml set "$profile") || { whiptail --title "$TITLE" --msgbox "Could not write $CHEZMOI_CFG" 9 70; return 1; }

    if ! chezmoi apply "$MONITOR_SETUP_SRC" >/dev/null 2>&1; then
        whiptail --title "$TITLE" --msgbox \
            "Wrote the profile ($verb) but 'chezmoi apply' failed.\n\nRun it by hand to bake it into monitor-setup.sh." 11 70
        return 1
    fi

    "$MONITOR_SETUP" --apply >/dev/null 2>&1
    restart_watcher

    whiptail --title "$TITLE" --msgbox \
        "Profile $verb and applied.\n\nPrevious chezmoi.toml saved as chezmoi.toml.bak." 10 66
}

delete_profile() {
    whiptail --title "$TITLE" --yesno \
        "Delete the stored profile for these screens?\n\nHyprland's fallback (preferred,auto,1) takes over until a new one is saved." \
        12 70 || return 1
    toml del "$(profile_string)" >/dev/null || return 1
    chezmoi apply "$MONITOR_SETUP_SRC" >/dev/null 2>&1
    restart_watcher
    whiptail --title "$TITLE" --msgbox "Profile deleted." 8 40
    exit 0
}

# --- main --------------------------------------------------------------------

require
load_monitors

if [[ "${1:-}" == "--show" ]]; then
    load_profile && echo "Stored profile for these screens (offsets normalised):" \
        || echo "No stored profile for these screens — showing the current arrangement:"
    echo
    summary 66 8
    echo
    echo "profile: $(profile_string)"
    exit 0
fi

load_profile || true

while true; do
    text=$'\n'"$(summary "$(( $(box_width 74) - 8 ))")"$'\n'
    if [[ "$LOADED" == true ]]; then
        text="Editing the stored profile for these ${#DESC[@]} screens.$text"
    else
        text="No stored profile matches these ${#DESC[@]} screens — this will add one.$text"
    fi

    # A short terminal scrolls the menu list rather than clipping the diagram
    # and table out of the box.
    list_height=8
    (( $(tput lines 2>/dev/null || echo 24) >= 34 )) || list_height=4

    choice=$(whiptail --title "$TITLE" --notags --menu "$text" \
        "$(box_height 32)" "$(box_width 78)" "$list_height" \
        save   "Save and apply" \
        order  "Left-to-right order" \
        valign "Vertical alignment  (${VALIGN})" \
        focus  "Focus-mode screen   (${NAME[$FOCUS]})" \
        mode   "Resolution / refresh rate" \
        scale  "Scale" \
        rotate "Rotation" \
        delete "Delete this profile" \
        3>&1 1>&2 2>&3) || exit 0

    case "$choice" in
        save)   save_and_apply && exit 0 ;;
        order)  edit_order ;;
        valign) edit_valign ;;
        focus)  edit_focus ;;
        mode)   edit_mode ;;
        scale)  edit_scale ;;
        rotate) edit_transform ;;
        delete) delete_profile ;;
    esac
done
