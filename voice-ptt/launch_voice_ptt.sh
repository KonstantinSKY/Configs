#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$APP_DIR"

if [[ "$(uname)" == "Darwin" ]]; then
  exec "$APP_DIR/voice-ptt-macos"
else
  exec "$APP_DIR/voice-ptt"
fi
