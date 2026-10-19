# MangoBar Themes

Ready-to-use themes for [MangoBar](https://github.com/mangowm/mangobar), the status bar for MangoWM. The V2.0 theme uses a Waybar-compatible JSONC configuration and stylesheet.

## Themes

### V1.0

Stable Catppuccin-inspired theme:

- [Configuration](v1.0/config.jsonc)
- [Stylesheet](v1.0/style.css)

### V2.0 (Under Development)

An experimental, dark sunset-city theme with a translucent charcoal bar, warm peach and gold accents, persistent workspaces, a live Cava spectrum, centered clock, and system monitors.

- [Configuration](v2.0%28Under%20Devlopment%29/config.jsonc)
- [Stylesheet](v2.0%28Under%20Devlopment%29/style.css)
- [Cava configuration](v2.0%28Under%20Devlopment%29/cava.conf)
- [Visualizer script](v2.0%28Under%20Devlopment%29/scripts/cava-visualizer.sh)

## V2.0 layout

- **Left:** workspaces followed immediately by a live, 16-bar audio visualizer.
- **Center:** a minimal 24-hour clock.
- **Right:** CPU, memory, root-disk usage, network name/speeds, volume, and battery (when available).
- **Palette:** translucent `#1E1E2E` charcoal with `#FAB387` peach and `#F9E2AF` gold highlights.

The graph uses Cava's ASCII raw output, rendered as block glyphs by the included Bash script. It starts with the bar's custom module and does not require a separate visualizer process.

## Dependencies

Required for the V2.0 layout:

- MangoBar, or a Waybar-compatible bar/configuration backend.
- Cava, with PulseAudio compatibility (`pipewire-pulse` for PipeWire systems or PulseAudio).
- A Nerd Font for the module icons. JetBrainsMono Nerd Font is the configured first choice; Maple Mono NF is also supported.
- `mmsg` for workspace click actions in MangoWM.
- `wpctl` and WirePlumber for the included volume controls.

Optional:

- `pavucontrol` for the volume module's right-click mixer action.
- A battery device; the battery module is useful on laptops and may be absent on desktops.
- A separate icon package is not needed when using a Nerd Font; the graph itself uses the bundled Unicode block glyphs.

Install these with your distribution's package manager. The included installer only copies theme files; it does not install packages or alter MangoWM settings.

## Install V2.0

From the repository root:

```bash
cd "v2.0(Under Devlopment)"
bash install.sh
```

The installer copies the configuration, stylesheet, Cava settings, and scripts into `~/.config/mangobar/`. Existing files with those names are backed up to a timestamped `~/.config/mangobar-v2-backup-*` directory. Script permissions are set to executable.

Run the Waybar-compatible backend with:

```bash
waybar -c "$HOME/.config/mangobar/config.jsonc" \
       -s "$HOME/.config/mangobar/style.css"
```

If MangoBar starts the bar for you, reload/restart it after installation and point it at `~/.config/mangobar/config.jsonc` and `style.css`.

To remove the V2.0 files and restore the latest backup, run `bash uninstall.sh` from the V2.0 directory. The uninstaller only handles files managed by this theme; it leaves other files in `~/.config/mangobar/` untouched.

## Manual setup

Copy the contents of [the V2.0 directory](v2.0%28Under%20Devlopment%29/) into `~/.config/mangobar/`, preserving the `scripts/` subdirectory, then make its scripts executable:

```bash
chmod +x "$HOME/.config/mangobar/scripts/"*.sh
```

Start or reload the bar using the configuration and stylesheet paths above.
