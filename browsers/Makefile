# IMPORTANT FOR AI AGENTS:
# Do not modify this file without explicit user confirmation.

.PHONY: help h setup all install i remove cleanup remove-palemoon chrome install-chrome firefox install-firefox tor install-tor
.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

MANJARO_MAKEFILE := $(CONFIGS_DIR)/manjaro/Makefile
FIREFOX_MAKEFILE := $(THIS_DIR)/firefox/Makefile

setup all install i: ## Remove legacy Pale Moon and install the managed browser set
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" remove-palemoon
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" chrome
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" firefox
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" tor

remove cleanup: ## Remove legacy Pale Moon packages if they are installed
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" remove-palemoon

remove-palemoon: ## Remove legacy Pale Moon packages before a full system update
	@for pkg in palemoon palemoon-bin; do \
		if pacman -Q "$$pkg" >/dev/null 2>&1; then \
			echo "🗑️  Removing $$pkg..."; \
			sudo pacman -Rns --noconfirm "$$pkg"; \
		else \
			echo "ℹ️  $$pkg is not installed"; \
		fi; \
	done

chrome install-chrome: ## Install Google Chrome via the Manjaro package flow
	@echo "🌐 Installing Google Chrome..."
	@$(MAKE) -s -f "$(MANJARO_MAKEFILE)" install google-chrome

firefox install-firefox: ## Install Firefox and apply the managed Firefox profile overlay
	@$(MAKE) -s -f "$(FIREFOX_MAKEFILE)" install

tor install-tor: ## Install Tor Browser Launcher via the Manjaro package flow
	@echo "🕵️  Installing Tor Browser..."
	@$(MAKE) -s -f "$(MANJARO_MAKEFILE)" install torbrowser-launcher

%:
	@:
