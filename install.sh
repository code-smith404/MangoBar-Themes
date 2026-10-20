#!/usr/bin/env bash
set -euo pipefail

THEME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME:?HOME must be set}/.config/mangobar"

printf 'Choose a MangoBar theme to install:\n'
printf '  1) V1.0\n'
printf '  2) V1.1\n'
printf '  3) V2.0 (Under Development)\n'
printf '  4) V3.0 (Lumen)\n'
if ! read -r -p 'Enter 1, 2, 3, or 4: ' choice; then
    printf 'Error: no theme choice was provided.\n' >&2
    exit 1
fi

case "$choice" in
    1|V1.0|v1.0)
        version='V1.0'
        theme_path='v1.0'
        backup_name='mangobar-v1.0-backup'
        managed_files=(config.jsonc style.css)
        obsolete_files=()
        ;;
    2|V1.1|v1.1)
        version='V1.1'
        theme_path='v1.1'
        backup_name='mangobar-v1.1-backup'
        managed_files=(config.jsonc style.css scripts/network-speed.sh)
        obsolete_files=()
        ;;
    3|V2.0|v2.0)
        version='V2.0'
        theme_path='v2.0(Under Devlopment)'
        backup_name='mangobar-v2-backup'
        managed_files=(config.jsonc style.css scripts/power-menu.sh)
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
        ;;
    4|V3.0|v3.0)
        version='V3.0'
        theme_path='v3.0'
        backup_name='mangobar-v3.0-backup'
        managed_files=(config.jsonc style.css scripts/menu.sh scripts/power-menu.sh)
        obsolete_files=()
        ;;
    *)
        printf 'Error: invalid theme choice %q. Enter 1, 2, 3, or 4.\n' "$choice" >&2
        exit 1
        ;;
esac

for relative_path in "${managed_files[@]}"; do
    source="${THEME_DIR}/${theme_path}/${relative_path}"
    if [[ ! -f "$source" ]]; then
        printf 'Error: required theme file is missing: %s\n' "$source" >&2
        exit 1
    fi
done

for relative_path in "${managed_files[@]}" "${obsolete_files[@]}"; do
    target="${CONFIG_DIR}/${relative_path}"
    if [[ -d "$target" && ! -L "$target" ]]; then
        printf 'Error: refusing to replace a directory at %s\n' "$target" >&2
        exit 1
    fi
done

BACKUP_DIR="${HOME}/.config/${backup_name}-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p -- "${BACKUP_DIR}/originals"
if [[ "$version" == 'V2.0' || "$version" == 'V3.0' ]]; then
    mkdir -p -- "${BACKUP_DIR}/installed"
fi

backup_original() {
    local relative_path="$1"
    local target="${CONFIG_DIR}/${relative_path}"

    if [[ -e "$target" || -L "$target" ]]; then
        mkdir -p -- "${BACKUP_DIR}/originals/$(dirname "$relative_path")"
        cp -a -- "$target" "${BACKUP_DIR}/originals/${relative_path}"
    fi
}

for relative_path in "${managed_files[@]}"; do
    target="${CONFIG_DIR}/${relative_path}"
    backup_original "$relative_path"

    if [[ -L "$target" ]]; then
        rm -- "$target"
    fi

    mode=644
    if [[ "$relative_path" == scripts/* ]]; then
        mode=755
    fi
    install -D -m "$mode" "${THEME_DIR}/${theme_path}/${relative_path}" "$target"

    if [[ "$version" == 'V2.0' || "$version" == 'V3.0' ]]; then
        mkdir -p -- "${BACKUP_DIR}/installed/$(dirname "$relative_path")"
        cp -a -- "$target" "${BACKUP_DIR}/installed/${relative_path}"
    fi
done

for relative_path in "${obsolete_files[@]}"; do
    backup_original "$relative_path"
    rm -f -- "${CONFIG_DIR}/${relative_path}"
done

printf 'Successfully installed MangoBar %s to %s\n' "$version" "$CONFIG_DIR"
printf 'Existing files, if any, are backed up in %s\n' "$BACKUP_DIR"
printf 'Start MangoBar with: mangobar\n'
