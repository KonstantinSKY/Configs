.PHONY: help all install update refresh check list
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif
include $(CONFIGS_DIR)/make/update.mk

UNAME := $(shell uname)

# Linux font names (yay/AUR)
FONTS_LINUX = \
	noto-fonts \
	noto-fonts-emoji \
	ttf-jetbrains-mono \
	ttf-jetbrains-mono-nerd \
	ttf-hack \
	ttf-hack-nerd \
	ttf-ubuntu-font-family \
	ttf-ubuntu-mono-nerd \
	ttf-ubuntu-nerd \
	ttf-fira-code \
	ttf-firacode-nerd \
	ttf-sourcecodepro-nerd \
	ttf-nerd-fonts-symbols-mono

# Mac font names (brew cask)
FONTS_MAC = \
	font-noto-sans \
	font-noto-emoji \
	font-jetbrains-mono \
	font-jetbrains-mono-nerd-font \
	font-hack \
	font-hack-nerd-font \
	font-ubuntu \
	font-ubuntu-nerd-font \
	font-fira-code \
	font-fira-code-nerd-font \
	font-sauce-code-pro-nerd-font \
	font-symbols-only-nerd-font

all: install refresh check

install: ## Install all fonts (yay on Linux, brew cask on Mac)
ifeq ($(UNAME), Darwin)
	@echo "🔤 Installing fonts with brew cask..."
	@brew tap homebrew/cask-fonts 2>/dev/null || true
	@for font in $(FONTS_MAC); do \
		echo "📦 Installing $$font..."; \
		brew install --cask $$font || echo "⚠️  Failed to install $$font"; \
	done
else
	@echo "🔤 Installing fonts with yay..."
	@$(call ensure_system_updated)
	@for font in $(FONTS_LINUX); do \
		echo "📦 Installing $$font..."; \
		yay -S --needed --noconfirm $$font || echo "⚠️  Failed to install $$font"; \
	done
endif

update: ## Update system and reinstall fonts
ifeq ($(UNAME), Darwin)
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" install
else
	@$(call ensure_system_updated)
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" install
endif

refresh: ## Refresh font cache
	@echo "🔄 Refreshing font cache..."
ifeq ($(UNAME), Darwin)
	@echo "✅ Font cache managed automatically by macOS."
else
	fc-cache -fv
	@echo "✅ Font cache refreshed."
endif

check: ## Check which fonts from the list are installed
	@echo "🔍 Checking if fonts are installed..."
ifeq ($(UNAME), Darwin)
	@for font in $(FONTS_MAC); do \
		if brew list --cask $$font >/dev/null 2>&1; then \
			echo "✅ $$font is installed."; \
		else \
			echo "❌ $$font is NOT installed."; \
		fi; \
	done
else
	@if ! command -v pango-view >/dev/null 2>&1; then \
		echo "⚠️  pango-view is not installed. Previews won't be shown."; \
	fi
	@for font in $(FONTS_LINUX); do \
		if yay -Q $$font >/dev/null 2>&1; then \
			echo "✅ $$font is installed."; \
		else \
			echo "❌ $$font is NOT installed."; \
		fi; \
	done
	@echo "-------------------------------------------------------------------"
	@echo "🧪 Testing font cache (fc-list)..."
	@if ! fc-list > /dev/null 2>&1; then \
		echo "❌ Font cache seems broken or inaccessible."; \
	else \
		echo "✅ Font cache is readable."; \
	fi
endif

list: ## List all configured fonts and their install status
	@echo "📋 Fonts listed in Makefile:"
ifeq ($(UNAME), Darwin)
	@for font in $(FONTS_MAC); do echo " • $$font"; done
	@echo "-------------------------------------------------------------------"
	@echo "📦 Fonts installed via brew cask:"
	@for font in $(FONTS_MAC); do \
		if brew list --cask $$font >/dev/null 2>&1; then \
			echo " ✅ $$font"; \
		else \
			echo " ❌ $$font not installed"; \
		fi \
	done
else
	@for font in $(FONTS_LINUX); do echo " • $$font"; done
	@echo "-------------------------------------------------------------------"
	@echo "📦 Fonts from yay (installed from your list):"
	@for font in $(FONTS_LINUX); do \
		if yay -Q $$font >/dev/null 2>&1; then \
			echo " ✅ $$font"; \
		else \
			echo " ❌ $$font not installed"; \
		fi \
	done
	@echo "-------------------------------------------------------------------"
	@echo "🖋  Fonts available via fontconfig (fc-list):"
	@fc-list : family | cut -d',' -f1 | sort | uniq | head -n 2000
endif
