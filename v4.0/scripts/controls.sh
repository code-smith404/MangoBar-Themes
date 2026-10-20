#!/usr/bin/env bash
set -euo pipefail

report_error() {
    local message="$1"
    if command -v notify-send >/dev/null 2>&1; then
        if ! notify-send --urgency=normal --app-name="MangoBar V4.0" "Bar action" "$message"; then
            printf 'MangoBar V4.0: %s\n' "$message" >&2
        fi
    else
        printf 'MangoBar V4.0: %s\n' "$message" >&2
    fi
}

launch_gui() {
    local application="$1"
    shift

    if ! command -v "$application" >/dev/null 2>&1; then
        report_error "${application} is not installed."
        return 127
    fi
    "$application" "$@" >/dev/null 2>&1 &
}

open_network_settings() {
    if command -v nm-connection-editor >/dev/null 2>&1; then
        launch_gui nm-connection-editor
    elif command -v gnome-control-center >/dev/null 2>&1; then
        launch_gui gnome-control-center wifi
    else
        report_error "Install nm-connection-editor or GNOME Control Center to manage network connections."
        return 127
    fi
}

open_notifications() {
    if ! command -v swaync-client >/dev/null 2>&1; then
        report_error "Install and run SwayNotificationCenter (swaync) to open the notification panel."
        return 127
    fi
    if ! swaync-client -t -sw; then
        report_error "Could not open the SwayNC notification panel. Check that swaync is running."
        return 1
    fi
}

open_calendar() {
    if command -v gnome-calendar >/dev/null 2>&1; then
        launch_gui gnome-calendar
    elif command -v gsimplecal >/dev/null 2>&1; then
        launch_gui gsimplecal
    elif command -v yad >/dev/null 2>&1; then
        launch_gui yad --calendar
    else
        report_error "Install GNOME Calendar, gsimplecal, or yad to open a calendar."
        return 127
    fi
}

open_system_monitor() {
    if command -v gnome-system-monitor >/dev/null 2>&1; then
        launch_gui gnome-system-monitor
    elif command -v missioncenter >/dev/null 2>&1; then
        launch_gui missioncenter
    elif command -v xfce4-taskmanager >/dev/null 2>&1; then
        launch_gui xfce4-taskmanager
    elif command -v mate-system-monitor >/dev/null 2>&1; then
        launch_gui mate-system-monitor
    else
        report_error "Install a system monitor (GNOME System Monitor, Mission Center, XFCE Task Manager, or MATE System Monitor)."
        return 127
    fi
}

case "${1:-}" in
    network)
        open_network_settings
        ;;
    notifications)
        open_notifications
        ;;
    calendar)
        open_calendar
        ;;
    system-monitor)
        open_system_monitor
        ;;
    *)
        printf 'Usage: %s {network|notifications|calendar|system-monitor}\n' "$0" >&2
        exit 2
        ;;
esac
