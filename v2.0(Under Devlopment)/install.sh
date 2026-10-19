#!/usr/bin/env bash
set -euo pipefail

export TERM=xterm-256color

SCRIPT_NAME="$(basename "$0")"
HOME_DIR="${HOME}"
CONFIG_ROOT="${HOME_DIR}/.config"
MANGO_DIR="${CONFIG_ROOT}/mango"
MANGOBAR_DIR="${CONFIG_ROOT}/mangobar"
WAYBAR_DIR="${CONFIG_ROOT}/waybar"
BACKUP_ROOT="${HOME_DIR}/.config-backup-$(date +%Y%m%d-%H%M%S)"
THEME_DIR="$(cd "$(dirname "$0")" && pwd)"

log() {
  printf '\033[1;34m[%s]\033[0m %s\n' "$SCRIPT_NAME" "$*"
}
warn() {
  printf '\033[1;33m[%s]\033[0m %s\n' "$SCRIPT_NAME" "$*"
}
ok() {
  printf '\033[1;32m[%s]\033[0m %s\n' "$SCRIPT_NAME" "$*"
}
fail() {
  printf '\033[1;31m[%s]\033[0m %s\n' "$SCRIPT_NAME" "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

if [[ "$(uname -s)" != "Linux" ]]; then
  fail "This installer is for Arch Linux / Linux only."
fi

if [[ ! -f /etc/arch-release ]]; then
  fail "This installer must run on Arch Linux."
fi

if [[ "${EUID}" -eq 0 ]]; then
  fail "Please run this as a normal user; use sudo only for package installation."
fi

if ! curl -fsSL --max-time 10 https://archlinux.org >/dev/null; then
  fail "No internet connectivity detected."
fi

if ! command -v sudo >/dev/null 2>&1; then
  warn "sudo not found; installing sudo first."
  pacman -S --needed --noconfirm sudo
fi

if ! command -v yay >/dev/null 2>&1; then
  log "Installing yay AUR helper..."
  TEMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TEMP_DIR"' EXIT
  git clone https://aur.archlinux.org/yay-bin.git "$TEMP_DIR/yay-bin"
  (cd "$TEMP_DIR/yay-bin" && makepkg -si --noconfirm)
  trap - EXIT
fi

log "Installing required packages..."
sudo pacman -S --needed --noconfirm \
  base-devel git curl jq \
  waybar cava playerctl pipewire pipewire-pulse wireplumber \
  networkmanager pavucontrol wofi rofi fuzzel mako \
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji \
  gtk-layer-shell python-gobject libnotify wl-clipboard \
  xdg-user-dirs brightnessctl rsync

yay -S --needed --noconfirm \
  bibata-cursor-theme \
  bibata-cursor-theme-extra \
  catppuccin-cursors \
  capitaine-cursors

mkdir -p "$BACKUP_ROOT"
for target in "$CONFIG_ROOT/mango" "$CONFIG_ROOT/waybar" "$CONFIG_ROOT/mangobar" "$CONFIG_ROOT/gtk-3.0" "$CONFIG_ROOT/gtk-4.0" "$HOME_DIR/.icons/default"; do
  if [[ -e "$target" ]]; then
    mkdir -p "$BACKUP_ROOT/$(dirname "${target#$HOME_DIR/}")"
    cp -a "$target" "$BACKUP_ROOT/$(dirname "${target#$HOME_DIR/}")/"
  fi
done

mkdir -p "$MANGOBAR_DIR/scripts" "$WAYBAR_DIR" "$MANGO_DIR" "$HOME_DIR/.config/environment.d" "$HOME_DIR/.icons/default" "$HOME_DIR/.config/gtk-3.0" "$HOME_DIR/.config/gtk-4.0"

cp -a "${THEME_DIR}/style.css" "$MANGOBAR_DIR/style.css"
cp -a "${THEME_DIR}/style.css" "$WAYBAR_DIR/style.css"
cp -a "${THEME_DIR}/config.jsonc" "$WAYBAR_DIR/config"
cp -a "${THEME_DIR}/theme.conf" "$MANGOBAR_DIR/theme.conf"
cp -a "${THEME_DIR}/cava.conf" "$MANGOBAR_DIR/cava.conf"

cat > "$MANGOBAR_DIR/scripts/media.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if ! command -v playerctl >/dev/null 2>&1; then
  printf ' No media\n'
  exit 0
fi
status="$(playerctl status 2>/dev/null || true)"
if [[ -z "$status" || "$status" == "No players found" ]]; then
  printf ' No media\n'
  exit 0
fi
artist="$(playerctl metadata artist 2>/dev/null || true)"
title="$(playerctl metadata title 2>/dev/null || true)"
album="$(playerctl metadata album 2>/dev/null || true)"
if [[ -n "$artist" && -n "$title" ]]; then
  payload="$artist - $title"
  if [[ -n "$album" ]]; then
    payload+=" - $album"
  fi
  printf ' %s\n' "$payload"
else
  printf ' %s\n' "${title:-$status}"
fi
EOF

cat > "$MANGOBAR_DIR/scripts/weather.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
weather="$(curl -fsSL --max-time 7 'https://wttr.in/Ajeetpura,Bhadra,Hanumangarh,Rajasthan,India?format=%t' 2>/dev/null || true)"
if [[ -z "$weather" ]]; then
  printf ' --\n'
  exit 0
fi
printf ' %s\n' "$weather"
EOF

cat > "$MANGOBAR_DIR/scripts/gamemode.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
STATE_DIR="${HOME}/.cache/mangobar"
STATE_FILE="${STATE_DIR}/gamemode"
mkdir -p "$STATE_DIR"
case "${1:-toggle}" in
  toggle)
    if [[ -f "$STATE_FILE" ]]; then
      rm -f "$STATE_FILE"
      echo "game mode off"
    else
      touch "$STATE_FILE"
      echo "game mode on"
    fi
    ;;
  status)
    if [[ -f "$STATE_FILE" ]]; then
      printf '\n'
    else
      printf '\n'
    fi
    ;;
  *)
    printf 'usage: %s [toggle|status]\n' "$0"
    ;;
esac
EOF

cat > "$MANGOBAR_DIR/scripts/idle-toggle.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
STATE_DIR="${HOME}/.cache/mangobar"
STATE_FILE="${STATE_DIR}/idle"
mkdir -p "$STATE_DIR"
case "${1:-toggle}" in
  toggle)
    if [[ -f "$STATE_FILE" ]]; then
      rm -f "$STATE_FILE"
      pkill -f 'systemd-inhibit.*mangobar' || true
      echo "idle inhibitor off"
    else
      touch "$STATE_FILE"
      systemd-inhibit --what=idle --why='MangoBar idle inhibitor' --mode=block bash -c 'sleep infinity' >/dev/null 2>&1 &
      echo "idle inhibitor on"
    fi
    ;;
  status)
    if [[ -f "$STATE_FILE" ]]; then
      printf '󰈈\n'
    else
      printf '󰈉\n'
    fi
    ;;
  *)
    printf 'usage: %s [toggle|status]\n' "$0"
    ;;
esac
EOF

cat > "$MANGOBAR_DIR/scripts/volume.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-status}" in
  mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    ;;
  up)
    wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
    ;;
  down)
    wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-
    ;;
  switch)
    pactl list short sinks | awk '{print $2}' | tail -n +1 | while read -r sink; do echo "$sink"; done | head -n 2 | tail -n 1 | xargs -r -I{} pactl set-default-sink "{}"
    ;;
  status)
    vol="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2}')"
    printf '%s\n' "${vol:-0}"
    ;;
  *)
    printf 'usage: %s [mute|up|down|switch|status]\n' "$0"
    ;;
esac
EOF

cat > "$MANGOBAR_DIR/scripts/network-menu.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if command -v wofi >/dev/null 2>&1; then
  nmcli device wifi list | tail -n +1 | wofi --dmenu --show dmenu || true
elif command -v rofi >/dev/null 2>&1; then
  nmcli device wifi list | tail -n +1 | rofi -dmenu || true
else
  nmcli device wifi list
fi
EOF

cat > "$MANGOBAR_DIR/scripts/power-menu.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
opts=("lock" "logout" "reboot" "shutdown")
if command -v wofi >/dev/null 2>&1; then
  choice="$(printf '%s\n' "${opts[@]}" | wofi --dmenu)"
elif command -v rofi >/dev/null 2>&1; then
  choice="$(printf '%s\n' "${opts[@]}" | rofi -dmenu)"
else
  choice=""
fi
case "$choice" in
  lock) loginctl lock-session || true ;;
  logout) pkill -KILL -u "$USER" || true ;;
  reboot) systemctl reboot || loginctl reboot || true ;;
  shutdown) systemctl poweroff || loginctl poweroff || true ;;
  *) ;;
esac
EOF

cat > "$MANGOBAR_DIR/scripts/cursor-switch.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
THEMES=(
  "Bibata-Modern-Classic"
  "Bibata-Modern-Ice"
  "Catppuccin-Mocha-Dark-Cursors"
  "Capitaine-cursors"
)
if command -v wofi >/dev/null 2>&1; then
  choice="$(printf '%s\n' "${THEMES[@]}" | wofi --dmenu)"
elif command -v rofi >/dev/null 2>&1; then
  choice="$(printf '%s\n' "${THEMES[@]}" | rofi -dmenu)"
else
  choice="${THEMES[0]}"
fi
if [[ -z "$choice" ]]; then
  exit 0
fi
mkdir -p "$HOME/.config/environment.d"
cat > "$HOME/.config/environment.d/99-cursor.conf" <<CURSOR
XCURSOR_THEME=${choice}
XCURSOR_SIZE=24
CURSOR
export XCURSOR_THEME="$choice"
export XCURSOR_SIZE=24
ln -sf "/usr/share/icons/${choice}" "$HOME/.icons/default"
# GTK and Qt apps often require a restart; compositor reload is best-effort only.
gsettings set org.gnome.desktop.interface cursor-theme "$choice" || true
printf 'Selected cursor theme: %s\n' "$choice"
EOF

cat > "$MANGOBAR_DIR/scripts/visualizer-toggle.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
STATE="${HOME}/.cache/mangobar/visualizer"
mkdir -p "$(dirname "$STATE")"
if [[ -f "$STATE" ]]; then
  rm -f "$STATE"
  pkill -f 'cava' || true
  printf 'visualizer off\n'
else
  touch "$STATE"
  cava -p "${HOME}/.config/mangobar/cava.conf" >/dev/null 2>&1 &
  printf 'visualizer on\n'
fi
EOF

for file in "$MANGOBAR_DIR/scripts"/*.sh; do
  chmod +x "$file"
done

cat > "$MANGO_DIR/config.conf" <<'EOF'
# MangoWM config additions
setenv XCURSOR_THEME Bibata-Modern-Classic
setenv XCURSOR_SIZE 24
setenv GTK_THEME Adwaita-dark
setenv QT_QPA_PLATFORMTHEME gtk3
EOF

cat > "$MANGO_DIR/autostart.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
# Start the bar and visualizer in a wayland-friendly order.
if command -v waybar >/dev/null 2>&1; then
  (waybar -c "${HOME}/.config/waybar/config" -s "${HOME}/.config/waybar/style.css" >/dev/null 2>&1 &) || true
fi
if command -v cava >/dev/null 2>&1; then
  (cava -p "${HOME}/.config/mangobar/cava.conf" >/dev/null 2>&1 &) || true
fi
if command -v mako >/dev/null 2>&1; then
  (mako >/dev/null 2>&1 &) || true
fi
EOF
chmod +x "$MANGO_DIR/autostart.sh"

cat > "$HOME_DIR/.config/environment.d/99-mangobar.conf" <<'EOF'
XCURSOR_THEME=Bibata-Modern-Classic
XCURSOR_SIZE=24
EOF

cat > "$HOME_DIR/.config/gtk-3.0/settings.ini" <<'EOF'
[Settings]
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-font-name=JetBrainsMono Nerd Font 11
EOF

cat > "$HOME_DIR/.config/gtk-4.0/settings.ini" <<'EOF'
[Settings]
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-font-name=JetBrainsMono Nerd Font 11
EOF

cat > "$HOME_DIR/.icons/default/index.theme" <<'EOF'
[Icon Theme]
Inherits=Bibata-Modern-Classic
EOF

gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic || true


ok "All theme files created."
ok "Run: waybar -c ${WAYBAR_DIR}/config -s ${WAYBAR_DIR}/style.css"
ok "Or source ${HOME_DIR}/.config/mango/autostart.sh"

printf '\n\033[1;32mMangoBar V2.0 install complete.\033[0m\n'
printf 'Restart MangoWM or run the autostart script before reloading the bar.\n'
printf 'If GTK apps do not pick up the new cursor immediately, restart them once.\n'
