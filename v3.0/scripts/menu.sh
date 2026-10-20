#!/usr/bin/env bash
set -euo pipefail

report_error() {
    printf 'Lumen menu: %s\n' "$1" >&2
}

show_menu() {
    local prompt="$1"
    shift

    if command -v wofi >/dev/null 2>&1; then
        printf '%s\n' "$@" | wofi --dmenu --prompt "$prompt"
    elif command -v rofi >/dev/null 2>&1; then
        printf '%s\n' "$@" | rofi -dmenu -i -p "$prompt"
    elif command -v fuzzel >/dev/null 2>&1; then
        printf '%s\n' "$@" | fuzzel --dmenu --prompt="$prompt"
    else
        report_error "Install wofi, rofi, or fuzzel to open menu actions."
        return 127
    fi
}

open_path() {
    local path="$1"
    if ! command -v xdg-open >/dev/null 2>&1; then
        report_error "xdg-open is required to open file locations."
        return 127
    fi
    xdg-open "$path" >/dev/null 2>&1 &
}

open_file_manager() {
    local manager
    for manager in thunar nautilus dolphin pcmanfm; do
        if command -v "$manager" >/dev/null 2>&1; then
            "$manager" "$HOME" >/dev/null 2>&1 &
            return 0
        fi
    done
    open_path "$HOME"
}

launch_app_menu() {
    if command -v wofi >/dev/null 2>&1; then
        wofi --show drun
    elif command -v rofi >/dev/null 2>&1; then
        rofi -show drun
    elif command -v fuzzel >/dev/null 2>&1; then
        fuzzel
    else
        report_error "Install wofi, rofi, or fuzzel to open the applications menu."
        return 127
    fi
}

choose_action() {
    local prompt="$1"
    shift
    local action
    local status

    if action="$(show_menu "$prompt" "$@")"; then
        printf '%s' "$action"
        return 0
    else
        status=$?
        if (( status == 1 )); then
            return 1
        fi
        return "$status"
    fi
}

case "${1:-}" in
    workspace)
        if action="$(choose_action "Workspace" \
            "Previous occupied workspace" \
            "Next occupied workspace")"; then
            case "$action" in
                "Previous occupied workspace")
                    mmsg dispatch viewtoleft_have_client
                    ;;
                "Next occupied workspace")
                    mmsg dispatch viewtoright_have_client
                    ;;
            esac
        else
            status=$?
            (( status == 1 )) && exit 0
            exit "$status"
        fi
        ;;
    apps)
        launch_app_menu
        ;;
    files)
        if action="$(choose_action "Files" \
            "Open Home" \
            "Open Downloads" \
            "Open File Manager")"; then
            case "$action" in
                "Open Home")
                    open_path "$HOME"
                    ;;
                "Open Downloads")
                    open_path "${HOME}/Downloads"
                    ;;
                "Open File Manager")
                    open_file_manager
                    ;;
            esac
        else
            status=$?
            (( status == 1 )) && exit 0
            exit "$status"
        fi
        ;;
    help)
        if action="$(choose_action "Help" \
            "MangoBar documentation" \
            "MangoWM documentation")"; then
            case "$action" in
                "MangoBar documentation")
                    open_path "https://github.com/mangowm/mangobar/wiki"
                    ;;
                "MangoWM documentation")
                    open_path "https://github.com/mangowm/mangowm"
                    ;;
            esac
        else
            status=$?
            (( status == 1 )) && exit 0
            exit "$status"
        fi
        ;;
    *)
        report_error "Unknown menu. Use: workspace, apps, files, or help."
        exit 2
        ;;
esac
