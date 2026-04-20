#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_NAME="com.sky.voice-ptt.plist"
SOURCE_PLIST="$APP_DIR/$PLIST_NAME"
TARGET_DIR="$HOME/Library/LaunchAgents"
TARGET_PLIST="$TARGET_DIR/$PLIST_NAME"
LABEL="com.sky.voice-ptt"
DOMAIN="gui/$(id -u)"

mkdir -p "$TARGET_DIR"
install -m 644 "$SOURCE_PLIST" "$TARGET_PLIST"

launchctl bootout "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
launchctl bootstrap "$DOMAIN" "$TARGET_PLIST"
launchctl enable "$DOMAIN/$LABEL"
launchctl kickstart -k "$DOMAIN/$LABEL"

echo "Installed $TARGET_PLIST"
echo "Loaded $DOMAIN/$LABEL"
