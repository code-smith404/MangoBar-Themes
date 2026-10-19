#!/usr/bin/env bash
set -euo pipefail

STATE="${HOME}/.cache/mangobar/visualizer"
mkdir -p "$(dirname "$STATE")"

if [[ -f "$STATE" ]]; then
  rm -f "$STATE"
  pkill -f 'cava' || true
  printf 'visualizer off\n'
else
  touch "$STATE"
  cava -p "${HOME}/.config/mangobar/cava.conf" >/dev/null 2>&1 &
  printf 'visualizer on\n'
fi
