#!/usr/bin/env bash
# Перезапускает voice-ptt, когда меняется микрофон по умолчанию
# (например, Bluetooth-наушники включили/выключили): voice-ptt сам не
# переподключается к новому устройству и зависает в ошибках ALSA.
set -uo pipefail

SERVICE_NAME="${1:-voice-ptt.service}"
SETTLE="${VOICE_PTT_AUDIO_SETTLE_DELAY:-2}"

# Имя + номер узла: номер меняется, даже если устройство пересоздано с тем же
# именем (смена Bluetooth-кодека/профиля, перезапуск WirePlumber).
current_source() {
  local name
  name="$(pactl get-default-source 2>/dev/null)" || return 0
  printf '%s#%s' "$name" "$(pactl list short sources | awk -v n="$name" '$2==n {print $1; exit}')"
}

last="$(current_source)"
echo "Watching default audio source (now: ${last:-none}); will restart ${SERVICE_NAME} on change."

pactl subscribe | while IFS= read -r line; do
  case "$line" in
    *"on server"*|*"'remove' on source"*|*"'new' on source"*) ;;
    *) continue ;;
  esac
  sleep "$SETTLE"
  now="$(current_source)"
  if [[ -n "$now" && "$now" != *"#" && "$now" != "$last" ]]; then
    echo "Default source changed: ${last:-none} -> ${now}; restarting ${SERVICE_NAME}."
    last="$now"
    systemctl --user restart "$SERVICE_NAME"
  fi
done
