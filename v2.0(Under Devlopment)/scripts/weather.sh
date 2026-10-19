#!/usr/bin/env bash
set -euo pipefail

weather="$(curl -fsSL --max-time 7 'https://wttr.in/Ajeetpura,Bhadra,Hanumangarh,Rajasthan,India?format=%t' 2>/dev/null || true)"
if [[ -z "$weather" ]]; then
  printf ' --\n'
  exit 0
fi
printf ' %s\n' "$weather"
