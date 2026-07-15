.PHONY: help all install i deps link l verify v status st keyring-info clean
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

include $(CONFIGS_DIR)/make/update.mk

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif
ifeq ($(filter $(CONFIGS_DIR)/make/link.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/link.mk
endif

SEPARATOR := ---------------------------------------------------------------------

# - zed: the editor
# - gnome-keyring + libsecret: persistent credential storage so Zed's auth
#   token survives restarts (without these, Zed prompts for login every launch
#   because libsecret has no Secret Service backend).
# - hunspell + en_US/ru dictionaries: power Zed's spell_check_languages.
ZED_DEPS := zed gnome-keyring libsecret hunspell hunspell-en_us hunspell-ru

ZED_TARGET_DIR := $(HOME)/.config/zed
ZED_SETTINGS_NAME := settings.json
ZED_SOURCE_SETTINGS := $(THIS_DIR)/$(ZED_SETTINGS_NAME)
ZED_TARGET_SETTINGS := $(ZED_TARGET_DIR)/$(ZED_SETTINGS_NAME)

all: install

install i: ## Install Zed and dependencies via yay, then link settings.json
	@echo "📥 Installing Zed and credential / spell-check deps via yay..."
	@$(call ensure_system_updated)
	@yay -S --needed --noconfirm $(ZED_DEPS)
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" link
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" keyring-info
	@echo "✅ Zed installed and configured."

deps: ## Install dependencies only (no link)
	@$(call ensure_system_updated)
	@yay -S --needed --noconfirm $(ZED_DEPS)

link l: ## Symlink settings.json into ~/.config/zed (leaves the dir for Zed)
	@mkdir -p "$(ZED_TARGET_DIR)"
	@$(call link,$(ZED_SOURCE_SETTINGS),$(ZED_TARGET_SETTINGS))

verify v: ## Verify the settings.json symlink resolves correctly
	@if [ ! -r "$(ZED_SOURCE_SETTINGS)" ]; then \
		echo "❌ Source settings.json not found: $(ZED_SOURCE_SETTINGS)"; \
		exit 1; \
	fi
	@if [ -L "$(ZED_TARGET_SETTINGS)" ]; then \
		echo "✅ $(ZED_TARGET_SETTINGS) -> $$(readlink -f "$(ZED_TARGET_SETTINGS)")"; \
	elif [ -e "$(ZED_TARGET_SETTINGS)" ]; then \
		echo "⚠️  $(ZED_TARGET_SETTINGS) exists but is not a symlink"; \
		exit 1; \
	else \
		echo "❌ Symlink missing: $(ZED_TARGET_SETTINGS)"; \
		exit 1; \
	fi

status st: ## Show Zed install state and config link
	@echo "Zed status"
	@echo "$(SEPARATOR)"
	@if command -v zeditor >/dev/null 2>&1; then \
		echo "✅ zed installed: $$(zeditor --version 2>/dev/null | head -1 || echo unknown)"; \
	else \
		echo "❌ zed not installed"; \
	fi
	@echo "$(SEPARATOR)"
	@if [ -L "$(ZED_TARGET_SETTINGS)" ]; then \
		echo "✅ settings linked: $(ZED_TARGET_SETTINGS) -> $$(readlink -f "$(ZED_TARGET_SETTINGS)")"; \
	elif [ -e "$(ZED_TARGET_SETTINGS)" ]; then \
		echo "⚠️  settings exists but is not a symlink"; \
	else \
		echo "❌ settings not linked"; \
	fi
	@echo "$(SEPARATOR)"
	@if pgrep -x gnome-keyring-d >/dev/null 2>&1 || \
	   dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply \
	             /org/freedesktop/DBus org.freedesktop.DBus.ListNames 2>/dev/null \
	     | grep -q org.freedesktop.secrets; then \
		echo "✅ Secret Service available — Zed login will persist."; \
	else \
		echo "⚠️  No Secret Service running — see 'make keyring-info'"; \
	fi

keyring-info: ## Print one-time setup notes for gnome-keyring autostart in i3
	@echo "$(SEPARATOR)"
	@echo "Secret Service / login persistence"
	@echo "$(SEPARATOR)"
	@echo "Zed stores its auth token via libsecret. For it to survive across"
	@echo "launches you need a Secret Service running in the i3 session."
	@echo ""
	@echo "1. The i3 config in ~/Work/Configs/i3/config already autostarts"
	@echo "   gnome-keyring-daemon. After installing the package, reload i3"
	@echo "   with Super+Shift+r."
	@echo ""
	@echo "2. On first launch Zed will prompt to create a keyring password."
	@echo "   Use the same as your login password if you want pam_gnome_keyring"
	@echo "   to auto-unlock it on login (already shipped with the package)."

clean: ## No-op (Zed manages its own runtime state in ~/.local/share/zed)
	@echo "Nothing to clean — Zed runtime data lives in ~/.local/share/zed/"
