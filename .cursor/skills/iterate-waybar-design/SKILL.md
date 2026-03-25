---
name: iterate-waybar-design
description: >-
  Iterate on Waybar bar design by editing chezmoi-managed config and styles,
  applying changes, restarting Waybar, and taking screenshots to review the
  result. Use when the user asks to change, redesign, tweak, or improve their
  Waybar layout, style, theme, or modules.
---

# Iterate on Waybar Design

This repo is a chezmoi-managed dotfiles repo. Waybar configuration lives here
and is applied to `~/.config/waybar/` via chezmoi.

## Waybar Config Files

| Chezmoi source path | Target | Purpose |
|---|---|---|
| `dot_config/waybar/config.jsonc` | `~/.config/waybar/config.jsonc` | Module layout, ordering, and behavior |
| `dot_config/waybar/style.css` | `~/.config/waybar/style.css` | All visual styling (colors, fonts, spacing, shapes) |
| `dot_config/waybar/power_menu.xml` | `~/.config/waybar/power_menu.xml` | Power menu popup structure |
| `dot_config/waybar/executable_wifi-menu.sh` | `~/.config/waybar/wifi-menu.sh` | Wi-Fi menu script (on-click handler) |

## Iteration Workflow

Follow these steps in order every time you make a change:

### 1. Edit config files in this repo

Edit `dot_config/waybar/config.jsonc` (modules/layout) and/or
`dot_config/waybar/style.css` (visual design) as needed.

### 2. Preview the diff

```bash
chezmoi diff
```

Review the output to confirm only intended changes will be applied.

### 3. Apply changes

```bash
chezmoi apply
```

### 4. Restart Waybar

```bash
pkill waybar && waybar &
```

Run this in a backgrounded shell. Give it ~1 second to start before
taking a screenshot.

### 5. Screenshot and review

Use `grim` to capture the waybar region, then scale it up for review:

```bash
# Capture the waybar strip (top 50px) from a monitor
grim -g "XOFF,0 WIDTHx50" /tmp/waybar-review.png

# Scale it up so text is readable
magick /tmp/waybar-review.png -resize WIDTHx200! /tmp/waybar-scaled.png
```

Then read `/tmp/waybar-scaled.png` as an image to visually review it.

### 6. Iterate

If the result isn't right, go back to step 1 and adjust. Repeat until the
design looks correct.

## Monitor Layout

The system has three monitors. Waybar appears on all of them.

| Monitor | Resolution | Compositor offset | Notes |
|---|---|---|---|
| `eDP-1` | 1920x1200 | 0,120 | Laptop display |
| `DP-6` | 2560x1440 | 1920,0 | Dell P2421DC (left external) |
| `HDMI-A-1` | 2560x1440 | 4480,0 | Dell P2421DC (right external) |

To screenshot a specific monitor's waybar, use the X offset from the table:

```bash
# Right external (HDMI-A-1, usually focused)
grim -g "4480,0 2560x50" /tmp/waybar-review.png

# Left external (DP-6)
grim -g "1920,0 2560x50" /tmp/waybar-review.png

# Laptop (eDP-1)
grim -g "0,120 1920x50" /tmp/waybar-review.png
```

## Tips

- Waybar uses GTK3 CSS, not standard web CSS. Some properties differ
  (e.g., `border-radius`, `min-height`, `padding` work; flexbox does not).
- `config.jsonc` supports JSONC (comments allowed).
- The bar currently uses a floating style with `margin-top/bottom/left/right`
  and `border-radius: 14px` for rounded corners.
- Font stack: `'SF Pro Display', 'Inter', 'Cantarell', 'Noto Sans', sans-serif`.
- Module icons use Font Awesome / Nerd Font glyphs.
- The `chezmoi apply` step is mandatory — editing source files alone does
  nothing until applied.
