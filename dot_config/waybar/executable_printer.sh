#!/bin/bash
ICON=$''  # fa-print

# Job IDs are "<printer>-<n>", and printer names can't contain spaces.
mapfile -t printers < <(lpstat -o 2>/dev/null | awk '{sub(/-[0-9]+$/, "", $1); print $1}' | sort -u)
if [ ${#printers[@]} -eq 0 ]; then
    printf '{"text":""}\n'
    exit 0
fi

class=printing
total=0
lines=()
for printer in "${printers[@]}"; do
    # A disabled queue holds jobs forever, which is the case worth noticing.
    if lpstat -p "$printer" 2>/dev/null | grep -q disabled; then
        class=stopped
        lines+=("$printer (stopped)")
    else
        lines+=("$printer")
    fi
    # lpq's columns are fixed width, which is the only safe way to split titles containing spaces.
    while IFS= read -r job; do
        title=$(sed 's/ *$//' <<< "${job:24:31}")
        [[ $job == active* ]] && title="$title (printing)"
        lines+=("  ${title:-untitled}")
        total=$((total + 1))
    done < <(lpq -P "$printer" 2>/dev/null | tail -n +3)
done

jq -cn --arg text "$ICON $total" --arg tooltip "$(printf '%s\n' "${lines[@]}")" --arg class "$class" \
    '{text: $text, tooltip: ($tooltip | gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub(">"; "&gt;")), class: $class}'
