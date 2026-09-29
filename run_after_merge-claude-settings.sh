#!/usr/bin/env bash
# Rebuild ~/.claude/settings.json after every apply, since this repo's fragment
# is only one of the files it's merged from.
set -euo pipefail
exec "${HOME}/bin/claude-settings-merge"
