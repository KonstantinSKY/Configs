.PHONY: help all install i packages p link l sync s parsers ts verify v
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

NVIM_SOURCE_DIR := $(THIS_DIR)
NVIM_TARGET_DIR := $(HOME)/.config/nvim
CORE_PACKAGES := neovim tree-sitter-cli
LEGACY_VIM_PACKAGES := vim ex-vi-compat
# Keep this list in sync with nvim/lua/plugins/treesitter.lua.
TREESITTER_PARSERS := bash diff json lua luadoc markdown markdown_inline python query rust toml vim vimdoc yaml

define replace_with_symlink
	TARGET_PATH="$(1)"; \
	SOURCE_PATH="$(2)"; \
	DESIRED_LINK="$$(readlink -f "$$SOURCE_PATH")"; \
	CURRENT_LINK=""; \
	if [ -L "$$TARGET_PATH" ]; then \
		CURRENT_LINK="$$(readlink -f "$$TARGET_PATH" 2>/dev/null || true)"; \
	fi; \
	if [ "$$CURRENT_LINK" = "$$DESIRED_LINK" ]; then \
		echo "✅ Neovim config already linked: $$TARGET_PATH"; \
	else \
		if [ -L "$$TARGET_PATH" ]; then \
			echo "🔁 Replacing existing symlink: $$TARGET_PATH"; \
			rm -f "$$TARGET_PATH"; \
		elif [ -e "$$TARGET_PATH" ]; then \
			BACKUP_PATH="$$TARGET_PATH.bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up existing Neovim config to $$BACKUP_PATH"; \
			mv "$$TARGET_PATH" "$$BACKUP_PATH"; \
		fi; \
		echo "🔗 Linking Neovim config:"; \
		echo "→ Target : $$TARGET_PATH"; \
		echo "→ Source : $$SOURCE_PATH"; \
		ln -s "$$SOURCE_PATH" "$$TARGET_PATH"; \
	fi
endef

all: install

install i: ## Install Neovim, restore locked plugins, install parsers, and verify
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" packages
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" link
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" sync
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" parsers
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ Neovim installed and configured."

packages p: ## Install Neovim and tree-sitter CLI from official repositories
	@if ! command -v pacman >/dev/null 2>&1; then \
		echo "❌ pacman not found. This target currently supports Arch/Manjaro only."; \
		exit 1; \
	fi
	@legacy_packages=""; \
	for pkg in $(LEGACY_VIM_PACKAGES); do \
		if pacman -Q "$$pkg" >/dev/null 2>&1; then \
			legacy_packages="$$legacy_packages $$pkg"; \
		fi; \
	done; \
	if [ -n "$$legacy_packages" ]; then \
		echo "🧹 Removing legacy Vim packages:$$legacy_packages"; \
		sudo pacman -Rns --noconfirm $$legacy_packages; \
	else \
		echo "✅ No legacy Vim packages installed."; \
	fi
	@echo "📦 Installing core Neovim packages from official repositories..."
	@sudo pacman -S --needed --noconfirm $(CORE_PACKAGES)

link l: ## Link managed Neovim config into ~/.config
	@mkdir -p "$(HOME)/.config"
	@$(call replace_with_symlink,$(NVIM_TARGET_DIR),$(NVIM_SOURCE_DIR))

sync s: ## Restore lazy.nvim plugins to the versions pinned in lazy-lock.json
	@if ! command -v nvim >/dev/null 2>&1; then \
		echo "❌ nvim is not installed. Run 'make -f $(THIS_MAKEFILE) install' first."; \
		exit 1; \
	fi
	@echo "🔄 Restoring lazy.nvim plugins from lockfile..."
	@STATE_DIR="$$(mktemp -d)"; \
	CACHE_DIR="$$(mktemp -d)"; \
	OUT_FILE="$$(mktemp)"; \
	if XDG_STATE_HOME="$$STATE_DIR" XDG_CACHE_HOME="$$CACHE_DIR" nvim --headless "+Lazy! restore" "+qa!" >"$$OUT_FILE" 2>&1; then \
		if grep -q "Error detected while processing" "$$OUT_FILE"; then \
			cat "$$OUT_FILE"; \
			rm -rf "$$STATE_DIR" "$$CACHE_DIR" "$$OUT_FILE"; \
			exit 1; \
		fi; \
		cat "$$OUT_FILE"; \
	else \
		cat "$$OUT_FILE"; \
		rm -rf "$$STATE_DIR" "$$CACHE_DIR" "$$OUT_FILE"; \
		exit 1; \
	fi; \
	rm -rf "$$STATE_DIR" "$$CACHE_DIR" "$$OUT_FILE"

parsers ts: ## Install or update the configured Tree-sitter parsers synchronously
	@if ! command -v nvim >/dev/null 2>&1; then \
		echo "❌ nvim is not installed. Run 'make -f $(THIS_MAKEFILE) install' first."; \
		exit 1; \
	fi
	@echo "🌲 Installing Tree-sitter parsers..."
	@STATE_DIR="$$(mktemp -d)"; \
	CACHE_DIR="$$(mktemp -d)"; \
	OUT_FILE="$$(mktemp)"; \
	if XDG_STATE_HOME="$$STATE_DIR" XDG_CACHE_HOME="$$CACHE_DIR" nvim --headless "+TSUpdateSync $(TREESITTER_PARSERS)" "+qa!" >"$$OUT_FILE" 2>&1; then \
		if grep -q "Error detected while processing" "$$OUT_FILE"; then \
			cat "$$OUT_FILE"; \
			rm -rf "$$STATE_DIR" "$$CACHE_DIR" "$$OUT_FILE"; \
			exit 1; \
		fi; \
		cat "$$OUT_FILE"; \
	else \
		cat "$$OUT_FILE"; \
		rm -rf "$$STATE_DIR" "$$CACHE_DIR" "$$OUT_FILE"; \
		exit 1; \
	fi; \
	rm -rf "$$STATE_DIR" "$$CACHE_DIR" "$$OUT_FILE"

verify v: ## Verify the managed config link and basic headless startup
	@echo "🔎 Verifying Neovim source..."
	@if [ ! -r "$(THIS_DIR)/init.lua" ]; then \
		echo "❌ Missing init.lua in $(THIS_DIR)"; \
		exit 1; \
	fi
	@echo "✅ Found: $(THIS_DIR)/init.lua"
	@echo "🔎 Checking home target..."
	@if [ -L "$(NVIM_TARGET_DIR)" ]; then \
		echo "✅ $(NVIM_TARGET_DIR) -> $$(readlink -f "$(NVIM_TARGET_DIR)")"; \
	elif [ -e "$(NVIM_TARGET_DIR)" ]; then \
		echo "⚠️  $(NVIM_TARGET_DIR) exists but is not a symlink"; \
		exit 1; \
	else \
		echo "❌ Missing target: $(NVIM_TARGET_DIR)"; \
		exit 1; \
	fi
	@if ! command -v nvim >/dev/null 2>&1; then \
		echo "❌ nvim is not installed."; \
		exit 1; \
	fi
	@echo "🔎 Verifying headless startup..."
	@STATE_DIR="$$(mktemp -d)"; \
	CACHE_DIR="$$(mktemp -d)"; \
	OUT_FILE="$$(mktemp)"; \
	if XDG_STATE_HOME="$$STATE_DIR" XDG_CACHE_HOME="$$CACHE_DIR" nvim --headless "+lua io.write(vim.fn.stdpath('config'))" "+qa" >"$$OUT_FILE" 2>&1; then \
		if grep -q "Error detected while processing" "$$OUT_FILE"; then \
			cat "$$OUT_FILE"; \
			rm -rf "$$STATE_DIR" "$$CACHE_DIR" "$$OUT_FILE"; \
			exit 1; \
		fi; \
		sed 's#^#stdpath(config)=#' "$$OUT_FILE"; \
	else \
		cat "$$OUT_FILE"; \
		rm -rf "$$STATE_DIR" "$$CACHE_DIR" "$$OUT_FILE"; \
		exit 1; \
	fi; \
	rm -rf "$$STATE_DIR" "$$CACHE_DIR" "$$OUT_FILE"
	@if [ -f "$(THIS_DIR)/lazy-lock.json" ]; then \
		echo "✅ Found: $(THIS_DIR)/lazy-lock.json"; \
	else \
		echo "ℹ️  lazy-lock.json is not present yet; it will appear after the first successful sync."; \
	fi
