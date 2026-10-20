#!/usr/bin/env bash
set -euo pipefail

report_error() {
    local message="$1"
    if command -v notify-send >/dev/null 2>&1; then
        if ! notify-send --urgency=critical --app-name="MangoBar V4.0" "Power menu" "$message"; then
            printf 'MangoBar V4.0: %s\n' "$message" >&2
        fi
    else
        printf 'MangoBar V4.0: %s\n' "$message" >&2
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
        return 127
    fi
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
            report_error "Install wofi, rofi, or fuzzel to use the power menu."
            return 2
        fi
        report_error "The confirmation menu failed to open."
        return 2
    fi
}

if selection="$(show_menu "Power" "Lock screen" "Log out" "Restart" "Power off" "Cancel")"; then
    :
else
    status=$?
    if (( status == 1 )); then
        exit 0
    elif (( status == 127 )); then
        report_error "Install wofi, rofi, or fuzzel to use the power menu."
        exit "$status"
    fi
    report_error "The power menu failed to open."
    exit "$status"
fi

case "$selection" in
    "Lock screen")
        if command -v swaylock >/dev/null 2>&1; then
            swaylock
        elif command -v gtklock >/dev/null 2>&1; then
            gtklock
        else
            report_error "Install swaylock or gtklock to lock the screen."
            exit 127
        fi
        ;;
    "Log out")
        if [[ -z "${XDG_SESSION_ID:-}" ]]; then
            report_error "XDG_SESSION_ID is missing; refusing to log out an unspecified session."
            exit 1
        fi
        if confirm_action "log out"; then
            if ! loginctl terminate-session "$XDG_SESSION_ID"; then
                report_error "Could not end session ${XDG_SESSION_ID}."
                exit 1
            fi
        else
            status=$?
            if (( status > 1 )); then
                exit "$status"
            fi
        fi
        ;;
    "Restart")
        if confirm_action "restart"; then
            if ! systemctl reboot; then
                report_error "The system refused the reboot request."
                exit 1
            fi
        else
            status=$?
            if (( status > 1 )); then
                exit "$status"
            fi
        fi
        ;;
    "Power off")
        if confirm_action "power off"; then
            if ! systemctl poweroff; then
                report_error "The system refused the power-off request."
                exit 1
            fi
        else
            status=$?
            if (( status > 1 )); then
                exit "$status"
            fi
        fi
        ;;
    "Cancel" | "")
        exit 0
        ;;
esac
