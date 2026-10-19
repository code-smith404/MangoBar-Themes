#!/usr/bin/env bash
set -euo pipefail

if ! command -v ip >/dev/null 2>&1; then
    printf 'network-speed: iproute2 (ip) is required\n' >&2
    printf 'NET N/A\n'
    exit 1
fi

interface="$(
    ip -4 route show default 2>/dev/null |
        awk 'NR == 1 { for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit } }'
)"
if [[ -z "$interface" ]]; then
    interface="$(
        ip -6 route show default 2>/dev/null |
            awk 'NR == 1 { for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit } }'
    )"
fi

if [[ -z "$interface" ]]; then
    printf 'NET offline\n'
    exit 0
fi

if [[ ! "$interface" =~ ^[[:alnum:]_.:-]+$ ]]; then
    printf 'network-speed: invalid interface name\n' >&2
    printf 'NET N/A\n'
    exit 1
fi

interface_dir="/sys/class/net/${interface}/statistics"
if [[ ! -r "${interface_dir}/rx_bytes" || ! -r "${interface_dir}/tx_bytes" ]]; then
    printf 'NET offline\n'
    exit 0
fi

IFS= read -r rx_bytes < "${interface_dir}/rx_bytes"
IFS= read -r tx_bytes < "${interface_dir}/tx_bytes"
now="$(date +%s)"
cache_dir="${XDG_CACHE_HOME:-${HOME:?HOME must be set}/.cache}/mangobar"
mkdir -p -- "$cache_dir"
state_file="${cache_dir}/network-speed-${interface//[^[:alnum:]_.-]/_}"
temporary_file="${state_file}.$$"
trap 'rm -f -- "$temporary_file"' EXIT

if [[ -r "$state_file" ]]; then
    read -r old_rx old_tx old_time < "$state_file" || true
fi

if [[ "${old_rx:-}" =~ ^[0-9]+$ &&
      "${old_tx:-}" =~ ^[0-9]+$ &&
      "${old_time:-}" =~ ^[0-9]+$ &&
      "$rx_bytes" -ge "$old_rx" &&
      "$tx_bytes" -ge "$old_tx" &&
      "$now" -gt "$old_time" ]]; then
    awk -v rx="$rx_bytes" -v tx="$tx_bytes" \
        -v old_rx="$old_rx" -v old_tx="$old_tx" \
        -v seconds="$((now - old_time))" '
        function rate(bytes, elapsed) {
            value = bytes / elapsed / 1024
            if (value >= 1024)
                return sprintf("%.1fMB/s", value / 1024)
            return sprintf("%.0fKB/s", value)
        }
        BEGIN {
            printf "↓%s ↑%s\n",
                rate(rx - old_rx, seconds), rate(tx - old_tx, seconds)
        }
    '
else
    printf '↓0KB/s ↑0KB/s\n'
fi

printf '%s %s %s\n' "$rx_bytes" "$tx_bytes" "$now" > "$temporary_file"
mv -f -- "$temporary_file" "$state_file"
