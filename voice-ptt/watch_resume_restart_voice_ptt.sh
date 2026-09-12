#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${1:-voice-ptt.service}"
RESTART_DELAY="${VOICE_PTT_RESUME_RESTART_DELAY:-5}"
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/voice-ptt"
RESUME_HEADSETS_FILE="$STATE_DIR/resume-headsets"

echo "Watching logind sleep/resume signals; will restart ${SERVICE_NAME} after resume."

snapshot_connected_audio_devices() {
  mkdir -p "$STATE_DIR"
  : >"$RESUME_HEADSETS_FILE"

  bluetoothctl devices Connected | awk '/^Device / { print $2 }' | while IFS= read -r mac; do
    if bluetoothctl info "$mac" | grep -Eq 'Icon: audio-|UUID: (Headset|Handsfree|Audio Sink|Advanced Audio)'; then
      echo "$mac" >>"$RESUME_HEADSETS_FILE"
    fi
  done

  if [[ -s "$RESUME_HEADSETS_FILE" ]]; then
    echo "Recorded Bluetooth audio devices for resume recovery:"
    while IFS= read -r mac; do
      bluetoothctl info "$mac" | sed -n '/Name:/p;/Connected:/p'
    done <"$RESUME_HEADSETS_FILE"
  else
    echo "No connected Bluetooth audio devices recorded before suspend."
  fi
}

recover_recorded_audio_devices() {
  if [[ ! -s "$RESUME_HEADSETS_FILE" ]]; then
    echo "No pre-suspend Bluetooth audio devices to recover."
    return 0
  fi

  while IFS= read -r mac; do
    [[ -n "$mac" ]] || continue
    bash "$APP_DIR/recover_bluetooth_headset.sh" "$mac" || true
  done <"$RESUME_HEADSETS_FILE"
}

dbus-monitor --system "type='signal',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'" |
while IFS= read -r line; do
  case "$line" in
    *"boolean true"*)
      echo "Suspend detected."
      snapshot_connected_audio_devices
      ;;
    *"boolean false"*)
      echo "Resume detected; recovering audio stack and restarting ${SERVICE_NAME} after ${RESTART_DELAY}s."
      sleep "$RESTART_DELAY"
      recover_recorded_audio_devices
      systemctl --user restart "$SERVICE_NAME"
      echo "${SERVICE_NAME} restarted after resume."
      ;;
  esac
done
