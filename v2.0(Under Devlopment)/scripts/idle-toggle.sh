#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${HOME}/.cache/mangobar"
STATE_FILE="${STATE_DIR}/idle"
mkdir -p "$STATE_DIR"

case "${1:-toggle}" in
  toggle)
    if [[ -f "$STATE_FILE" ]]; then
      rm -f "$STATE_FILE"
      pkill -f 'systemd-inhibit.*mangobar' || true
      echo "idle inhibitor off"
    else
      touch "$STATE_FILE"
      systemd-inhibit --what=idle --why='MangoBar idle inhibitor' --mode=block bash -c 'sleep infinity' >/dev/null 2>&1 &
      echo "idle inhibitor on"
    fi
    ;;
  status)
    if [[ -f "$STATE_FILE" ]]; then
      printf '󰈈\n'
    else
      printf '󰈉\n'
    fi
    ;;
  *)
    printf 'usage: %s [toggle|status]\n' "$0"
    ;;
esac
