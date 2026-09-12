#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${1:-voice-ptt.service}"
RESTART_DELAY="${VOICE_PTT_RESUME_RESTART_DELAY:-5}"

echo "Watching logind sleep/resume signals; will restart ${SERVICE_NAME} after resume."

dbus-monitor --system "type='signal',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'" |
while IFS= read -r line; do
  case "$line" in
    *"boolean true"*)
      echo "Suspend detected."
      ;;
    *"boolean false"*)
      echo "Resume detected; restarting ${SERVICE_NAME} after ${RESTART_DELAY}s."
      sleep "$RESTART_DELAY"
      systemctl --user restart "$SERVICE_NAME"
      echo "${SERVICE_NAME} restarted after resume."
      ;;
  esac
done
