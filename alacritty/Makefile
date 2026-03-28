.PHONY: help all install i link l verify v
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

include $(CONFIGS_DIR)/make/update.mk

CONFIG_DIR := $(HOME)/.config/alacritty
CONFIG_FILE_NAME := alacritty.toml
SOURCE_CONFIG := $(THIS_DIR)/$(CONFIG_FILE_NAME)
TARGET_CONFIG := $(CONFIG_DIR)/$(CONFIG_FILE_NAME)

define replace_with_symlink
	TARGET_PATH="$(1)"; \
	SOURCE_PATH="$(2)"; \
	DESIRED_LINK="$$(readlink -f "$$SOURCE_PATH")"; \
	CURRENT_LINK=""; \
	if [ -L "$$TARGET_PATH" ]; then \
		CURRENT_LINK="$$(readlink -f "$$TARGET_PATH" 2>/dev/null || true)"; \
	fi; \
	if [ "$$CURRENT_LINK" = "$$DESIRED_LINK" ]; then \
		echo "✅ Alacritty config already linked: $$TARGET_PATH"; \
	else \
		if [ -L "$$TARGET_PATH" ]; then \
			echo "🔁 Replacing existing symlink: $$TARGET_PATH"; \
			rm -f "$$TARGET_PATH"; \
		elif [ -e "$$TARGET_PATH" ]; then \
			BACKUP_PATH="$$TARGET_PATH.bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up existing config to $$BACKUP_PATH"; \
			mv "$$TARGET_PATH" "$$BACKUP_PATH"; \
		fi; \
		echo "🔗 Linking Alacritty config:"; \
		echo "→ Target : $$TARGET_PATH"; \
		echo "→ Source : $$SOURCE_PATH"; \
		ln -s "$$SOURCE_PATH" "$$TARGET_PATH"; \
	fi
endef

all: install

install i:
	@echo "📥 Installing Alacritty via yay..."
	@$(call ensure_system_updated)
	@yay -S --needed --noconfirm alacritty
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" link
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ Alacritty installed and configured."

link l:
	@echo "📁 Ensuring config directory exists at $(CONFIG_DIR)..."
	@mkdir -p "$(CONFIG_DIR)"
	@$(call replace_with_symlink,$(TARGET_CONFIG),$(SOURCE_CONFIG))

verify v:
	@echo "🔎 Verifying Alacritty config..."
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
