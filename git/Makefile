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

define replace_with_symlink
	TARGET_PATH="$(1)"; \
	SOURCE_PATH="$(2)"; \
	DESIRED_LINK="$$(readlink -f "$$SOURCE_PATH")"; \
	CURRENT_LINK=""; \
	if [ -L "$$TARGET_PATH" ]; then \
		CURRENT_LINK="$$(readlink -f "$$TARGET_PATH" 2>/dev/null || true)"; \
	fi; \
	if [ "$$CURRENT_LINK" = "$$DESIRED_LINK" ]; then \
		echo "✅ Git config already linked: $$TARGET_PATH"; \
	else \
		if [ -L "$$TARGET_PATH" ]; then \
			echo "🔁 Replacing existing symlink: $$TARGET_PATH"; \
			rm -f "$$TARGET_PATH"; \
		elif [ -e "$$TARGET_PATH" ]; then \
			BACKUP_PATH="$$TARGET_PATH.bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up existing config to $$BACKUP_PATH"; \
			mv "$$TARGET_PATH" "$$BACKUP_PATH"; \
		fi; \
		echo "🔗 Linking Git config:"; \
		echo "→ Target : $$TARGET_PATH"; \
		echo "→ Source : $$SOURCE_PATH"; \
		ln -s "$$SOURCE_PATH" "$$TARGET_PATH"; \
	fi
endef

link l: ## Link gitconfig to ~/.gitconfig
	@$(call replace_with_symlink,$(TARGET_CONFIG),$(SOURCE_CONFIG))

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
