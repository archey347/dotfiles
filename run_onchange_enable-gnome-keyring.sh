#!/usr/bin/env bash
# Enable the gnome-keyring-daemon user socket so PAM's auto_start finds an
# existing control socket at $XDG_RUNTIME_DIR/keyring/control on login and
# hands off the password to a socket-activated daemon. Without this, on
# non-GNOME compositors (e.g. Hyprland) the XDG autostart entries are
# filtered out by OnlyShowIn= and the login keyring never gets unlocked.
set -euo pipefail

if ! command -v systemctl >/dev/null; then
    exit 0
fi

if [ ! -f /usr/lib/systemd/user/gnome-keyring-daemon.socket ] \
    && [ ! -f /lib/systemd/user/gnome-keyring-daemon.socket ]; then
    exit 0
fi

systemctl --user enable --now gnome-keyring-daemon.socket
