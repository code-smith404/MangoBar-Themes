#!/usr/bin/env bash
set -euo pipefail

THEME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME:?HOME must be set}/.config/mangobar"
BACKUP_DIR=""

backup_if_present() {
  local relative_path="$1"
  local target="${CONFIG_DIR}/${relative_path}"

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -z "$BACKUP_DIR" ]]; then
      BACKUP_DIR="${HOME}/.config/mangobar-v2-backup-$(date +%Y%m%d-%H%M%S)-$$"
    fi
    mkdir -p "${BACKUP_DIR}/$(dirname "$relative_path")"
    cp -a "$target" "${BACKUP_DIR}/${relative_path}"
  fi
}

install_file() {
  local source="$1"
  local relative_path="$2"
  local mode="$3"

  backup_if_present "$relative_path"
  install -D -m "$mode" "$source" "${CONFIG_DIR}/${relative_path}"
}

install_file "${THEME_DIR}/config.jsonc" "config.jsonc" 644
install_file "${THEME_DIR}/style.css" "style.css" 644
install_file "${THEME_DIR}/theme.conf" "theme.conf" 644
install_file "${THEME_DIR}/cava.conf" "cava.conf" 644

for script in "${THEME_DIR}/scripts/cava-visualizer.sh" "${THEME_DIR}/scripts/volume.sh"; do
  install_file "$script" "scripts/$(basename "$script")" 755
done

printf 'MangoBar V2.0 theme installed to %s\n' "$CONFIG_DIR"
if [[ -n "$BACKUP_DIR" ]]; then
  printf 'Existing theme files were backed up to %s\n' "$BACKUP_DIR"
fi
printf 'Start your Waybar-compatible bar with:\n'
printf '  waybar -c "%s/config.jsonc" -s "%s/style.css"\n' "$CONFIG_DIR" "$CONFIG_DIR"
