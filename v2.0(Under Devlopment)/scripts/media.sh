#!/usr/bin/env bash
set -euo pipefail

if ! command -v playerctl >/dev/null 2>&1; then
  printf ' No media\n'
  exit 0
fi

status="$(playerctl status 2>/dev/null || true)"
if [[ -z "$status" || "$status" == "No players found" ]]; then
  printf ' No media\n'
  exit 0
fi

artist="$(playerctl metadata artist 2>/dev/null || true)"
title="$(playerctl metadata title 2>/dev/null || true)"
album="$(playerctl metadata album 2>/dev/null || true)"

if [[ -n "$artist" && -n "$title" ]]; then
  payload="$artist - $title"
  if [[ -n "$album" ]]; then
    payload+=" - $album"
  fi
  printf ' %s\n' "$payload"
else
  printf ' %s\n' "${title:-$status}"
fi
