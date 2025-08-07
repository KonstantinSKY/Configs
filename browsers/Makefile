.PHONY: help all remove chrome firefox tor

MAKEFLAGS += --no-print-directory
LINUX_MAKEFILE = $(HOME)/Work/Configs/manjaro/Makefile

help:
	@echo "📘 Available targets:"
	@echo "  make remove   - Remove Pale unneeded browsers"
	@echo "  make chrome   - Install Google Chrome"
	@echo "  make firefox  - Install Firefox"
	@echo "  make tor      - Install Tor Browser"
	@echo "  make all      - Remove Polymoon and install all browsers"

all: remove chrome firefox tor

remove:
	@echo "🗑️  Removing All unneeded browsers..."
	@yay -Rns --noconfirm palemoon-bin || echo "⚠️  Polymoon not found or already removed."

chrome:
	@echo "🌐 Installing Google Chrome..."
	$(MAKE) -f $(LINUX_MAKEFILE) install google-chrome

firefox:
	@echo "🦊 Installing Firefox..."
	$(MAKE) -f $(LINUX_MAKEFILE) i firefox

tor:
	@echo "🕵️  Installing Tor Browser..."
	$(MAKE) -f $(LINUX_MAKEFILE) install torbrowser-launcher

# Prevent make from treating package names as targets
# %:
# 	@:
