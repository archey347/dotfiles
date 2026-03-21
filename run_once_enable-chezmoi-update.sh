#!/usr/bin/env bash
# Enable and start the chezmoi-update systemd user service
systemctl --user daemon-reload
systemctl --user enable --now chezmoi-update.service
systemctl --user enable --now chezmoi-update.timer
