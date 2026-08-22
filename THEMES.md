# Desktop themes

The desktop palette (shared by **waybar**, **mako**, **wofi** and **ghostty**) lives
per-machine in `[data.theme]` of the local `~/.config/chezmoi/chezmoi.toml`, so each
laptop can run a different theme. On a Hyprland machine `chezmoi init` seeds the
default (Gruvbox dark) block; edit it there to reskin.

## Switching a machine's theme

1. Open the local chezmoi config: `chezmoi edit-config` (or edit
   `~/.config/chezmoi/chezmoi.toml` directly).
2. Replace the `[data.theme]` table with one of the blocks below.
3. Apply: `chezmoi apply`.

The blocks are complete — paste over the whole `[data.theme]` table. Hex strings are
6-digit (no `#`, no alpha); `*_rgb` strings are comma triples for use inside `rgba()`.
Alpha is applied per-surface at the call site in the templates.

### Token reference

| Token             | Used for                                                        |
| ----------------- | --------------------------------------------------------------- |
| `background`      | Window/bar background (ghostty, waybar bar + dropdowns, wofi)    |
| `surface`         | Brand surfaces / waybar pills (full opacity)                    |
| `surface_hover`   | Hovered/active pill surfaces                                    |
| `accent`          | Active workspace, notification border                           |
| `accent_strong`   | Notification background, low-urgency border                     |
| `text`            | Foreground text + subtle hover/border overlays                  |
| `error`           | Errors, urgent/critical status                                  |
| `success`         | OK status, progress fills                                       |
| `info`            | Informational status                                            |

Each token has a matching `*_rgb` triple for the same colour.

---

## Work

systemGray surfaces over a deep-teal background, with a teal brand accent and
system status colours.

```toml
[data.theme]
    background         = "001a22"
    background_rgb     = "0, 26, 34"
    surface            = "2c2c2e"
    surface_rgb        = "44, 44, 46"
    surface_hover      = "3a3a3c"
    surface_hover_rgb  = "58, 58, 60"
    accent             = "007681"
    accent_rgb         = "0, 118, 129"
    accent_strong      = "48484a"
    accent_strong_rgb  = "72, 72, 74"
    text               = "ffffff"
    text_rgb           = "255, 255, 255"
    error              = "ff453a"
    error_rgb          = "255, 69, 58"
    success            = "30d158"
    success_rgb        = "48, 209, 88"
    info               = "0a84ff"
    info_rgb           = "10, 132, 255"
```

## Light

Light grey surfaces, teal brand accent.

```toml
[data.theme]
    background         = "f2f2f7"
    background_rgb     = "242, 242, 247"
    surface            = "e5e5ea"
    surface_rgb        = "229, 229, 234"
    surface_hover      = "d1d1d6"
    surface_hover_rgb  = "209, 209, 214"
    accent             = "007681"
    accent_rgb         = "0, 118, 129"
    accent_strong      = "c7c7cc"
    accent_strong_rgb  = "199, 199, 204"
    text               = "3a3a3c"
    text_rgb           = "58, 58, 60"
    error              = "ff3b30"
    error_rgb          = "255, 59, 48"
    success            = "34c759"
    success_rgb        = "52, 199, 89"
    info               = "007aff"
    info_rgb           = "0, 122, 255"
```

## Nord

Polar-night surfaces, frost accent, aurora status colours.

```toml
[data.theme]
    background         = "2e3440"
    background_rgb     = "46, 52, 64"
    surface            = "3b4252"
    surface_rgb        = "59, 66, 82"
    surface_hover      = "434c5e"
    surface_hover_rgb  = "67, 76, 94"
    accent             = "88c0d0"
    accent_rgb         = "136, 192, 208"
    accent_strong      = "4c566a"
    accent_strong_rgb  = "76, 86, 106"
    text               = "eceff4"
    text_rgb           = "236, 239, 244"
    error              = "bf616a"
    error_rgb          = "191, 97, 106"
    success            = "a3be8c"
    success_rgb        = "163, 190, 140"
    info               = "81a1c1"
    info_rgb           = "129, 161, 193"
```

## Gruvbox dark (default)

Warm dark surfaces, bright-orange accent. This is the palette `chezmoi init` seeds.

```toml
[data.theme]
    background         = "282828"
    background_rgb     = "40, 40, 40"
    surface            = "3c3836"
    surface_rgb        = "60, 56, 54"
    surface_hover      = "504945"
    surface_hover_rgb  = "80, 73, 69"
    accent             = "fe8019"
    accent_rgb         = "254, 128, 25"
    accent_strong      = "665c54"
    accent_strong_rgb  = "102, 92, 84"
    text               = "ebdbb2"
    text_rgb           = "235, 219, 178"
    error              = "fb4934"
    error_rgb          = "251, 73, 52"
    success            = "b8bb26"
    success_rgb        = "184, 187, 38"
    info               = "83a598"
    info_rgb           = "131, 165, 152"
```

## Blue (cool summer)

Shaded-pool background, clear sky accent, pale-ice info, cool-mint success,
warm-rose error pops against the cool palette.

```toml
[data.theme]
    background         = "1a2838"
    background_rgb     = "26, 40, 56"
    surface            = "273a52"
    surface_rgb        = "39, 58, 82"
    surface_hover      = "34496a"
    surface_hover_rgb  = "52, 73, 106"
    accent             = "7fb4d9"
    accent_rgb         = "127, 180, 217"
    accent_strong      = "3a5273"
    accent_strong_rgb  = "58, 82, 115"
    text               = "dde5ed"
    text_rgb           = "221, 229, 237"
    error              = "d97878"
    error_rgb          = "217, 120, 120"
    success            = "7fc9a4"
    success_rgb        = "127, 201, 164"
    info               = "9fcfe8"
    info_rgb           = "159, 207, 232"
```

## Windows XP

Luna blue — deep-blue taskbar surfaces, bright Luna-blue accent, start-button
green for "ok"/charging, and white text.

```toml
[data.theme]
    background         = "2257d8"
    background_rgb     = "34, 87, 216"
    surface            = "3a6ea5"
    surface_rgb        = "58, 110, 165"
    surface_hover      = "4f86c6"
    surface_hover_rgb  = "79, 134, 198"
    accent             = "3ca017"
    accent_rgb         = "60, 160, 23"
    accent_strong      = "1941a5"
    accent_strong_rgb  = "25, 65, 165"
    text               = "ffffff"
    text_rgb           = "255, 255, 255"
    error              = "cc2936"
    error_rgb          = "204, 41, 54"
    success            = "5cb85c"
    success_rgb        = "92, 184, 92"
    info               = "4f86c6"
    info_rgb           = "79, 134, 198"
```
