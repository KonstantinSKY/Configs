#!/usr/bin/env bash
set -euo pipefail

HEADSET_MAC="${1:-${VOICE_PTT_HEADSET_MAC:-3C:68:16:4D:BE:89}}"
TRIES="${VOICE_PTT_HEADSET_CONNECT_TRIES:-6}"
DELAY="${VOICE_PTT_HEADSET_CONNECT_DELAY:-2}"

echo "Recovering Bluetooth headset ${HEADSET_MAC}."

systemctl --user restart wireplumber.service || true
sleep 2

bluetoothctl power on || true
bluetoothctl trust "$HEADSET_MAC" || true
bluetoothctl disconnect "$HEADSET_MAC" || true
sleep 1

for attempt in $(seq 1 "$TRIES"); do
  echo "Connecting ${HEADSET_MAC}, attempt ${attempt}/${TRIES}."
  if bluetoothctl connect "$HEADSET_MAC"; then
    echo "Bluetooth headset ${HEADSET_MAC} connected."
    bluetoothctl info "$HEADSET_MAC" | sed -n '/Name:/p;/Connected:/p;/Battery Percentage:/p'
    exit 0
  fi
  sleep "$DELAY"
done

echo "Bluetooth headset ${HEADSET_MAC} did not reconnect after ${TRIES} attempts." >&2
bluetoothctl info "$HEADSET_MAC" | sed -n '/Name:/p;/Connected:/p;/Blocked:/p;/Trusted:/p' || true
exit 1
