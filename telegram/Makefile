.PHONY: help all install i apply a verify v clean uninstall
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/all.mk,$(abspath $(MAKEFILE_LIST))),)
include $(CONFIGS_DIR)/make/all.mk
endif

PACKAGE := telegram-desktop
DESKTOP_FILE_NAME := org.telegram.desktop.desktop
SYSTEM_DESKTOP := /usr/share/applications/$(DESKTOP_FILE_NAME)
LOCAL_DESKTOP_DIR := $(HOME)/.local/share/applications
LOCAL_DESKTOP := $(LOCAL_DESKTOP_DIR)/$(DESKTOP_FILE_NAME)

# Patch goal: force Telegram's bundled Qt6 to use the xdg-desktop-portal
# file picker (matches the dark dialog that browsers already get) instead
# of falling back to its built-in QFileDialog (which renders light because
# qt6ct/kvantum aren't applied to standalone dialogs).
#
# Patch 1: prefix every Exec= with `env QT_QPA_PLATFORMTHEME=xdgdesktopportal`
# Patch 2: flip DBusActivatable=true → false so launchers honor our Exec=
#          (otherwise they D-Bus-activate the upstream service file and our
#           env prefix never reaches the process).
QT_PLATFORM_THEME := xdgdesktopportal

all: install

install i: ## Install Telegram and apply the dark-file-dialog patch
	@$(require_yay)
	@echo "📥 Installing $(PACKAGE) via yay..."
	@yay -S --needed --noconfirm $(PACKAGE)
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" apply
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ Telegram installed and patched."

apply a: ## Regenerate the patched .desktop override from the current system file
	@$(call require_exists,$(SYSTEM_DESKTOP),Upstream Telegram .desktop missing — install $(PACKAGE) first)
	@mkdir -p "$(LOCAL_DESKTOP_DIR)"
	@if [ -L "$(LOCAL_DESKTOP)" ]; then rm -f "$(LOCAL_DESKTOP)"; fi
	@sed \
		-e 's|^Exec=Telegram |Exec=env QT_QPA_PLATFORMTHEME=$(QT_PLATFORM_THEME) Telegram |g' \
		-e 's|^DBusActivatable=true$$|DBusActivatable=false|' \
		"$(SYSTEM_DESKTOP)" > "$(LOCAL_DESKTOP)"
	@echo "🔧 $(LOCAL_DESKTOP) generated from $(SYSTEM_DESKTOP)"
	@if command -v update-desktop-database >/dev/null 2>&1; then \
		update-desktop-database "$(LOCAL_DESKTOP_DIR)" 2>/dev/null || true; \
	fi

verify v: ## Verify the patched override has both expected modifications
	@echo "🔎 Verifying Telegram .desktop override..."
	@if [ ! -e "$(LOCAL_DESKTOP)" ]; then \
		echo "❌ $(LOCAL_DESKTOP) not found — run 'make apply'"; \
		exit 1; \
	fi
	@if grep -q "^Exec=env QT_QPA_PLATFORMTHEME=$(QT_PLATFORM_THEME) Telegram" "$(LOCAL_DESKTOP)"; then \
		echo "✅ Exec= carries QT_QPA_PLATFORMTHEME=$(QT_PLATFORM_THEME)"; \
	else \
		echo "❌ Exec= is missing the env prefix — re-run 'make apply'"; \
		exit 1; \
	fi
	@if grep -q "^DBusActivatable=false$$" "$(LOCAL_DESKTOP)"; then \
		echo "✅ DBusActivatable=false"; \
	elif grep -q "^DBusActivatable=true$$" "$(LOCAL_DESKTOP)"; then \
		echo "❌ DBusActivatable=true (launchers will bypass Exec=) — re-run 'make apply'"; \
		exit 1; \
	else \
		echo "ℹ️  DBusActivatable line not present (upstream may have removed it)"; \
	fi

clean uninstall: ## Remove the local .desktop override (revert to upstream behavior)
	@if [ -e "$(LOCAL_DESKTOP)" ]; then \
		rm -f "$(LOCAL_DESKTOP)"; \
		echo "🗑️  Removed $(LOCAL_DESKTOP)"; \
		if command -v update-desktop-database >/dev/null 2>&1; then \
			update-desktop-database "$(LOCAL_DESKTOP_DIR)" 2>/dev/null || true; \
		fi; \
	else \
		echo "ℹ️  $(LOCAL_DESKTOP) not present — nothing to remove"; \
	fi
