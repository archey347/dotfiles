#!/usr/bin/env bash
# Override the global pushRemote = no_push rule for the chezmoi source repo
# so that chezmoi autoPush works without hitting the no_push guard on main/master
git -C "$CHEZMOI_SOURCE_DIR" config branch.main.pushRemote origin

# Use HTTPS for fetch (no SSH key needed) and SSH for push
REPO=$(git -C "$CHEZMOI_SOURCE_DIR" remote get-url origin | sed 's|git@github.com:|https://github.com/|')
git -C "$CHEZMOI_SOURCE_DIR" remote set-url origin "$REPO"
git -C "$CHEZMOI_SOURCE_DIR" remote set-url --push origin "$(git -C "$CHEZMOI_SOURCE_DIR" remote get-url origin | sed 's|https://github.com/|git@github.com:|')"
