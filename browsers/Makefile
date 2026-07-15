# IMPORTANT FOR AI AGENTS:
# Do not modify this file without explicit user confirmation.

.PHONY: help h setup all install i remove cleanup remove-palemoon chrome install-chrome firefox install-firefox tor install-tor default-firefox verify-default
.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

EOS_MAKEFILE := $(CONFIGS_DIR)/eos/Makefile

setup all install i: ## Remove legacy Pale Moon and install the managed browser set
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" remove-palemoon
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" chrome
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" firefox
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" tor
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" default-firefox

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

chrome install-chrome: ## Install Google Chrome via the EndeavourOS package flow
	@echo "🌐 Installing Google Chrome..."
	@$(MAKE) -s -f "$(EOS_MAKEFILE)" install PKGS="google-chrome"
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" default-firefox
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify-default

firefox install-firefox: ## Install Firefox
	@$(MAKE) -s -f "$(EOS_MAKEFILE)" install PKGS="firefox"

tor install-tor: ## Install Tor Browser Launcher via the EndeavourOS package flow
	@echo "🕵️  Installing Tor Browser..."
	@$(MAKE) -s -f "$(EOS_MAKEFILE)" install PKGS="torbrowser-launcher"

default-firefox: ## Set Firefox as the default browser for XDG web links
	@echo "🦊 Setting Firefox as the default browser..."
	@env -u BROWSER xdg-settings set default-web-browser firefox.desktop
	@xdg-mime default firefox.desktop x-scheme-handler/http
	@xdg-mime default firefox.desktop x-scheme-handler/https
	@xdg-mime default firefox.desktop text/html
	@xdg-mime default firefox.desktop application/xhtml+xml
	@xdg-mime default firefox.desktop application/x-extension-html
	@xdg-mime default firefox.desktop application/x-extension-htm
	@xdg-mime default firefox.desktop application/x-extension-shtml
	@xdg-mime default firefox.desktop application/x-extension-xhtml
	@echo "✅ Firefox is the default browser."

verify-default: ## Verify Firefox is the default browser for XDG web links
	@set -eu; \
	status=0; \
	if [ "$$(xdg-settings get default-web-browser)" != "firefox.desktop" ]; then \
		echo "❌ default-web-browser is not Firefox: $$(xdg-settings get default-web-browser)"; \
		status=1; \
	fi; \
	for mime in x-scheme-handler/http x-scheme-handler/https text/html application/xhtml+xml; do \
		current="$$(xdg-mime query default "$$mime")"; \
		if [ "$$current" != "firefox.desktop" ]; then \
			echo "❌ $$mime -> $$current"; \
			status=1; \
		else \
			echo "✅ $$mime -> firefox.desktop"; \
		fi; \
	done; \
	exit "$$status"

%:
	@:
