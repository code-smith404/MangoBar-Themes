#!/usr/bin/env bash
set -euo pipefail

opts=("lock" "logout" "reboot" "shutdown")
if command -v wofi >/dev/null 2>&1; then
  choice="$(printf '%s\n' "${opts[@]}" | wofi --dmenu)"
elif command -v rofi >/dev/null 2>&1; then
  choice="$(printf '%s\n' "${opts[@]}" | rofi -dmenu)"
else
  choice=""
fi

case "$choice" in
  lock)
    loginctl lock-session || true
    ;;
  logout)
    pkill -KILL -u "$USER" || true
    ;;
  reboot)
    systemctl reboot || loginctl reboot || true
    ;;
  shutdown)
    systemctl poweroff || loginctl poweroff || true
    ;;
  *)
    ;;
esac
