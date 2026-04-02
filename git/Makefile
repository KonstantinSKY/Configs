.PHONY: help link l verify v
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

SOURCE_CONFIG := $(THIS_DIR)/gitconfig
TARGET_CONFIG := $(HOME)/.gitconfig

link l: ## Link gitconfig to ~/.gitconfig
	@$(call link,$(SOURCE_CONFIG),$(TARGET_CONFIG))

verify v: ## Verify gitconfig symlink and show current settings
	@echo "🔎 Verifying Git config..."
	@if [ ! -r "$(SOURCE_CONFIG)" ]; then \
		echo "❌ Source config not found: $(SOURCE_CONFIG)"; \
		exit 1; \
	fi
	@if [ -L "$(TARGET_CONFIG)" ]; then \
		echo "✅ $(TARGET_CONFIG) -> $$(readlink -f "$(TARGET_CONFIG)")"; \
		echo ""; \
		git config --global --list; \
	elif [ -e "$(TARGET_CONFIG)" ]; then \
		echo "⚠️  $(TARGET_CONFIG) exists but is not a symlink"; \
		exit 1; \
	else \
		echo "❌ Target config is missing: $(TARGET_CONFIG)"; \
		exit 1; \
	fi
