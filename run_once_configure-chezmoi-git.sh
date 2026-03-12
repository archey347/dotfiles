#!/usr/bin/env bash
# Override the global pushRemote = no_push rule for the chezmoi source repo
# so that chezmoi autoPush works without hitting the no_push guard on main/master
git -C "$(chezmoi source-path)" config branch.main.pushRemote origin
