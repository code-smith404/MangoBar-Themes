#!/usr/bin/env bash
set -euo pipefail

case "${1:-status}" in
  mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    ;;
  up)
    wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
    ;;
  down)
    wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-
    ;;
  switch)
    mapfile -t sinks < <(pactl list short sinks | awk '{print $2}')
    if [[ ${#sinks[@]} -ge 2 ]]; then
      pactl set-default-sink "${sinks[1]}"
    fi
    ;;
  status)
    vol="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2}')"
    printf '%s\n' "${vol:-0}"
    ;;
  *)
    printf 'usage: %s [mute|up|down|switch|status]\n' "$0"
    ;;
esac
