#!/usr/bin/env bash
set -euo pipefail

# MangoBar Themes Installer
# Supports both local execution (./install.sh) and remote execution (curl | bash)

REPO_URL="https://github.com/code-smith404/MangoBar-Themes.git"
RAW_BASE_URL="https://raw.githubusercontent.com/code-smith404/MangoBar-Themes/main"
CONFIG_DIR="${HOME:?HOME must be set}/.config/mangobar"

TEMP_DIR=""
CLEANUP_NEEDED=false

cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" && "$CLEANUP_NEEDED" == true ]]; then
        rm -rf -- "$TEMP_DIR"
    fi
}
trap cleanup EXIT

usage() {
    cat <<'EOF'
MangoBar Themes Installer

Usage: install.sh [options]

Options:
  --theme <version>   Theme to install (1.0, 1.1, 2.0, 3.0, 4.0)
  --yes               Skip confirmation prompts
  --help              Show this help and exit

Environment variables:
  MANGOBAR_THEME      Theme version to install (same values as --theme)

Examples:
  # Interactive (local or remote)
  ./install.sh
  curl -fsSL https://raw.githubusercontent.com/code-smith404/MangoBar-Themes/main/install.sh | bash

  # Non-interactive
  ./install.sh --theme 4.0 --yes
  curl -fsSL https://raw.githubusercontent.com/code-smith404/MangoBar-Themes/main/install.sh | bash -s -- --theme 4.0 --yes
  MANGOBAR_THEME=3.0 bash <(curl -fsSL https://raw.githubusercontent.com/code-smith404/MangoBar-Themes/main/install.sh)
EOF
}

# Parse command-line arguments
THEME_ARG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --theme)
            if [[ $# -lt 2 ]]; then
                printf 'Error: --theme requires a version argument\n' >&2
                exit 1
            fi
            THEME_ARG="$2"
            shift 2
            ;;
        --yes)
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            printf 'Error: unknown option %q\n' "$1" >&2
            usage
            exit 1
            ;;
    esac
done

# Determine theme from argument or environment
SELECTED_THEME="${THEME_ARG:-${MANGOBAR_THEME:-}}"

# Check if we're running from a pipe (stdin is not a terminal)
# If so, we need to download the repo and read prompts from /dev/tty
IS_PIPED=false
if [[ ! -t 0 ]]; then
    IS_PIPED=true
fi

# Determine the theme directory (where theme files are located)
if [[ "$IS_PIPED" == true ]]; then
    # Running via curl | bash - need to download the repo
    if ! command -v git >/dev/null 2>&1 && ! command -v curl >/dev/null 2>&1; then
        printf 'Error: neither git nor curl is available. Cannot download themes.\n' >&2
        exit 1
    fi

    TEMP_DIR="$(mktemp -d -t mangobar-themes-XXXXXX)"
    CLEANUP_NEEDED=true

    if command -v git >/dev/null 2>&1; then
        printf 'Downloading MangoBar-Themes (shallow clone)...\n'
        if ! git clone --depth 1 --quiet "$REPO_URL" "$TEMP_DIR" 2>/dev/null; then
            printf 'Error: git clone failed\n' >&2
            exit 1
        fi
    else
        printf 'Downloading MangoBar-Themes (tarball)...\n'
        if ! curl -fsSL "$RAW_BASE_URL.tar.gz" | tar -xz -C "$TEMP_DIR" --strip-components=1 2>/dev/null; then
            printf 'Error: curl download failed\n' >&2
            exit 1
        fi
    fi

    THEME_DIR="$TEMP_DIR"
else
    # Running locally - use the script's directory
    THEME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
fi

# Map theme selection to version, path, backup name, and file lists
map_theme() {
    local choice="$1"
    case "$choice" in
        1|V1.0|v1.0|1.0)
            version='V1.0'
            theme_path='v1.0'
            backup_name='mangobar-v1.0-backup'
            managed_files=(config.jsonc style.css)
            obsolete_files=()
            ;;
        2|V1.1|v1.1|1.1)
            version='V1.1'
            theme_path='v1.1'
            backup_name='mangobar-v1.1-backup'
            managed_files=(config.jsonc style.css scripts/network-speed.sh)
            obsolete_files=()
            ;;
        3|V2.0|v2.0|2.0)
            version='V2.0'
            theme_path='v2.0(Under Devlopment)'
            backup_name='mangobar-v2-backup'
            managed_files=(config.jsonc style.css wallpaper.svg)
            obsolete_files=(
                cava.conf
                theme.conf
                scripts/cava-visualizer.sh
                scripts/cursor-switch.sh
                scripts/gamemode.sh
                scripts/idle-toggle.sh
                scripts/media.sh
                scripts/network-menu.sh
                scripts/power-menu.sh
                scripts/visualizer-toggle.sh
                scripts/weather.sh
                scripts/volume.sh
            )
            ;;
        4|V3.0|v3.0|3.0)
            version='V3.0'
            theme_path='v3.0'
            backup_name='mangobar-v3.0-backup'
            managed_files=(config.jsonc style.css scripts/menu.sh scripts/power-menu.sh)
            obsolete_files=()
            ;;
        5|V4.0|v4.0|4.0)
            version='V4.0'
            theme_path='v4.0'
            backup_name='mangobar-v4.0-backup'
            managed_files=(config.jsonc style.css scripts/controls.sh scripts/power-menu.sh)
            obsolete_files=()
            ;;
        *)
            return 1
            ;;
    esac
    return 0
}

# If theme not provided via arg/env, prompt interactively
if [[ -z "$SELECTED_THEME" ]]; then
    printf 'Choose a MangoBar theme to install:\n'
    printf '  1) V1.0\n'
    printf '  2) V1.1\n'
    printf '  3) V2.0 (Under Development)\n'
    printf '  4) V3.0 (Mist Lake)\n'
    printf '  5) V4.0 (Square)\n'

    if [[ "$IS_PIPED" == true ]]; then
        if ! read -r -p 'Enter 1, 2, 3, 4, or 5: ' choice < /dev/tty; then
            printf 'Error: no theme choice was provided.\n' >&2
            exit 1
        fi
    else
        if ! read -r -p 'Enter 1, 2, 3, 4, or 5: ' choice; then
            printf 'Error: no theme choice was provided.\n' >&2
            exit 1
        fi
    fi

    if ! map_theme "$choice"; then
        printf 'Error: invalid theme choice %q. Enter 1, 2, 3, 4, or 5.\n' "$choice" >&2
        exit 1
    fi
else
    if ! map_theme "$SELECTED_THEME"; then
        printf 'Error: invalid theme %q. Use 1.0, 1.1, 2.0, 3.0, or 4.0\n' "$SELECTED_THEME" >&2
        exit 1
    fi
fi

# Verify all required theme files exist
for relative_path in "${managed_files[@]}"; do
    source="${THEME_DIR}/${theme_path}/${relative_path}"
    if [[ ! -f "$source" ]]; then
        printf 'Error: required theme file is missing: %s\n' "$source" >&2
        exit 1
    fi
done

# Check for directory conflicts
for relative_path in "${managed_files[@]}" "${obsolete_files[@]}"; do
    target="${CONFIG_DIR}/${relative_path}"
    if [[ -d "$target" && ! -L "$target" ]]; then
        printf 'Error: refusing to replace a directory at %s\n' "$target" >&2
        exit 1
    fi
done

# Backup existing ~/.config/mangobar to ~/.config/mangobar.bak.<timestamp>
if [[ -d "$CONFIG_DIR" || -L "$CONFIG_DIR" ]]; then
    BACKUP_TIMESTAMP="$(date +%Y%m%d-%H%M%S)-$$"
    BACKUP_DIR="${HOME}/.config/mangobar.bak.${BACKUP_TIMESTAMP}"
    printf 'Backing up existing %s to %s\n' "$CONFIG_DIR" "$BACKUP_DIR"
    mv -- "$CONFIG_DIR" "$BACKUP_DIR"
fi

# Create fresh config directory
mkdir -p -- "$CONFIG_DIR"

# Theme-specific backup directory for installed files (V2.0, V3.0, V4.0)
THEME_BACKUP_DIR="${HOME}/.config/${backup_name}-$(date +%Y%m%d-%H%M%S)-$$"
if [[ "$version" == 'V2.0' || "$version" == 'V3.0' || "$version" == 'V4.0' ]]; then
    mkdir -p -- "${THEME_BACKUP_DIR}/installed"
fi

backup_original() {
    local relative_path="$1"
    local target="${CONFIG_DIR}/${relative_path}"

    if [[ -e "$target" || -L "$target" ]]; then
        mkdir -p -- "${THEME_BACKUP_DIR}/originals/$(dirname "$relative_path")"
        cp -a -- "$target" "${THEME_BACKUP_DIR}/originals/${relative_path}"
    fi
}

# Install theme files
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

    if [[ "$version" == 'V2.0' || "$version" == 'V3.0' || "$version" == 'V4.0' ]]; then
        mkdir -p -- "${THEME_BACKUP_DIR}/installed/$(dirname "$relative_path")"
        cp -a -- "$target" "${THEME_BACKUP_DIR}/installed/${relative_path}"
    fi
done

# Remove obsolete files (V2.0 only)
for relative_path in "${obsolete_files[@]}"; do
    backup_original "$relative_path"
    rm -f -- "${CONFIG_DIR}/${relative_path}"
done

printf 'Successfully installed MangoBar %s to %s\n' "$version" "$CONFIG_DIR"
if [[ "$version" == 'V2.0' || "$version" == 'V3.0' || "$version" == 'V4.0' ]]; then
    printf 'Theme files backed up in %s\n' "$THEME_BACKUP_DIR"
fi
if compgen -G "${HOME}/.config/mangobar.bak.*" >/dev/null; then
    printf 'Previous mangobar config backed up to %s\n' "${HOME}/.config/mangobar.bak."*
fi
printf 'Restart MangoBar to apply the theme: mangobar\n'