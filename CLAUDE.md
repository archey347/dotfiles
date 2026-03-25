# Chezmoi Dotfiles Repo

This is a chezmoi-managed dotfiles repository. Source files here are applied
to the home directory via `chezmoi apply`. The `dot_` prefix maps to `.` and
`private_` sets file permissions.

## Waybar Design Iteration

To iterate on the Waybar design, follow the workflow documented in
[.cursor/skills/iterate-waybar-design/SKILL.md](.cursor/skills/iterate-waybar-design/SKILL.md).

Summary: edit files in `dot_config/waybar/`, run `chezmoi apply`, restart
with `pkill waybar && waybar &`, then screenshot with `grim` to review.
