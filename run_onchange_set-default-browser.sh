#!/usr/bin/env bash
# Point http(s) at the workspace-aware handler rather than at Firefox directly,
# so a clicked link opens in the Firefox window on the workspace you are on.
set -euo pipefail

if ! command -v xdg-mime >/dev/null; then
    exit 0
fi

for mime in x-scheme-handler/http x-scheme-handler/https text/html application/xhtml+xml; do
    xdg-mime default firefox-workspace.desktop "$mime"
done

if command -v update-desktop-database >/dev/null; then
    update-desktop-database "${HOME}/.local/share/applications"
fi
