# MangoBar V3.0 — macOS Dark

A compact, dark desktop menu bar with flat full-width styling, quiet menu labels, a centered window title, and a subdued system-status cluster. It takes inspiration from minimal desktop menu bars and intentionally does not use Apple branding or the Apple logo.

![V3.0 macOS Dark menu-bar preview](preview.svg)

## Install

From the repository root, run the installer and choose **option 4**:

```bash
./install.sh
```

The installer copies `config.jsonc`, `style.css`, and the executable `scripts/menu.sh` and `scripts/power-menu.sh` into `~/.config/mangobar/`.

To copy the files manually from the repository root:

```bash
mkdir -p "$HOME/.config/mangobar/scripts"
cp v3.0/config.jsonc v3.0/style.css "$HOME/.config/mangobar/"
install -m 755 v3.0/scripts/menu.sh v3.0/scripts/power-menu.sh \
    "$HOME/.config/mangobar/scripts/"
```

## Behavior and limits

- Click a workspace number to activate it; right-click toggles it; scrolling switches through occupied workspaces.
- **Apps** opens the installed application launcher. **Files** opens Home, Downloads, or the file manager. **Help** opens MangoBar or MangoWM documentation.
- Click the network item to toggle its alternate transfer-rate display. Click audio to mute/unmute or scroll to adjust volume.
- The status tray, active-window title, battery, date, and time are native MangoBar modules. The included script also keeps a confirmed power menu available when invoked without an action argument, although it is not shown as a status-bar button.

MangoBar cannot show the active application's native File/Edit/View menus, macOS Control Center, or Apple system menus. The labels here trigger Linux desktop actions and are not a full macOS behavior clone.

## Font and colors

**Inter** is recommended for a clean sans-serif look. Install Inter through your distribution's font packages or from its official font distribution, then set `font-family` to `Inter` in `style.css`. `system-ui` or another installed sans-serif is a suitable substitute.

Colors are defined at the top of `style.css`. `@accent` controls the active workspace color; the other variables control the dark bar, hover surfaces, text, and status states.
