#!/usr/bin/env bash
# Claude Code status line: hostname, current directory, git branch, and context usage.
# Receives session context as JSON on stdin.

input=$(cat)
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$dir" ] && dir="$PWD"

host=$(hostname -s 2>/dev/null || hostname)

# Abbreviate $HOME to ~ for the displayed path.
short_dir="${dir/#$HOME/\~}"

branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)

ctx_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
ctx_used=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_size=$(printf '%s' "$input" | jq -r '.context_window.context_window_size // empty')

# Render a token count in k, e.g. 128000 -> 128k.
fmt_tokens() { awk -v n="$1" 'BEGIN { printf "%dk", n / 1000 }'; }

# ANSI: dim host, bold dir, green branch.
out="\033[2m${host}\033[0m \033[1m${short_dir}\033[0m"
[ -n "$branch" ] && out="${out} \033[32m(${branch})\033[0m"

if [ -n "$ctx_pct" ]; then
    ctx_int=${ctx_pct%.*}
    # Green under 50%, yellow under 80%, red above — flags when a compaction is close.
    if [ "$ctx_int" -ge 80 ]; then
        ctx_color="\033[31m"
    elif [ "$ctx_int" -ge 50 ]; then
        ctx_color="\033[33m"
    else
        ctx_color="\033[32m"
    fi
    ctx_label="${ctx_int}%"
    if [ -n "$ctx_used" ] && [ -n "$ctx_size" ]; then
        ctx_label="${ctx_label} ($(fmt_tokens "$ctx_used")/$(fmt_tokens "$ctx_size"))"
    fi
    out="${out} ${ctx_color}${ctx_label}\033[0m"
fi

printf '%b' "$out"
