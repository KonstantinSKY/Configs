#!/usr/bin/env bash
set -euo pipefail

sleep 3

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/voice-ptt.log"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DISPLAY="${DISPLAY:-:0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"

pkill -x voice-ptt 2>/dev/null || true
sleep 0.5

cd "$APP_DIR"
{
  echo "==== $(date -Is) ===="
  echo "DISPLAY=$DISPLAY"
  echo "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
  echo "XAUTHORITY=$XAUTHORITY"
} >"$LOG_FILE"
nohup "$APP_DIR/voice-ptt" >>"$LOG_FILE" 2>&1 &
sleep 1

if pgrep -x voice-ptt >/dev/null; then
  echo "voice-ptt started"
else
  echo "voice-ptt failed to start"
fi

echo "--- log tail ---"
tail -n 40 "$LOG_FILE" || true
