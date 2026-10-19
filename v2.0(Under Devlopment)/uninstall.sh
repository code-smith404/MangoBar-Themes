#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${HOME:?HOME must be set}/.config/mangobar"
BACKUP_DIR="$(ls -dt "${HOME}"/.config/mangobar-v2-backup-* 2>/dev/null | head -n 1 || true)"
files=("config.jsonc" "style.css" "theme.conf" "cava.conf")
files+=("scripts/cava-visualizer.sh" "scripts/volume.sh")

for relative_path in "${files[@]}"; do
  target="${CONFIG_DIR}/${relative_path}"
  backup="${BACKUP_DIR}/${relative_path}"
  if [[ -e "$target" || -L "$target" ]]; then
    rm -f "$target"
  fi
  if [[ -n "$BACKUP_DIR" && ( -e "$backup" || -L "$backup" ) ]]; then
    mkdir -p "$(dirname "$target")"
    cp -a "$backup" "$target"
  fi
done

printf 'MangoBar V2.0 theme files removed from %s\n' "$CONFIG_DIR"
if [[ -n "$BACKUP_DIR" ]]; then
  printf 'Previous files were restored from %s\n' "$BACKUP_DIR"
else
  printf 'No V2.0 backup was found; unrelated files and directories were left untouched.\n'
fi
