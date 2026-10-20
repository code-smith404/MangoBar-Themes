#!/usr/bin/env bash
set -euo pipefail

report_error() {
    local message="$1"
    if command -v notify-send >/dev/null 2>&1; then
        if ! notify-send --urgency=critical --app-name="macOS Dark" "Menu" "$message"; then
            printf 'macOS Dark: %s\n' "$message" >&2
        fi
    else
        printf 'macOS Dark: %s\n' "$message" >&2
    fi
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
        report_error "Install wofi, rofi, or fuzzel to use desktop menus."
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
    else
        status=$?
        if (( status == 1 )); then
            return 1
        fi
        return "$status"
    fi
}

open_path() {
    local path="$1"
    if ! command -v xdg-open >/dev/null 2>&1; then
        report_error "xdg-open is required to open this location."
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

launch_apps() {
    if command -v wofi >/dev/null 2>&1; then
        wofi --show drun
    elif command -v rofi >/dev/null 2>&1; then
        rofi -show drun
    elif command -v fuzzel >/dev/null 2>&1; then
        fuzzel
    else
        report_error "Install wofi, rofi, or fuzzel to open applications."
        return 127
    fi
}

run_desktop_menu() {
    local menu="$1"
    local action
    local status

    case "$menu" in
        apps)
            launch_apps
            ;;
        files)
            if action="$(choose_action "Files" "Home" "Downloads" "File Manager")"; then
                case "$action" in
                    Home) open_path "$HOME" ;;
                    Downloads) open_path "${HOME}/Downloads" ;;
                    "File Manager") open_file_manager ;;
                esac
            else
                status=$?
                (( status == 1 )) && return 0
                return "$status"
            fi
            ;;
        help)
            if action="$(choose_action "Help" "MangoBar Documentation" "MangoWM Documentation")"; then
                case "$action" in
                    "MangoBar Documentation")
                        open_path "https://github.com/mangowm/mangobar/wiki"
                        ;;
                    "MangoWM Documentation")
                        open_path "https://github.com/mangowm/mangowm"
                        ;;
                esac
            else
                status=$?
                (( status == 1 )) && return 0
                return "$status"
            fi
            ;;
        *)
            report_error "Unknown menu: ${menu}"
            return 2
            ;;
    esac
}

confirm_action() {
    local action="$1"
    local confirmation
    local status

    if confirmation="$(show_menu "Confirm ${action}" "Cancel" "YES - ${action}")"; then
        [[ "$confirmation" == "YES - ${action}" ]]
    else
        status=$?
        if (( status == 1 )); then
            return 1
        elif (( status == 127 )); then
            return 2
        fi
        report_error "The confirmation menu failed to open."
        return 2
    fi
}

run_power_menu() {
    local selection
    local status

    if selection="$(show_menu "Power" "Log out" "Restart" "Power off" "Cancel")"; then
        :
    else
        status=$?
        if (( status == 1 )); then
            return 0
        fi
        return "$status"
    fi

    case "$selection" in
        "Log out")
            if [[ -z "${XDG_SESSION_ID:-}" ]]; then
                report_error "XDG_SESSION_ID is missing; refusing to log out an unspecified session."
                return 1
            fi
            if confirm_action "log out"; then
                if ! loginctl terminate-session "$XDG_SESSION_ID"; then
                    report_error "Could not end session ${XDG_SESSION_ID}."
                    return 1
                fi
            fi
            ;;
        "Restart")
            if confirm_action "restart" && ! systemctl reboot; then
                report_error "The system refused the reboot request."
                return 1
            fi
            ;;
        "Power off")
            if confirm_action "power off" && ! systemctl poweroff; then
                report_error "The system refused the power-off request."
                return 1
            fi
            ;;
        "Cancel" | "")
            return 0
            ;;
    esac
}

if (($# > 0)); then
    run_desktop_menu "$1"
else
    run_power_menu
fi
