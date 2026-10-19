#!/usr/bin/env bash
set -euo pipefail

THEME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME:?HOME must be set}/.config/mangobar"
BACKUP_DIR="${HOME}/.config/mangobar-v2-backup-$(date +%Y%m%d-%H%M%S)-$$"
managed_files=(
    config.jsonc
    style.css
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

for relative_path in "${managed_files[@]}" "${obsolete_files[@]}"; do
    target="${CONFIG_DIR}/${relative_path}"
    if [[ -d "$target" && ! -L "$target" ]]; then
        printf 'Refusing to replace a directory at %s\n' "$target" >&2
        exit 1
    fi
done

mkdir -p "${BACKUP_DIR}/originals" "${BACKUP_DIR}/installed"

backup_original() {
    local relative_path="$1"
    local target="${CONFIG_DIR}/${relative_path}"

    if [[ -e "$target" || -L "$target" ]]; then
        mkdir -p "${BACKUP_DIR}/originals/$(dirname "$relative_path")"
        cp -a "$target" "${BACKUP_DIR}/originals/${relative_path}"
    fi
}

for relative_path in "${managed_files[@]}"; do
    backup_original "$relative_path"
    if [[ -L "${CONFIG_DIR}/${relative_path}" ]]; then
        rm -- "${CONFIG_DIR}/${relative_path}"
    fi
    mode=644
    if [[ "$relative_path" == scripts/* ]]; then
        mode=755
    fi
    install -D -m "$mode" "${THEME_DIR}/${relative_path}" "${CONFIG_DIR}/${relative_path}"
    mkdir -p "${BACKUP_DIR}/installed/$(dirname "$relative_path")"
    cp -a "${CONFIG_DIR}/${relative_path}" "${BACKUP_DIR}/installed/${relative_path}"
done

for relative_path in "${obsolete_files[@]}"; do
    backup_original "$relative_path"
    rm -f "${CONFIG_DIR}/${relative_path}"
done

printf 'Installed MangoBar V2.0 to %s\n' "$CONFIG_DIR"
printf 'Original files, if any, are backed up in %s\n' "$BACKUP_DIR"
printf 'Start MangoBar with: mangobar\n'
