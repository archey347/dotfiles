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
| `1984` | Record which desktop has focus, for workday metrics (default off, see below) |
| `monitors` | Monitor layout (pipe-separated Hyprland monitor strings) |
| `kb_layout` | Keyboard layout |
| `aq_drm_devices` | DRM device order for GPU selection |
| `libva_driver_name` | VA-API driver name |

## Workday metrics (`1984`)

`bin/hyprfocusd` records which Hyprland workspace has focus and what is running on each
one, so a day can be reconstructed afterwards: with one task per workspace, the workspace
is the task label, and a terminal's title names whatever session ran in it. Data lands in
`~/.local/state/hyprfocus/<date>.jsonl`, one file per local day, never managed or uploaded.

Off by default. Setting `1984 = true` in `chezmoi.toml` enables the `hyprfocusd` user
service and adds a hypridle listener that marks idle and resume, so time away from the
desk is not credited to whichever window kept focus. Screen locks are picked up from the
compositor directly. Window titles are logged; run the daemon with `--no-titles` to keep
only workspace and app.
