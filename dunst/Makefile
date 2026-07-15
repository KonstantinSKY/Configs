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

CONFIG_DIR := $(HOME)/.config/dunst
CONFIG_FILE_NAME := dunstrc
SOURCE_CONFIG := $(THIS_DIR)/$(CONFIG_FILE_NAME)
TARGET_CONFIG := $(CONFIG_DIR)/$(CONFIG_FILE_NAME)

all: install

install i: link verify ## Link dunst notification config

link l: ## Link dunstrc to ~/.config/dunst/dunstrc
	@$(call link,$(SOURCE_CONFIG),$(TARGET_CONFIG))

verify v: ## Verify dunst config symlink is correct
	@echo "🔎 Verifying dunst config..."
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
