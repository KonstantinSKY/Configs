#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIREFOX_DIR="${HOME}/.config/mozilla/firefox"
PROFILE_NAME="sky"
PROFILE_PATH="sky.profile"

USER_JS_SRC="${SCRIPT_DIR}/user.js"
USER_CHROME_SRC="${SCRIPT_DIR}/chrome/userChrome.css"
USER_CONTENT_SRC="${SCRIPT_DIR}/chrome/userContent.css"

die() {
    printf 'Error: %s\n' "$1" >&2
    exit 1
}

require_file() {
    [ -f "$1" ] || die "missing file: $1"
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

profile_running() {
    pgrep -x firefox >/dev/null 2>&1
}

read_ini_value() {
    local file="$1"
    local key="$2"
    awk -F= -v key="$key" '$1 == key { print substr($0, index($0, "=") + 1); exit }' "$file"
}

find_active_profile_path() {
    local installs_ini="${FIREFOX_DIR}/installs.ini"
    local profiles_ini="${FIREFOX_DIR}/profiles.ini"
    local install_default=""
    local profile_path=""

    [ -f "$profiles_ini" ] || die "Firefox profiles.ini not found: $profiles_ini"

    if [ -f "$installs_ini" ]; then
        install_default="$(read_ini_value "$installs_ini" "Default" || true)"
    fi

    if [ -n "$install_default" ]; then
        printf '%s\n' "$install_default"
        return 0
    fi

    profile_path="$(awk -F= '
        /^\[Profile/ { in_profile=1; is_default=0; path="" }
        in_profile && $1 == "Default" && $2 == "1" { is_default=1 }
        in_profile && $1 == "Path" { path=substr($0, index($0, "=") + 1) }
        /^\[/ && !/^\[Profile/ && in_profile {
            if (is_default && path != "") { print path; exit }
            in_profile=0
        }
        END {
            if (in_profile && is_default && path != "") print path
        }
    ' "$profiles_ini")"

    [ -n "$profile_path" ] || die "could not determine active Firefox profile"
    printf '%s\n' "$profile_path"
}

ensure_firefox_dir() {
    mkdir -p "$FIREFOX_DIR"
}

ensure_profiles_ini() {
    local profiles_ini="${FIREFOX_DIR}/profiles.ini"
    if [ ! -f "$profiles_ini" ]; then
        cat >"$profiles_ini" <<EOF
[General]
StartWithLastProfile=1
Version=2
EOF
    fi
}

normalize_profile() {
    local current_path="$1"
    local current_dir="${FIREFOX_DIR}/${current_path}"
    local target_dir="${FIREFOX_DIR}/${PROFILE_PATH}"
    local profiles_ini="${FIREFOX_DIR}/profiles.ini"
    local installs_ini="${FIREFOX_DIR}/installs.ini"

    [ -d "$current_dir" ] || die "profile directory not found: $current_dir"

    if [ "$current_path" != "$PROFILE_PATH" ]; then
        if profile_running; then
            die "Firefox is running. Close it before renaming the profile directory."
        fi
        if [ -e "$target_dir" ]; then
            die "target profile path already exists: $target_dir"
        fi
        mv "$current_dir" "$target_dir"
        current_path="$PROFILE_PATH"
    fi

    awk -F= -v path="$current_path" -v name="$PROFILE_NAME" '
        BEGIN { in_profile=0 }
        /^\[Profile/ {
            in_profile=1
            profile_path=""
            print
            next
        }
        /^\[/ {
            in_profile=0
        }
        in_profile && $1 == "Path" && $2 == path {
            profile_path=path
            print
            next
        }
        in_profile && profile_path == path && $1 == "Name" {
            print "Name=" name
            next
        }
        { print }
    ' "$profiles_ini" > "${profiles_ini}.tmp"
    mv "${profiles_ini}.tmp" "$profiles_ini"

    if [ -f "$installs_ini" ]; then
        awk -F= -v path="$current_path" '
            $1 == "Default" && $2 == path { print; next }
            $1 == "Default" { print "Default=" path; next }
            { print }
        ' "$installs_ini" > "${installs_ini}.tmp"
        mv "${installs_ini}.tmp" "$installs_ini"
    fi
}

link_profile_files() {
    local profile_dir="$1"
    local chrome_dir="${profile_dir}/chrome"

    mkdir -p "$chrome_dir"

    ln -sfn "$USER_JS_SRC" "${profile_dir}/user.js"
    ln -sfn "$USER_CHROME_SRC" "${chrome_dir}/userChrome.css"
    ln -sfn "$USER_CONTENT_SRC" "${chrome_dir}/userContent.css"
}

main() {
    require_cmd awk
    require_cmd ln
    require_cmd mv
    require_file "$USER_JS_SRC"
    require_file "$USER_CHROME_SRC"
    require_file "$USER_CONTENT_SRC"

    ensure_firefox_dir
    ensure_profiles_ini

    local active_path
    active_path="$(find_active_profile_path)"

    normalize_profile "$active_path"
    link_profile_files "${FIREFOX_DIR}/${PROFILE_PATH}"

    printf 'Firefox profile ready.\n'
    printf 'Name: %s\n' "$PROFILE_NAME"
    printf 'Path: %s\n' "${FIREFOX_DIR}/${PROFILE_PATH}"
    printf 'Linked: %s\n' "${FIREFOX_DIR}/${PROFILE_PATH}/user.js"
    printf 'Linked: %s\n' "${FIREFOX_DIR}/${PROFILE_PATH}/chrome/userChrome.css"
    printf 'Linked: %s\n' "${FIREFOX_DIR}/${PROFILE_PATH}/chrome/userContent.css"
}

main "$@"
