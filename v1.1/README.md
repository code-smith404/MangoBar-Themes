# MangoBar V1.1

A more compact update to the V1.0 Catppuccin-inspired theme, with a continuously visible network transfer-rate indicator.

## Install

From the repository root, run the installer and select V1.1:

```bash
./install.sh
```

The installer copies the configuration, stylesheet, and network-speed script into `~/.config/mangobar/`. Existing managed files are backed up under `~/.config/mangobar-v1.1-backup-*`. The installer does not install system packages or modify MangoWM configuration.

The speed module uses `ip` from `iproute2` to select the interface with the default IPv4 route (or IPv6 route when IPv4 is unavailable), then samples its byte counters under `/sys/class/net`. `iproute2` is normally present with a MangoWM setup. If no default route exists, it displays `NET offline`.

Install any optional modules used by your setup separately. The power and volume actions in this configuration use `wlogout`, `pamixer`, and `brightnessctl`.

## Layout

The bar is 27 pixels high with reduced font size, spacing, tray icons, and shorter status labels. The right side keeps connection state and places download/upload rates next to it. Network rates refresh once per second; the first sample is zero until the next reading.

To launch the bar, run:

```bash
mangobar
```

The installer intentionally leaves MangoWM autostart configuration unchanged.
