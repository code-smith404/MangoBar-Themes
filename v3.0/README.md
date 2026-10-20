# MangoBar V3.0 — Lumen

Lumen is a dark, macOS-inspired menu bar for MangoWM. It uses restrained menu labels on the left, a subdued active-window title, and a compact tray/network/audio/battery/clock cluster on the right. The Apple logo is intentionally omitted.

![V3.0 Lumen dark menu-bar preview](preview.svg)

## Install

From the repository root, run the installer and choose **4) V3.0 (Lumen)**:

```bash
./install.sh
```

The installer copies `config.jsonc`, `style.css`, and the executable `scripts/menu.sh` and `scripts/power-menu.sh` into `~/.config/mangobar/`. Existing files are backed up under `~/.config/mangobar-v3.0-backup-*`.

To install manually from the repository root:

```bash
mkdir -p "$HOME/.config/mangobar/scripts"
cp v3.0/config.jsonc v3.0/style.css "$HOME/.config/mangobar/"
install -m 755 v3.0/scripts/menu.sh v3.0/scripts/power-menu.sh \
    "$HOME/.config/mangobar/scripts/"
```

## Menu behavior

The **Workspace** menu switches to the previous or next occupied workspace. **Apps** opens the desktop application launcher. **Files** opens Home, Downloads, or the file manager. **Help** opens MangoBar or MangoWM documentation. The workspace menu uses MangoWM's `mmsg`; the app/menu launchers use `wofi`, `rofi`, or `fuzzel`; file actions use `xdg-open` and an installed file manager.

The system tray is MangoBar's native tray. Click the audio indicator to mute/unmute, scroll it to adjust volume, click the network indicator to toggle its alternate transfer-rate display, and use the power control for confirmed logout/restart/shutdown actions.

This is a macOS-inspired Linux bar, not a full macOS menu-bar replacement. MangoBar does not expose active applications' native File/Edit/View/Window menus, Apple system menus, or macOS control-center behavior. The menus here are global desktop actions and do not show app-specific commands.

## Customize

The palette is defined at the top of `style.css`. Adjust `@accent` and `@accent-strong` to change the warm highlight. **Inter** is the recommended font; replace it in the global `font-family` rule if it is not installed. Nerd Font icons are only used for audio and power indicators; Maple Mono NF or another Nerd Font is recommended for those glyphs.
