#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${HOME}/.cache/mangobar"
STATE_FILE="${STATE_DIR}/gamemode"
mkdir -p "$STATE_DIR"

case "${1:-toggle}" in
  toggle)
    if [[ -f "$STATE_FILE" ]]; then
      rm -f "$STATE_FILE"
      echo "game mode off"
    else
      touch "$STATE_FILE"
      echo "game mode on"
    fi
    ;;
  status)
    printf '\n'
    ;;
  *)
    printf 'usage: %s [toggle|status]\n' "$0"
    ;;
esac
