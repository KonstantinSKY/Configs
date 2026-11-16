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

# MAC-адреса Bluetooth-наушников, у которых сейчас есть микрофон.
bt_macs() {
  pactl list short sources 2>/dev/null | awk '$2 ~ /^bluez_input\./ { sub(/^bluez_input\./, "", $2); print $2 }' | sort -u
}

# Последние подключённые наушники становятся звуком и микрофоном по умолчанию,
# чтобы при смене наушников не переключать устройства вручную. Если появилось
# сразу несколько (перезапуск WirePlumber), выбор не меняется.
follow_new_headset() {
  local now_macs new mac sink
  now_macs="$(bt_macs)"
  new="$(comm -13 <(printf '%s\n' "$bt_known") <(printf '%s\n' "$now_macs") | sed '/^$/d')"
  bt_known="$now_macs"
  [[ -n "$new" && "$(wc -l <<<"$new")" -eq 1 ]] || return 0
  mac="$new"
  sink="$(pactl list short sinks | awk -v p="bluez_output.${mac//:/_}" 'index($2, p) == 1 { print $2; exit }')"
  echo "Headset ${mac} connected; making it the default mic${sink:+ and output}."
  pactl set-default-source "bluez_input.${mac}"
  [[ -n "$sink" ]] && pactl set-default-sink "$sink"
}

bt_known="$(bt_macs)"
last="$(current_source)"
echo "Watching default audio source (now: ${last:-none}); will restart ${SERVICE_NAME} on change."

pactl subscribe | while IFS= read -r line; do
  case "$line" in
    *"on server"*|*"'remove' on source"*|*"'new' on source"*) ;;
    *) continue ;;
  esac
  sleep "$SETTLE"
  follow_new_headset
  now="$(current_source)"
  if [[ -n "$now" && "$now" != *"#" && "$now" != "$last" ]]; then
    echo "Default source changed: ${last:-none} -> ${now}; restarting ${SERVICE_NAME}."
    last="$now"
    systemctl --user restart "$SERVICE_NAME"
  fi
done
