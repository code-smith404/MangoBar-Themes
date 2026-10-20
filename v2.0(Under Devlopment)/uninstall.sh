#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${HOME:?HOME must be set}/.config/mangobar"
BACKUP_DIR="$(ls -dt "${HOME}"/.config/mangobar-v2-backup-* 2>/dev/null | head -n 1 || true)"
managed_files=(
    config.jsonc
    style.css
    wallpaper.svg
    scripts/power-menu.sh
)
obsolete_files=(
    cava.conf
    theme.conf
    scripts/cava-visualizer.sh
    scripts/cursor-switch.sh
    scripts/gamemode.sh
    scripts/idle-toggle.sh
    scripts/media.sh
    scripts/network-menu.sh
    scripts/visualizer-toggle.sh
    scripts/weather.sh
    scripts/volume.sh
)

if [[ -z "$BACKUP_DIR" ]]; then
    printf 'No MangoBar V2 backup was found; no files were changed.\n'
    exit 0
fi

restore_file() {
    local relative_path="$1"
    local target="${CONFIG_DIR}/${relative_path}"
    local original="${BACKUP_DIR}/originals/${relative_path}"
    local installed="${BACKUP_DIR}/installed/${relative_path}"

    if [[ -e "$original" || -L "$original" ]]; then
        rm -f "$target"
        mkdir -p "$(dirname "$target")"
        cp -a "$original" "$target"
    elif [[ -e "$installed" && -f "$target" && ! -L "$target" ]]; then
        if cmp -s "$installed" "$target"; then
            rm -f "$target"
        else
            printf 'Preserved modified file: %s\n' "$target"
        fi
    fi
}

for relative_path in "${managed_files[@]}"; do
    restore_file "$relative_path"
done

for relative_path in "${obsolete_files[@]}"; do
    original="${BACKUP_DIR}/originals/${relative_path}"
    target="${CONFIG_DIR}/${relative_path}"
    if [[ -e "$original" || -L "$original" ]]; then
        rm -f "$target"
        mkdir -p "$(dirname "$target")"
        cp -a "$original" "$target"
    fi
done

printf 'MangoBar V2.0 files restored/removed using %s\n' "$BACKUP_DIR"
