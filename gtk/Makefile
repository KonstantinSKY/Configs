.PHONY: help all install i install_theme install-theme install_icons install-icons apply_theme apply-theme link l verify v check_theme
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/link.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/link.mk
endif

GTK_THEME ?= Arc-Dark
ICON_THEME ?= Qogir-Dark
CURSOR_THEME ?= Qogir-Dark
GTK_THEME_PACKAGE ?= arc-gtk-theme
GTK_ICON_PACKAGE ?= qogir-icon-theme
CURSOR_PACKAGE ?= qogir-icon-theme
GTK_PACKAGES = $(GTK_THEME_PACKAGE) $(GTK_ICON_PACKAGE)

GTK2_SOURCE := $(THIS_DIR)/.gtkrc-2.0
GTK3_SOURCE := $(THIS_DIR)/gtk-3.0/settings.ini
GTK4_SOURCE := $(THIS_DIR)/gtk-4.0/settings.ini

GTK2_TARGET := $(HOME)/.gtkrc-2.0
GTK3_TARGET_DIR := $(HOME)/.config/gtk-3.0
GTK3_TARGET := $(GTK3_TARGET_DIR)/settings.ini
GTK4_TARGET_DIR := $(HOME)/.config/gtk-4.0
GTK4_TARGET := $(GTK4_TARGET_DIR)/settings.ini

all: install

install i: ## Install GTK theme/icon packages and link managed configs
	@$(require_yay)
	@echo "🎨 Installing GTK packages: $(GTK_PACKAGES)..."
	@yay -S --needed --noconfirm $(GTK_PACKAGES)
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" link
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ GTK installed and configured."

install_theme install-theme: ## Install the configured GTK theme package
	@$(require_yay)
	@echo "🎨 Installing GTK theme package for $(GTK_THEME)..."
	@yay -S --needed --noconfirm $(GTK_THEME_PACKAGE)

install_icons install-icons: ## Install the configured GTK icon theme package
	@$(require_yay)
	@echo "🖼️  Installing GTK icon theme package for $(ICON_THEME)..."
	@yay -S --needed --noconfirm $(GTK_ICON_PACKAGE)

apply_theme apply-theme link l: ## Link managed GTK config files into the home directory
	@$(call link,$(GTK2_SOURCE),$(GTK2_TARGET))
	@$(call link,$(GTK3_SOURCE),$(GTK3_TARGET))
	@$(call link,$(GTK4_SOURCE),$(GTK4_TARGET))

verify v check_theme: ## Verify managed GTK config sources and symlinks
	@echo "🔎 Verifying GTK package installation..."
	@if yay -Q $(GTK_THEME_PACKAGE) >/dev/null 2>&1; then \
		echo "✅ GTK theme package installed: $(GTK_THEME_PACKAGE)"; \
	else \
		echo "⚠️  GTK theme package missing: $(GTK_THEME_PACKAGE)"; \
	fi
	@if yay -Q $(GTK_ICON_PACKAGE) >/dev/null 2>&1; then \
		echo "✅ GTK icon package installed: $(GTK_ICON_PACKAGE)"; \
	else \
		echo "⚠️  GTK icon package missing: $(GTK_ICON_PACKAGE)"; \
	fi
	@echo "🔎 Current home targets:"
	@$(call verify_link,$(GTK2_TARGET))
	@$(call verify_link,$(GTK3_TARGET))
	@$(call verify_link,$(GTK4_TARGET))
