.PHONY: help all install i link l verify v
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif
ifeq ($(filter $(CONFIGS_DIR)/make/link.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/link.mk
endif
include $(CONFIGS_DIR)/make/update.mk

CONFIG_FILE_NAME := picom.conf
SOURCE_CONFIG := $(THIS_DIR)/$(CONFIG_FILE_NAME)
TARGET_CONFIG := $(HOME)/.config/$(CONFIG_FILE_NAME)

all: install

install i: ## Install picom via yay and link config
	@echo "📥 Installing picom via yay..."
	@$(call ensure_system_updated)
	@yay -S --needed --noconfirm picom
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" link
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ picom installed and configured."

link l: ## Link picom.conf to ~/.config/picom.conf
	@$(call link,$(SOURCE_CONFIG),$(TARGET_CONFIG))

verify v: ## Verify picom config symlink is correct
	@echo "🔎 Verifying picom config..."
	@if [ ! -r "$(SOURCE_CONFIG)" ]; then \
		echo "❌ Source config not found: $(SOURCE_CONFIG)"; \
		exit 1; \
	fi
	@if [ -L "$(TARGET_CONFIG)" ]; then \
		echo "✅ $(TARGET_CONFIG) -> $$(readlink -f "$(TARGET_CONFIG)")"; \
	elif [ -e "$(TARGET_CONFIG)" ]; then \
		echo "⚠️  $(TARGET_CONFIG) exists but is not a symlink"; \
		exit 1; \
	else \
		echo "❌ Target config is missing: $(TARGET_CONFIG)"; \
		exit 1; \
	fi
