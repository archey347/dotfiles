#!/usr/bin/env bash
# Claude Code status line: hostname, current directory, and git branch.
# Receives session context as JSON on stdin.

input=$(cat)
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$dir" ] && dir="$PWD"

host=$(hostname -s 2>/dev/null || hostname)

# Abbreviate $HOME to ~ for the displayed path.
short_dir="${dir/#$HOME/\~}"

branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)

# ANSI: dim host, bold dir, green branch.
out="\033[2m${host}\033[0m \033[1m${short_dir}\033[0m"
[ -n "$branch" ] && out="${out} \033[32m(${branch})\033[0m"

printf '%b' "$out"
