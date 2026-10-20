# MangoBar V2.0 — Midnight Lake (Under Development)

Midnight Lake is a dark, translucent midnight-blue theme for Arch Linux sessions running MangoWM. It uses **MangoBar**, the native Wayland layer-shell bar for MangoWM—not Waybar, Hyprland, or Sway. The workspace tags and active-window title come directly from MangoBar's MangoWM integration; the configuration does not add guessed compositor commands or replace MangoWM files.

## Layout

- **Left:** MangoWM workspaces 1–4, kept visible with MangoBar's `pinned` tags option. The active tag is lavender; inactive tags are subdued.
- **Center:** the live title of the active window, centered by MangoBar. It is not a static label or brand name.
- **Right:** live CPU and memory usage, network-link icon, volume and mute state, localized date, and 24-hour time. Fine vertical dividers separate the modules.
- **No battery, tray, or power module** is included.

CPU and memory are reported as percentages by MangoBar's native modules. The network icon reflects Wi-Fi signal strength or the wired/disconnected state. Volume comes from MangoBar's PulseAudio module; on a PipeWire desktop, the `pipewire-pulse` compatibility service supplies that interface.

MangoBar's documented styling supports alpha colors, gradients, and rounded corners, but not backdrop blur. This theme uses a tinted, translucent panel to create a restrained glass effect without relying on unsupported CSS.

## Arch Linux requirements

Run this theme inside a working MangoWM Wayland session with MangoBar installed. If MangoBar is not installed, its upstream guide documents this Arch build setup:

```bash
sudo pacman -S --needed base-devel git meson ninja pkgconf cjson \
  wayland wayland-protocols fcft tllist pixman cairo pango libpulse \
  systemd-libs gdk-pixbuf2 alsa-lib

git clone https://github.com/mangowm/mangobar.git
cd mangobar
meson setup build -Dprefix=/usr
ninja -C build
sudo ninja -C build install
```

Install a Nerd Font for the module icons. The stylesheet defaults to **JetBrainsMono Nerd Font**; change `font-family` in `style.css` if you use another installed Nerd Font.

## Install and run

From the repository root, select V2.0 in the theme installer:

```bash
./install.sh
```

The installer copies `config.jsonc`, `style.css`, and `wallpaper.svg` to `~/.config/mangobar/`, backing up files it replaces. It does not install packages, change MangoWM configuration, or start a wallpaper service.

Start or restart the bar from a MangoWM session:

```bash
mangobar
```

MangoBar reads `~/.config/mangobar/config.jsonc` and `style.css` by default. To test alternate files:

```bash
mangobar -c "$HOME/.config/mangobar/config.jsonc" \
         -s "$HOME/.config/mangobar/style.css"
```

Add `mangobar` to the autostart method already used by your MangoWM session if you want it to launch automatically. The installer intentionally leaves compositor configuration untouched.

## Wallpaper

`wallpaper.svg` is a 2560×1440 sunset landscape with layered indigo mountains, a coral sun, a dark pine forest, and a reflective lake. It is installed at `~/.config/mangobar/wallpaper.svg` as a separate wallpaper asset; MangoBar does not set the desktop background. Apply it with the wallpaper utility already configured for your session. No specific wallpaper daemon or compositor command is assumed.

## Customize and uninstall

- Edit `config.jsonc` to change module order, workspace labels, refresh interval, or window-title width. The center group is MangoBar's documented true-center placement.
- Edit `style.css` to adjust the midnight palette, lavender/teal accents, transparency, radius, and spacing. Only MangoBar's supported CSS subset is used.
- The clock follows the system locale. Change its `strftime` format in the two `clock` module entries to customize the date or time.
- Remove the theme and restore the latest installer backup with:

  ```bash
  cd "v2.0(Under Devlopment)"
  ./uninstall.sh
  ```

## Upstream documentation

- [MangoBar repository and MangoWM compatibility](https://github.com/mangowm/mangobar)
- [Installation](https://github.com/mangowm/mangobar/wiki/Installation)
- [Configuration and module placement](https://github.com/mangowm/mangobar/wiki/Configuration)
- [Styling](https://github.com/mangowm/mangobar/wiki/Styling)
- [Workspace tags](https://github.com/mangowm/mangobar/wiki/Module:-Tags)
- [Active window title](https://github.com/mangowm/mangobar/wiki/Module:-Window)
- [CPU](https://github.com/mangowm/mangobar/wiki/Module:-CPU)
- [Memory](https://github.com/mangowm/mangobar/wiki/Module:-Memory)
- [Network](https://github.com/mangowm/mangobar/wiki/Module:-Network)
- [Clock](https://github.com/mangowm/mangobar/wiki/Module:-Clock)
- [Custom modules](https://github.com/mangowm/mangobar/wiki/Module:-Custom)
