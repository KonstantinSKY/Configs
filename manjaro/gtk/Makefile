.PHONY: help all install i install_theme install-theme install_icons install-icons apply_theme apply-theme link l verify v check_theme
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/../..)

include $(CONFIGS_DIR)/make/update.mk

MANJARO_MAKEFILE ?= $(abspath $(THIS_DIR)/..)/Makefile

GTK_THEME ?= Matcha-dark-sea
ICON_THEME ?= Papirus-Dark

GTK2_SOURCE := $(THIS_DIR)/.gtkrc-2.0
GTK3_SOURCE := $(THIS_DIR)/gtk-3.0/settings.ini
GTK4_SOURCE := $(THIS_DIR)/gtk-4.0/settings.ini

GTK2_TARGET := $(HOME)/.gtkrc-2.0
GTK3_TARGET_DIR := $(HOME)/.config/gtk-3.0
GTK3_TARGET := $(GTK3_TARGET_DIR)/settings.ini
GTK4_TARGET_DIR := $(HOME)/.config/gtk-4.0
GTK4_TARGET := $(GTK4_TARGET_DIR)/settings.ini

define replace_with_symlink
	TARGET_PATH="$(1)"; \
	SOURCE_PATH="$(2)"; \
	DESIRED_LINK="$$(readlink -f "$$SOURCE_PATH")"; \
	CURRENT_LINK=""; \
	if [ -L "$$TARGET_PATH" ]; then \
		CURRENT_LINK="$$(readlink -f "$$TARGET_PATH" 2>/dev/null || true)"; \
	fi; \
	if [ "$$CURRENT_LINK" = "$$DESIRED_LINK" ]; then \
		echo "✅ GTK config already linked: $$TARGET_PATH"; \
	else \
		if [ -L "$$TARGET_PATH" ]; then \
			echo "🔁 Replacing existing symlink: $$TARGET_PATH"; \
			rm -f "$$TARGET_PATH"; \
		elif [ -e "$$TARGET_PATH" ]; then \
			BACKUP_PATH="$$TARGET_PATH.bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up existing GTK config to $$BACKUP_PATH"; \
			mv "$$TARGET_PATH" "$$BACKUP_PATH"; \
		fi; \
		echo "🔗 Linking GTK config:"; \
		echo "→ Target : $$TARGET_PATH"; \
		echo "→ Source : $$SOURCE_PATH"; \
		ln -s "$$SOURCE_PATH" "$$TARGET_PATH"; \
	fi
endef

all: install

install i: ## Install GTK theme/icon packages and link managed configs
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" install_theme
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" install_icons
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" link
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ GTK installed and configured."

install_theme install-theme: ## Install the configured GTK theme package
	@echo "🎨 Installing GTK theme package for $(GTK_THEME)..."
	@$(MAKE) -f "$(MANJARO_MAKEFILE)" install matcha-gtk-theme

install_icons install-icons: ## Install the configured GTK icon theme package
	@echo "🖼️  Installing GTK icon theme package for $(ICON_THEME)..."
	@$(MAKE) -f "$(MANJARO_MAKEFILE)" install papirus-icon-theme

apply_theme apply-theme link l: ## Link managed GTK config files into the home directory
	@echo "📁 Ensuring GTK config directories exist..."
	@mkdir -p "$(GTK3_TARGET_DIR)" "$(GTK4_TARGET_DIR)"
	@$(call replace_with_symlink,$(GTK2_TARGET),$(GTK2_SOURCE))
	@$(call replace_with_symlink,$(GTK3_TARGET),$(GTK3_SOURCE))
	@$(call replace_with_symlink,$(GTK4_TARGET),$(GTK4_SOURCE))

verify v check_theme: ## Verify managed GTK config sources and symlinks
	@echo "🔎 Verifying GTK sources..."
	@for path in "$(GTK2_SOURCE)" "$(GTK3_SOURCE)" "$(GTK4_SOURCE)"; do \
		if [ ! -r "$$path" ]; then \
			echo "❌ Missing GTK source: $$path"; \
			exit 1; \
		fi; \
		echo "✅ Found: $$path"; \
	done
	@echo "🔎 Verifying GTK package installation..."
	@if yay -Q matcha-gtk-theme >/dev/null 2>&1; then \
		echo "✅ GTK theme package installed: matcha-gtk-theme"; \
	else \
		echo "⚠️  GTK theme package missing: matcha-gtk-theme"; \
	fi
	@if yay -Q papirus-icon-theme >/dev/null 2>&1; then \
		echo "✅ GTK icon package installed: papirus-icon-theme"; \
	else \
		echo "⚠️  GTK icon package missing: papirus-icon-theme"; \
	fi
	@echo "🔎 Current home targets:"
	@for target in "$(GTK2_TARGET)" "$(GTK3_TARGET)" "$(GTK4_TARGET)"; do \
		if [ -L "$$target" ]; then \
			echo "✅ $$target -> $$(readlink -f "$$target")"; \
		elif [ -e "$$target" ]; then \
			echo "⚠️  $$target exists but is not a symlink"; \
			exit 1; \
		else \
			echo "❌ Missing target: $$target"; \
			exit 1; \
		fi; \
	done
