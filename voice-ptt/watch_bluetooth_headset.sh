#!/usr/bin/env bash
set -euo pipefail

HEADSET_MAC="${1:-${VOICE_PTT_HEADSET_MAC:-3C:68:16:4D:BE:89}}"
INTERVAL="${VOICE_PTT_HEADSET_WATCH_INTERVAL:-30}"

echo "Watching Bluetooth headset ${HEADSET_MAC}; reconnect interval ${INTERVAL}s."

while true; do
  if ! bluetoothctl info "$HEADSET_MAC" | grep -q 'Connected: yes'; then
    echo "Bluetooth headset ${HEADSET_MAC} is disconnected; attempting reconnect."
    bluetoothctl power on || true
    bluetoothctl connect "$HEADSET_MAC" || true
  fi
  sleep "$INTERVAL"
done
