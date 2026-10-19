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
cat > "$HOME/.config/environment.d/99-cursor.conf" <<EOF
XCURSOR_THEME=${choice}
XCURSOR_SIZE=24
EOF

export XCURSOR_THEME="$choice"
export XCURSOR_SIZE=24
ln -sfn "/usr/share/icons/${choice}" "$HOME/.icons/default"
gsettings set org.gnome.desktop.interface cursor-theme "$choice" || true
printf 'Selected cursor theme: %s\n' "$choice"
