#!/usr/bin/env bash
set -euo pipefail

THEME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME:?HOME must be set}/.config/mangobar"
BACKUP_DIR="${HOME}/.config/mangobar-v1.1-backup-$(date +%Y%m%d-%H%M%S)-$$"
managed_files=(
    config.jsonc
    style.css
    scripts/network-speed.sh
)

for relative_path in "${managed_files[@]}"; do
    target="${CONFIG_DIR}/${relative_path}"
    if [[ -d "$target" && ! -L "$target" ]]; then
        printf 'Refusing to replace a directory at %s\n' "$target" >&2
        exit 1
    fi
done

mkdir -p -- "${BACKUP_DIR}/originals"

for relative_path in "${managed_files[@]}"; do
    source="${THEME_DIR}/${relative_path}"
    target="${CONFIG_DIR}/${relative_path}"
    if [[ ! -f "$source" ]]; then
        printf 'Required theme file is missing: %s\n' "$source" >&2
        exit 1
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        mkdir -p -- "${BACKUP_DIR}/originals/$(dirname "$relative_path")"
        cp -a -- "$target" "${BACKUP_DIR}/originals/${relative_path}"
    fi

    if [[ -L "$target" ]]; then
        rm -- "$target"
    fi

    mode=644
    if [[ "$relative_path" == scripts/* ]]; then
        mode=755
    fi
    install -D -m "$mode" "$source" "$target"
done

printf 'Installed MangoBar V1.1 to %s\n' "$CONFIG_DIR"
printf 'Existing managed files, if any, are backed up in %s\n' "$BACKUP_DIR"
printf 'Start MangoBar with: mangobar\n'
