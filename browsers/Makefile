.PHONY: all remove chrome firefox tor
MAKEFLAGS += --no-print-directory

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

LINUX_MAKEFILE := $(CONFIGS_DIR)/manjaro/Makefile
FIREFOX_MAKEFILE := $(THIS_DIR)/firefox/Makefile

all: remove chrome firefox tor
remove:
	@echo "🗑️  Removing All unneeded browsers..."
	@yay -Rns --noconfirm palemoon-bin || echo "⚠️  Polymoon not found or already removed."
chrome:
	@echo "🌐 Installing Google Chrome..."
	$(MAKE) -f "$(LINUX_MAKEFILE)" install google-chrome
firefox:
	@$(MAKE) -f "$(FIREFOX_MAKEFILE)" install
tor:
	@echo "🕵️  Installing Tor Browser..."
	$(MAKE) -f "$(LINUX_MAKEFILE)" install torbrowser-launcher
# Prevent make from treating package names as targets
# %:
# 	@:
