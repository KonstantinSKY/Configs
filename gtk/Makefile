.PHONY: help all install i install_theme install-theme install_icons install-icons apply_theme apply-theme link l apply-gsettings gs verify v check_theme
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

# was: only link.mk pulled in; help/fs missing when run standalone (no `make help`, no $(require_yay))
# was: ifeq ($(filter $(CONFIGS_DIR)/make/link.mk,$(MAKEFILE_LIST)),)
# was: include $(CONFIGS_DIR)/make/link.mk
# was: endif
ifeq ($(filter $(CONFIGS_DIR)/make/all.mk,$(abspath $(MAKEFILE_LIST))),)
include $(CONFIGS_DIR)/make/all.mk
endif

GTK_THEME ?= Arc-Dark
ICON_THEME ?= Qogir-Dark
CURSOR_THEME ?= Qogir-Dark
COLOR_SCHEME ?= prefer-dark
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
	@echo "🎨 Resolving GTK packages..."
#	was: @yay -S --needed --noconfirm $(GTK_PACKAGES)   # blew up on EndeavourOS where arc-gtk-theme conflicts with arc-gtk-theme-eos (both own /usr/share/themes/Arc-Dark)
	@PKGS=""; \
	if pacman -Qo "/usr/share/themes/$(GTK_THEME)" >/dev/null 2>&1; then \
		OWNER="$$(pacman -Qo "/usr/share/themes/$(GTK_THEME)" 2>/dev/null | sed 's/.*is owned by //' | awk '{print $$1}')"; \
		echo "✅ $(GTK_THEME) already provided by $$OWNER — skipping $(GTK_THEME_PACKAGE)"; \
	else \
		PKGS="$$PKGS $(GTK_THEME_PACKAGE)"; \
	fi; \
	if pacman -Qo "/usr/share/icons/$(ICON_THEME)" >/dev/null 2>&1; then \
		OWNER="$$(pacman -Qo "/usr/share/icons/$(ICON_THEME)" 2>/dev/null | sed 's/.*is owned by //' | awk '{print $$1}')"; \
		echo "✅ $(ICON_THEME) already provided by $$OWNER — skipping $(GTK_ICON_PACKAGE)"; \
	else \
		PKGS="$$PKGS $(GTK_ICON_PACKAGE)"; \
	fi; \
	if [ -z "$$(echo $$PKGS | xargs)" ]; then \
		echo "✅ All GTK theme components already installed — nothing to install."; \
	else \
		echo "📦 Installing:$$PKGS"; \
		yay -S --needed --noconfirm $$PKGS; \
	fi
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" link
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" apply-gsettings
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

apply-gsettings gs: ## Apply theme/icon/cursor/color-scheme via gsettings (for GTK4/libadwaita apps)
	@if ! command -v gsettings >/dev/null 2>&1; then \
		echo "ℹ️  gsettings not installed — skipping (GTK4/libadwaita apps may stay light)"; \
		exit 0; \
	fi
	@echo "🎛️  Applying gsettings (org.gnome.desktop.interface):"
	@gsettings set org.gnome.desktop.interface gtk-theme '$(GTK_THEME)' && echo "   gtk-theme     = $(GTK_THEME)"
	@gsettings set org.gnome.desktop.interface icon-theme '$(ICON_THEME)' && echo "   icon-theme    = $(ICON_THEME)"
	@gsettings set org.gnome.desktop.interface cursor-theme '$(CURSOR_THEME)' && echo "   cursor-theme  = $(CURSOR_THEME)"
	@gsettings set org.gnome.desktop.interface color-scheme '$(COLOR_SCHEME)' && echo "   color-scheme  = $(COLOR_SCHEME)  ← affects GTK4/libadwaita apps (Pamac etc.)"

verify v check_theme: ## Verify managed GTK config sources and symlinks
	@echo "🔎 Verifying GTK theme/icon availability..."
#	was: relied on exact package name; failed on EndeavourOS where arc-gtk-theme-eos provides the same files
	@if pacman -Qo "/usr/share/themes/$(GTK_THEME)" >/dev/null 2>&1; then \
		OWNER="$$(pacman -Qo "/usr/share/themes/$(GTK_THEME)" 2>/dev/null | sed 's/.*is owned by //' | awk '{print $$1}')"; \
		echo "✅ $(GTK_THEME) installed via $$OWNER"; \
	else \
		echo "⚠️  $(GTK_THEME) not present in /usr/share/themes/"; \
	fi
	@if pacman -Qo "/usr/share/icons/$(ICON_THEME)" >/dev/null 2>&1; then \
		OWNER="$$(pacman -Qo "/usr/share/icons/$(ICON_THEME)" 2>/dev/null | sed 's/.*is owned by //' | awk '{print $$1}')"; \
		echo "✅ $(ICON_THEME) installed via $$OWNER"; \
	else \
		echo "⚠️  $(ICON_THEME) not present in /usr/share/icons/"; \
	fi
	@echo "🔎 Current home targets:"
	@$(call verify_link,$(GTK2_TARGET))
	@$(call verify_link,$(GTK3_TARGET))
	@$(call verify_link,$(GTK4_TARGET))
	@if command -v gsettings >/dev/null 2>&1; then \
		echo "🔎 gsettings (org.gnome.desktop.interface):"; \
		printf "   gtk-theme     = %s\n" "$$(gsettings get org.gnome.desktop.interface gtk-theme)"; \
		printf "   icon-theme    = %s\n" "$$(gsettings get org.gnome.desktop.interface icon-theme)"; \
		printf "   cursor-theme  = %s\n" "$$(gsettings get org.gnome.desktop.interface cursor-theme)"; \
		printf "   color-scheme  = %s\n" "$$(gsettings get org.gnome.desktop.interface color-scheme)"; \
	fi
