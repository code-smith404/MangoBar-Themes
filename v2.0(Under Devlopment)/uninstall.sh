#!/usr/bin/env bash
set -euo pipefail

HOME_DIR="${HOME}"
CONFIG_ROOT="${HOME_DIR}/.config"
BACKUP_PARENT="${HOME_DIR}"

latest_backup="$(ls -dt "${BACKUP_PARENT}/.config-backup-*" 2>/dev/null | head -n 1 || true)"

if [[ -n "$latest_backup" ]]; then
  echo "Restoring from ${latest_backup}"
  for item in "$CONFIG_ROOT/mango" "$CONFIG_ROOT/waybar" "$CONFIG_ROOT/mangobar" "$HOME_DIR/.config/gtk-3.0" "$HOME_DIR/.config/gtk-4.0" "$HOME_DIR/.icons/default" "$HOME_DIR/.config/environment.d"; do
    if [[ -e "$item" ]]; then
      rm -rf "$item"
    fi
  done
  cp -a "${latest_backup}/mango" "${CONFIG_ROOT}/mango" 2>/dev/null || true
  cp -a "${latest_backup}/waybar" "${CONFIG_ROOT}/waybar" 2>/dev/null || true
  cp -a "${latest_backup}/mangobar" "${CONFIG_ROOT}/mangobar" 2>/dev/null || true
  cp -a "${latest_backup}/gtk-3.0" "${HOME_DIR}/.config/gtk-3.0" 2>/dev/null || true
  cp -a "${latest_backup}/gtk-4.0" "${HOME_DIR}/.config/gtk-4.0" 2>/dev/null || true
  cp -a "${latest_backup}/default" "${HOME_DIR}/.icons/default" 2>/dev/null || true
  cp -a "${latest_backup}/environment.d" "${HOME_DIR}/.config/environment.d" 2>/dev/null || true
else
  rm -rf "$CONFIG_ROOT/mango" "$CONFIG_ROOT/waybar" "$CONFIG_ROOT/mangobar" "$HOME_DIR/.config/gtk-3.0" "$HOME_DIR/.config/gtk-4.0" "$HOME_DIR/.icons/default" "$HOME_DIR/.config/environment.d"
fi

rm -f "$HOME_DIR/.config/environment.d/99-mangobar.conf" "$HOME_DIR/.config/environment.d/99-cursor.conf"
rm -f "$HOME_DIR/.config/gtk-3.0/settings.ini" "$HOME_DIR/.config/gtk-4.0/settings.ini"
rm -f "$HOME_DIR/.icons/default/index.theme"

printf 'Uninstall complete.\n'
