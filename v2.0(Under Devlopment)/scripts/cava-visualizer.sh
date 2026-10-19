#!/usr/bin/env bash
set -euo pipefail

CONFIG="${HOME}/.config/mangobar/cava.conf"
if ! command -v cava >/dev/null 2>&1; then
  printf 'Cava is required for the audio visualizer\n' >&2
  exit 127
fi
if [[ ! -r "$CONFIG" ]]; then
  printf 'Cava configuration is not readable: %s\n' "$CONFIG" >&2
  exit 1
fi

glyphs=(" " "▂" "▃" "▄" "▅" "▆" "▇" "█")

cava -p "$CONFIG" | while IFS= read -r frame; do
  IFS=';' read -r -a levels <<< "$frame"
  graph=""
  for level in "${levels[@]}"; do
    level="${level%%.*}"
    [[ "$level" =~ ^[0-9]+$ ]] || level=0
    (( level > 7 )) && level=7
    graph+="${glyphs[level]}"
  done
  printf '%s\n' "$graph"
done
