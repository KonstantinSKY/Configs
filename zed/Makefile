.PHONY: help all install i link l verify v status st clean
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

include $(CONFIGS_DIR)/make/update.mk

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif
ifeq ($(filter $(CONFIGS_DIR)/make/link.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/link.mk
endif

SEPARATOR := ---------------------------------------------------------------------
ZED_EXTENSIONS := material-icon-theme gruvbox lua dockerfile sql bash toml make

ZED_SOURCE_CONFIG := $(THIS_DIR)
ZED_TARGET_CONFIG := $(HOME)/.config/zed

all: install

install i: ## Install Zed and link configuration
	@echo "📥 Installing Zed via yay..."
	@$(call ensure_system_updated)
	@yay -S --needed --noconfirm zed
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" link
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ Zed installed and configured."

link l: ## Link Zed config directory into ~/.config
	@$(call link,$(ZED_SOURCE_CONFIG),$(ZED_TARGET_CONFIG))

verify v:
	@echo "🔎 Verifying Zed config..."
	@if [ ! -r "$(ZED_SOURCE_CONFIG)/settings.json" ]; then \
		echo "❌ Zed settings.json not found: $(ZED_SOURCE_CONFIG)/settings.json"; \
		exit 1; \
	fi
	@if [ -L "$(ZED_TARGET_CONFIG)" ]; then \
		echo "✅ $(ZED_TARGET_CONFIG) -> $$(readlink -f "$(ZED_TARGET_CONFIG)")"; \
	elif [ -e "$(ZED_TARGET_CONFIG)" ]; then \
		echo "⚠️  $(ZED_TARGET_CONFIG) exists but is not a symlink"; \
		exit 1; \
	else \
		echo "❌ Target config is missing: $(ZED_TARGET_CONFIG)"; \
		exit 1; \
	fi

status st: ## Show Zed installation, config link, and configured extensions
	@echo "Zed status"
	@echo "$(SEPARATOR)"
	@if command -v zeditor >/dev/null 2>&1; then \
		echo "✅ zed installed: $$(zeditor --version 2>/dev/null | head -1 || echo unknown)"; \
	else \
		echo "❌ zed not installed"; \
	fi
	@echo "$(SEPARATOR)"
	@if [ -L "$(ZED_TARGET_CONFIG)" ]; then \
		echo "✅ config linked: $(ZED_TARGET_CONFIG) -> $$(readlink -f "$(ZED_TARGET_CONFIG)")"; \
	elif [ -e "$(ZED_TARGET_CONFIG)" ]; then \
		echo "⚠️  config exists but is not a symlink: $(ZED_TARGET_CONFIG)"; \
	else \
		echo "❌ config not linked: $(ZED_TARGET_CONFIG)"; \
	fi
	@echo "$(SEPARATOR)"
	@echo "Auto-install extensions:"
	@for ext in $(ZED_EXTENSIONS); do \
		echo "  - $$ext"; \
	done

clean: ## Cleanup placeholder target for Zed
	@echo "Cleaning zed..."
	@echo "✅ Zed cleaned."
