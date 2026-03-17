# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Install

```sh
chezmoi init --apply https://github.com/archeybarrell/dotfiles
```

## Usage

| Command | Description |
|---|---|
| `chezmoi apply` | Apply dotfiles to the system |
| `chezmoi add <file>` | Track a new file |
| `chezmoi edit <file>` | Edit a tracked file |
| `chezmoi diff` | Preview pending changes |

Changes are automatically committed and pushed to GitHub on `chezmoi apply`.

## Configuration

Machine-specific settings live in `~/.config/chezmoi/chezmoi.toml`:

| Key | Description |
|---|---|
| `is_hyprland` | Enable Hyprland packages and config |
| `lock_timeout` | Inactivity timeout before screen locks (seconds) |
| `monitors` | Monitor layout (pipe-separated Hyprland monitor strings) |
| `kb_layout` | Keyboard layout |
| `aq_drm_devices` | DRM device order for GPU selection |
| `libva_driver_name` | VA-API driver name |
