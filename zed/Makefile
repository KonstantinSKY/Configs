.PHONY: help all install i link l verify v clean
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

include $(CONFIGS_DIR)/make/update.mk

ZED_SOURCE_CONFIG := $(THIS_DIR)
ZED_TARGET_CONFIG := $(HOME)/.config/zed

define replace_with_symlink
	TARGET_PATH="$(1)"; \
	SOURCE_PATH="$(2)"; \
	DESIRED_LINK="$$(readlink -f "$$SOURCE_PATH")"; \
	CURRENT_LINK=""; \
	if [ -L "$$TARGET_PATH" ]; then \
		CURRENT_LINK="$$(readlink -f "$$TARGET_PATH" 2>/dev/null || true)"; \
	fi; \
	if [ "$$CURRENT_LINK" = "$$DESIRED_LINK" ]; then \
		echo "✅ Zed config already linked: $$TARGET_PATH"; \
	else \
		if [ -L "$$TARGET_PATH" ]; then \
			echo "🔁 Replacing existing symlink: $$TARGET_PATH"; \
			rm -f "$$TARGET_PATH"; \
		elif [ -e "$$TARGET_PATH" ]; then \
			BACKUP_PATH="$$TARGET_PATH.bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up existing Zed config to $$BACKUP_PATH"; \
			mv "$$TARGET_PATH" "$$BACKUP_PATH"; \
		fi; \
		echo "🔗 Linking Zed config:"; \
		echo "→ Target : $$TARGET_PATH"; \
		echo "→ Source : $$SOURCE_PATH"; \
		ln -s "$$SOURCE_PATH" "$$TARGET_PATH"; \
	fi
endef

all: install

install i: ## Install Zed and link configuration
	@echo "📥 Installing Zed via yay..."
	@$(call ensure_system_updated)
	@yay -S --needed --noconfirm zed
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" link
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ Zed installed and configured."

link l:
	@echo "📁 Ensuring parent config directory exists..."
	@mkdir -p "$(HOME)/.config"
	@$(call replace_with_symlink,$(ZED_TARGET_CONFIG),$(ZED_SOURCE_CONFIG))

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

clean: ## Cleanup placeholder target for Zed
	@echo "Cleaning zed..."
	@echo "✅ Zed cleaned."
