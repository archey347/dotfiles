#!/bin/bash
ICON=$''  # fa-print

# Job IDs are "<printer>-<n>", and printer names can't contain spaces.
mapfile -t jobs < <(lpstat -o 2>/dev/null | awk '{print $1}')
if [ ${#jobs[@]} -eq 0 ]; then
    printf '{"text":""}\n'
    exit 0
fi

class=printing
lines=()
for printer in $(printf '%s\n' "${jobs[@]}" | sed 's/-[0-9]*$//' | sort -u); do
    count=$(printf '%s\n' "${jobs[@]}" | grep -c "^$printer-[0-9]*$")
    # A disabled queue holds jobs forever, which is the case worth noticing.
    if lpstat -p "$printer" 2>/dev/null | grep -q disabled; then
        class=stopped
        lines+=("$printer: $count queued (stopped)")
    else
        lines+=("$printer: $count queued")
    fi
done

jq -cn --arg text "$ICON ${#jobs[@]}" --arg tooltip "$(printf '%s\n' "${lines[@]}")" \
    --arg class "$class" '{text: $text, tooltip: $tooltip, class: $class}'
