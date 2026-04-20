#!/usr/bin/env bash
set -euo pipefail

sleep 3

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/voice-ptt.log"

if [[ "$(uname)" != "Darwin" ]]; then
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  export DISPLAY="${DISPLAY:-:0}"
  export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
fi

timestamp() {
  if date -Is >/dev/null 2>&1; then
    date -Is
  else
    date '+%Y-%m-%dT%H:%M:%S%z'
  fi
}

pkill -x voice-ptt 2>/dev/null || true
pkill -x voice-ptt-macos 2>/dev/null || true
sleep 0.5

cd "$APP_DIR"
{
  printf '==== %s ====\n' "$(timestamp)"
  if [[ "$(uname)" == "Darwin" ]]; then
    echo "platform=macOS"
  else
    echo "DISPLAY=$DISPLAY"
    echo "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
    echo "XAUTHORITY=$XAUTHORITY"
  fi
} >"$LOG_FILE"
if [[ "$(uname)" == "Darwin" ]]; then
  BINARY="$APP_DIR/voice-ptt-macos"
else
  BINARY="$APP_DIR/voice-ptt"
fi
nohup "$BINARY" >>"$LOG_FILE" 2>&1 &
CHILD_PID=$!
sleep 1

if kill -0 "$CHILD_PID" 2>/dev/null || pgrep -x voice-ptt >/dev/null 2>&1 || pgrep -x voice-ptt-macos >/dev/null 2>&1; then
  echo "voice-ptt started"
else
  echo "voice-ptt failed to start"
fi

echo "--- log tail ---"
tail -n 40 "$LOG_FILE" || true
