# MangoBar V3.0 — Aurora

A polished midnight theme with a translucent ink panel, soft cyan and violet accents, compact workspace pills, a highlighted live clock, and a dedicated power-menu button.

![V3.0 Aurora theme preview](preview.svg)

## Install

From the repository root, run the installer and choose **4) V3.0 (Aurora)**:

```bash
./install.sh
```

The installer installs `config.jsonc`, `style.css`, and the executable `scripts/power-menu.sh` into `~/.config/mangobar/`. Existing files are backed up under `~/.config/mangobar-v3.0-backup-*`. It does not change MangoWM configuration or install system packages.

The power menu uses `wofi`, `rofi`, or `fuzzel` (first available) and requires `systemctl`/`loginctl` for its actions. Audio controls use `wpctl`. Install and configure those tools separately if you want the corresponding actions.

## Layout

- **Left:** workspace pills and the active window title.
- **Center:** date and a cyan-highlighted 24-hour clock.
- **Right:** network, volume, CPU, memory, battery, and power menu.
- Click a workspace to activate it; right-click to toggle it. Scroll over the workspace list to switch between occupied workspaces.
- Click volume to mute/unmute or scroll to adjust the level. Click the power control to open the confirmed power menu.

The theme uses plain text labels and a monospace font, so it does not depend on a Nerd Font.
