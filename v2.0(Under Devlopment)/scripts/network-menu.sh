#!/usr/bin/env bash
set -euo pipefail

if command -v wofi >/dev/null 2>&1; then
  nmcli device wifi list | tail -n +1 | wofi --dmenu --show dmenu || true
elif command -v rofi >/dev/null 2>&1; then
  nmcli device wifi list | tail -n +1 | rofi -dmenu || true
else
  nmcli device wifi list
fi
