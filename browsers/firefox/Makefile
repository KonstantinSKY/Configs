.PHONY: help all install i setup set verify v
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/../..)

MANJARO_MAKEFILE := $(CONFIGS_DIR)/manjaro/Makefile
FIREFOX_DIR := $(HOME)/.config/mozilla/firefox
PROFILE_NAME := sky
PROFILE_PATH := sky.profile

USER_JS_SRC := $(THIS_DIR)/user.js
USER_CHROME_SRC := $(THIS_DIR)/chrome/userChrome.css
USER_CONTENT_SRC := $(THIS_DIR)/chrome/userContent.css

all: install

install i:
	@echo "🦊 Installing Firefox..."
	@$(MAKE) -f "$(MANJARO_MAKEFILE)" install firefox
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" setup
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ Firefox installed and profile overlay configured."

setup set:
	@set -euo pipefail; \
	die() { printf 'Error: %s\n' "$$1" >&2; exit 1; }; \
	require_file() { [ -f "$$1" ] || die "missing file: $$1"; }; \
	profile_running() { pgrep -x firefox >/dev/null 2>&1; }; \
	read_ini_value() { \
		local file="$$1"; \
		local key="$$2"; \
		awk -F= -v key="$$key" '$$1 == key { print substr($$0, index($$0, "=") + 1); exit }' "$$file"; \
	}; \
	find_active_profile_path() { \
		local installs_ini="$(FIREFOX_DIR)/installs.ini"; \
		local profiles_ini="$(FIREFOX_DIR)/profiles.ini"; \
		local install_default=""; \
		local profile_path=""; \
		[ -f "$$profiles_ini" ] || return 0; \
		if [ -f "$$installs_ini" ]; then \
			install_default="$$(read_ini_value "$$installs_ini" "Default" || true)"; \
		fi; \
		if [ -n "$$install_default" ]; then \
			printf '%s\n' "$$install_default"; \
			return 0; \
		fi; \
		profile_path="$$(awk -F= '\
			/^\[Profile/ { in_profile=1; is_default=0; path="" } \
			in_profile && $$1 == "Default" && $$2 == "1" { is_default=1 } \
			in_profile && $$1 == "Path" { path=substr($$0, index($$0, "=") + 1) } \
			/^\[/ && !/^\[Profile/ && in_profile { \
				if (is_default && path != "") { print path; exit } \
				in_profile=0 \
			} \
			END { \
				if (in_profile && is_default && path != "") print path \
			} \
		' "$$profiles_ini")"; \
		printf '%s\n' "$$profile_path"; \
	}; \
	ensure_firefox_dir() { \
		mkdir -p "$(FIREFOX_DIR)"; \
	}; \
		ensure_profiles_ini() { \
			local profiles_ini="$(FIREFOX_DIR)/profiles.ini"; \
			if [ ! -f "$$profiles_ini" ]; then \
				printf '[General]\nStartWithLastProfile=1\nVersion=2\n' > "$$profiles_ini"; \
			fi; \
		}; \
	append_profile_section() { \
		local profiles_ini="$(FIREFOX_DIR)/profiles.ini"; \
		local next_index; \
		next_index="$$(awk '\
			match($$0, /^\[Profile([0-9]+)\]$$/, parts) { \
				if (parts[1] > max) { \
					max = parts[1]; \
				} \
			} \
			END { \
				if (max != "") { \
					print max; \
				} \
			} \
		' "$$profiles_ini")"; \
		if [ -z "$$next_index" ]; then \
			next_index=0; \
		else \
			next_index="$$((next_index + 1))"; \
		fi; \
		printf '\n[Profile%s]\nName=%s\nIsRelative=1\nPath=%s\nDefault=1\n' "$$next_index" "$(PROFILE_NAME)" "$(PROFILE_PATH)" >> "$$profiles_ini"; \
	}; \
	ensure_profile_section() { \
		local profiles_ini="$(FIREFOX_DIR)/profiles.ini"; \
		if awk -F= -v path="$(PROFILE_PATH)" '\
			/^\[Profile/ { in_profile=1; current_path="" } \
			/^\[/ && !/^\[Profile/ { in_profile=0 } \
			in_profile && $$1 == "Path" { current_path=substr($$0, index($$0, "=") + 1) } \
			in_profile && current_path == path { found=1; exit } \
			END { exit(found ? 0 : 1) } \
		' "$$profiles_ini"; then \
			:; \
		else \
			append_profile_section; \
		fi; \
	}; \
	normalize_profile() { \
		local current_path="$$1"; \
		local current_dir="$(FIREFOX_DIR)/$$current_path"; \
		local target_dir="$(FIREFOX_DIR)/$(PROFILE_PATH)"; \
		local profiles_ini="$(FIREFOX_DIR)/profiles.ini"; \
		local installs_ini="$(FIREFOX_DIR)/installs.ini"; \
		if [ -z "$$current_path" ]; then \
			mkdir -p "$$target_dir"; \
			ensure_profile_section; \
			current_path="$(PROFILE_PATH)"; \
			current_dir="$$target_dir"; \
		elif [ ! -d "$$current_dir" ] && [ "$$current_path" = "$(PROFILE_PATH)" ]; then \
			mkdir -p "$$target_dir"; \
			ensure_profile_section; \
			current_dir="$$target_dir"; \
		elif [ ! -d "$$current_dir" ]; then \
			die "profile directory not found: $$current_dir"; \
		fi; \
		if [ "$$current_path" != "$(PROFILE_PATH)" ]; then \
			if profile_running; then \
				die "Firefox is running. Close it before renaming the profile directory."; \
			fi; \
			if [ -e "$$target_dir" ]; then \
				die "target profile path already exists: $$target_dir"; \
			fi; \
			mv "$$current_dir" "$$target_dir"; \
			current_path="$(PROFILE_PATH)"; \
		fi; \
		awk -F= -v path="$$current_path" -v target="$(PROFILE_PATH)" -v name="$(PROFILE_NAME)" '\
			BEGIN { in_profile=0; matched=0 } \
			/^\[Profile/ { in_profile=1; section_matches=0; print; next } \
			/^\[/ { in_profile=0 } \
			in_profile && $$1 == "Path" && $$2 == path { \
				section_matches=1; \
				matched=1; \
				print "Path=" target; \
				next \
			} \
			in_profile && section_matches && $$1 == "Name" { print "Name=" name; next } \
			{ print } \
			END { if (!matched) exit 0 } \
		' "$$profiles_ini" > "$$profiles_ini.tmp"; \
		mv "$$profiles_ini.tmp" "$$profiles_ini"; \
		ensure_profile_section; \
		if [ -f "$$installs_ini" ]; then \
			awk -F= -v path="$(PROFILE_PATH)" '\
				$$1 == "Default" && $$2 == path { print; next } \
				$$1 == "Default" { print "Default=" path; next } \
				{ print } \
			' "$$installs_ini" > "$$installs_ini.tmp"; \
			mv "$$installs_ini.tmp" "$$installs_ini"; \
		fi; \
	}; \
	link_profile_files() { \
		local profile_dir="$(FIREFOX_DIR)/$(PROFILE_PATH)"; \
		local chrome_dir="$$profile_dir/chrome"; \
		mkdir -p "$$chrome_dir"; \
		ln -sfn "$(USER_JS_SRC)" "$$profile_dir/user.js"; \
		ln -sfn "$(USER_CHROME_SRC)" "$$chrome_dir/userChrome.css"; \
		ln -sfn "$(USER_CONTENT_SRC)" "$$chrome_dir/userContent.css"; \
	}; \
	require_file "$(USER_JS_SRC)"; \
	require_file "$(USER_CHROME_SRC)"; \
	require_file "$(USER_CONTENT_SRC)"; \
	ensure_firefox_dir; \
	ensure_profiles_ini; \
	active_path="$$(find_active_profile_path || true)"; \
	normalize_profile "$$active_path"; \
	link_profile_files; \
	printf 'Firefox profile ready.\n'; \
	printf 'Name: %s\n' "$(PROFILE_NAME)"; \
	printf 'Path: %s\n' "$(FIREFOX_DIR)/$(PROFILE_PATH)"; \
	printf 'Linked: %s\n' "$(FIREFOX_DIR)/$(PROFILE_PATH)/user.js"; \
	printf 'Linked: %s\n' "$(FIREFOX_DIR)/$(PROFILE_PATH)/chrome/userChrome.css"; \
	printf 'Linked: %s\n' "$(FIREFOX_DIR)/$(PROFILE_PATH)/chrome/userContent.css"

verify v:
	@echo "🔎 Verifying Firefox overlay..."
	@if [ ! -r "$(FIREFOX_DIR)/profiles.ini" ]; then \
		echo "❌ profiles.ini not found: $(FIREFOX_DIR)/profiles.ini"; \
		exit 1; \
	fi
	@if [ ! -d "$(FIREFOX_DIR)/$(PROFILE_PATH)" ]; then \
		echo "❌ Profile directory not found: $(FIREFOX_DIR)/$(PROFILE_PATH)"; \
		exit 1; \
	fi
	@for target in "$(FIREFOX_DIR)/$(PROFILE_PATH)/user.js" "$(FIREFOX_DIR)/$(PROFILE_PATH)/chrome/userChrome.css" "$(FIREFOX_DIR)/$(PROFILE_PATH)/chrome/userContent.css"; do \
		if [ -L "$$target" ]; then \
			echo "✅ $$target -> $$(readlink -f "$$target")"; \
		else \
			echo "❌ Missing symlink: $$target"; \
			exit 1; \
		fi; \
	done
