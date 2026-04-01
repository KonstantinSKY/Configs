.PHONY: help all install update refresh check list
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif
include $(CONFIGS_DIR)/make/update.mk

FONTS = \
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

all: install refresh check

install: ## Install all fonts via yay
	@echo "🔤 Installing fonts with yay..."
	@$(call ensure_system_updated)
	@for font in $(FONTS); do \
		echo "📦 Installing $$font..."; \
		yay -S --needed --noconfirm $$font || echo "⚠️  Failed to install $$font"; \
	done

update: ## Update system and reinstall fonts
	@$(call ensure_system_updated)
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" install

refresh: ## Refresh font cache
	@echo "🔄 Refreshing font cache..."
	fc-cache -fv
	@echo "✅ Font cache refreshed."

check: ## Check which fonts from the list are installed
	@echo "🔍 Checking if fonts are installed..."
	@if ! command -v pango-view >/dev/null 2>&1; then \
		echo "⚠️  pango-view is not installed. Previews won't be shown."; \
	fi
	@for font in $(FONTS); do \
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

list: ## List all configured fonts and their install status
	@echo "📋 Fonts listed in Makefile:"
	@for font in $(FONTS); do echo " • $$font"; done
	@echo "-------------------------------------------------------------------"
	@echo "📦 Fonts from yay (installed from your list):"
	@for font in $(FONTS); do \
		if yay -Q $$font >/dev/null 2>&1; then \
			echo " ✅ $$font"; \
		else \
			echo " ❌ $$font not installed"; \
		fi \
	done
	@echo "-------------------------------------------------------------------"
	@echo "🖋  Fonts available via fontconfig (fc-list):"
	@fc-list : family | cut -d',' -f1 | sort | uniq | head -n 2000
