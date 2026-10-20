# MangoBar V2.0 — Ember Glass (Under Development)

Ember Glass is a polished dark-glass bar for MangoWM, pairing a deep charcoal panel and soft gradients with a warm peach accent, cool teal status colors, and gently rounded modules.

## Compatibility and supported features

This configuration follows the currently published MangoBar configuration, module, and styling documentation. MangoBar itself is not installed in the development workspace, so its exact local version and runtime behavior could not be checked. On your Arch system, use `mangobar -v` to see the installed version.

The configuration uses documented MangoBar features:

- `workspaces` tags with an active state, click-to-activate, and right-click toggle.
- `window` title with a 42-character maximum width.
- Centered `clock#date` and `clock#time`.
- A system tray plus native `network`, `pulseaudio`, `cpu`, `memory`, and `battery` modules.
- A `custom/power` module that opens the included power menu.
- MangoBar CSS colors, gradients, `mix()`, rounded corners, and module hover/active states.

MangoBar's documented CSS does not include blur, shadows, borders, CSS transitions, or general GTK/Web CSS. Those effects are not used here. The documented module actions are pointer actions; this setup does not claim keyboard navigation or screen-reader support from MangoBar.

## Arch Linux dependencies

This guide assumes you already have an Arch Linux MangoWM session. MangoWM installation and configuration are managed separately; V2 does not overwrite compositor files. If MangoBar is already installed, skip its build dependencies. The upstream installation guide currently documents these Arch packages for building from source:

```bash
sudo pacman -S --needed base-devel git meson ninja pkgconf cjson \
  wayland wayland-protocols fcft tllist pixman cairo pango libpulse \
  systemd-libs gdk-pixbuf2 alsa-lib
```

Build and install MangoBar if needed:

```bash
git clone https://github.com/mangowm/mangobar.git
cd mangobar
meson setup build -Dprefix=/usr
ninja -C build
sudo ninja -C build install
```

For this theme's interactive power menu and PipeWire volume controls, install:

```bash
sudo pacman -S --needed wofi pipewire-pulse wireplumber
```

`wofi` is the recommended menu. The script also supports `rofi` or `fuzzel` if already installed. If none is available, the power menu reports the missing dependency and does not perform an action. `notify-send` from `libnotify` is optional and is used only to surface action errors graphically. Workspace scrolling uses MangoWM's `mmsg` command, which should be available with MangoWM.

MangoBar's native volume module uses its PulseAudio interface. `pipewire-pulse` supplies that interface on a PipeWire desktop; `wpctl` from WirePlumber handles mute and volume actions. The network module uses system network information without requiring NetworkManager. The battery module reads battery status when a battery is present and is hidden on systems without one. **Maple Mono NF** is the recommended Nerd Font for the icons used in this theme; install it or change `font-family` in `style.css` to a font installed on your system.

## Install

From the repository root, run the installer and select V2.0:

```bash
./install.sh
```

The installer copies only `config.jsonc`, `style.css`, and `scripts/power-menu.sh` into `~/.config/mangobar/`. It does not install system packages or modify MangoWM configuration. Existing target files and known files from the previous V2 theme are backed up under `~/.config/mangobar-v2-backup-*` before replacement or cleanup. The executable bit is set on the installed power-menu script.

To copy the theme manually from the repository root instead:

```bash
mkdir -p "$HOME/.config/mangobar/scripts"
cp "v2.0(Under Devlopment)/config.jsonc" \
   "v2.0(Under Devlopment)/style.css" \
   "$HOME/.config/mangobar/"
install -m 755 "v2.0(Under Devlopment)/scripts/power-menu.sh" \
    "$HOME/.config/mangobar/scripts/power-menu.sh"
```

## Ember Glass colors and fonts

The main palette is defined at the top of `style.css`. Change `@accent` for the warm highlight and `@accent-deep` for its darker gradient endpoint; `@teal` and `@gold` control the cool and secondary accents. The theme uses **Maple Mono NF** for its compact typography and Nerd Font icons.

To launch or test the theme inside a MangoWM session:

```bash
mangobar
```

MangoBar defaults to `~/.config/mangobar/config.jsonc` and `style.css`. For a one-off launch with explicit paths:

```bash
mangobar -c "$HOME/.config/mangobar/config.jsonc" \
         -s "$HOME/.config/mangobar/style.css"
```

To start the bar automatically with MangoWM, add `mangobar` to your existing MangoWM autostart configuration using the syntax supported by your installed MangoWM version. The installer intentionally leaves compositor configuration untouched.

## Reload and uninstall

The documented MangoBar command-line options do not include a reload flag. If running it in a terminal, stop it with `Ctrl+C` and run `mangobar` again after editing the configuration or stylesheet. If your session starts it automatically, restart the bar using the method configured for your session.

To remove this theme and restore the latest install backup:

```bash
cd "v2.0(Under Devlopment)"
./uninstall.sh
```

The uninstaller only processes the files managed by this theme. If a newly installed file has been edited since installation and there was no previous version to restore, it preserves that modified file.

## Layout and customization

- **Left:** MangoWM tags and the active window title.
- **Center:** localized weekday/date and a 24-hour clock.
- **Right:** tray, connection/transfer speed, volume/mute, CPU, memory, battery, and power menu.
- Network left-click toggles the module's documented alternate speed display. Volume left-click toggles mute; scrolling adjusts volume.
- Log out, restart, and power off each require a second explicit confirmation.
- Window and network labels are width-limited to reduce crowding. The bar uses a 38-pixel logical height and follows the output scale.

Edit `config.jsonc` for module order, labels, refresh interval, and actions. Edit `style.css` using only the MangoBar styling properties documented in its [Styling guide](https://github.com/mangowm/mangobar/wiki/Styling). MangoBar does not document adaptive module hiding or CSS breakpoints, so on a narrow display reduce labels or remove modules in the configuration.

## Upstream references

- [MangoBar installation](https://github.com/mangowm/mangobar/wiki/Installation)
- [MangoBar configuration](https://github.com/mangowm/mangobar/wiki/Configuration)
- [MangoBar styling](https://github.com/mangowm/mangobar/wiki/Styling)
- [MangoBar tags module](https://github.com/mangowm/mangobar/wiki/Module:-Tags)
- [MangoBar window module](https://github.com/mangowm/mangobar/wiki/Module:-Window)
- [MangoBar clock module](https://github.com/mangowm/mangobar/wiki/Module:-Clock)
- [MangoBar network module](https://github.com/mangowm/mangobar/wiki/Module:-Network)
- [MangoBar CPU module](https://github.com/mangowm/mangobar/wiki/Module:-CPU)
- [MangoBar memory module](https://github.com/mangowm/mangobar/wiki/Module:-Memory)
- [MangoBar battery module](https://github.com/mangowm/mangobar/wiki/Module:-Battery)
- [MangoBar custom module](https://github.com/mangowm/mangobar/wiki/Module:-Custom)
