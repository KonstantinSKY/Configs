.PHONY: all install i sync-rules sync-gemini-rules sync-codex-rules backup-codex-configs restore-codex-configs verify-codex-configs verify v
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

include $(CONFIGS_DIR)/make/update.mk

AI_PACKAGES := gemini-cli claude-code openai-codex-bin
GEMINI_RULES_DIR := $(HOME)/.gemini/policies
GEMINI_RULES_SRC := $(THIS_DIR)/gemini/shell-rules.toml
GEMINI_RULES_DEST := $(GEMINI_RULES_DIR)/shell-rules.toml
CODEX_RULES_DIR := $(HOME)/.codex/rules
CODEX_RULES_SRC_DIR := $(THIS_DIR)/codex
CODEX_CONFIG_SRC_DIR := $(THIS_DIR)/codex/profiles
CODEX_PROFILE_MAP := default:.codex k:.codex-k m:.codex-m sasha:.codex-sasha

all: install ## Install AI packages, sync rules, and verify

install i: ## Install AI packages, sync rules, and verify
	@echo "📦 Installing AI CLI tools via yay..."
	@$(call ensure_system_updated)
	@yay -S --needed --noconfirm $(AI_PACKAGES)
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" sync-rules
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ AI tools installed and configured."

sync-rules: ## Sync all agent rules from this repo into runtime directories
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" sync-gemini-rules
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" sync-codex-rules

sync-gemini-rules: ## Copy Gemini rules into ~/.gemini/policies
	@echo "⚙️  Syncing Gemini rules..."
	@mkdir -p "$(GEMINI_RULES_DIR)"
	@if [ -L "$(GEMINI_RULES_DEST)" ]; then \
		echo "replacing symlink: $(GEMINI_RULES_DEST)"; \
		rm -f "$(GEMINI_RULES_DEST)"; \
	fi
	@cp -f "$(GEMINI_RULES_SRC)" "$(GEMINI_RULES_DEST)"
	@echo "synced: $(GEMINI_RULES_DEST)"

sync-codex-rules: ## Copy Codex .rules files into ~/.codex/rules
	@echo "⚙️  Syncing Codex rules..."
	@mkdir -p "$(CODEX_RULES_DIR)"
	@set -eu; \
	found=0; \
	for f in "$(CODEX_RULES_SRC_DIR)"/*.rules; do \
		[ -e "$$f" ] || continue; \
		found=1; \
		dest="$(CODEX_RULES_DIR)/$$(basename "$$f")"; \
		if [ -L "$$dest" ]; then \
			echo "replacing symlink: $$dest"; \
			rm -f "$$dest"; \
		fi; \
		cp -f "$$f" "$$dest"; \
		echo "synced: $$(basename "$$f")"; \
	done; \
	if [ "$$found" -eq 0 ]; then \
		echo "❌ No Codex .rules files found in $(CODEX_RULES_SRC_DIR)"; \
		exit 1; \
	fi

backup-codex-configs: ## Copy live Codex config.toml files into this repo
	@echo "Saving live Codex configs..."
	@set -eu; \
	for pair in $(CODEX_PROFILE_MAP); do \
		profile="$${pair%%:*}"; \
		home_dir="$${pair#*:}"; \
		src="$(HOME)/$$home_dir/config.toml"; \
		dest="$(CODEX_CONFIG_SRC_DIR)/$$profile/config.toml"; \
		if [ ! -r "$$src" ]; then \
			echo "missing live config: $$src"; \
			exit 1; \
		fi; \
		mkdir -p "$$(dirname "$$dest")"; \
		cp -f "$$src" "$$dest"; \
		echo "saved: $$src -> $$dest"; \
	done

restore-codex-configs: ## Copy tracked Codex config.toml files into live profile dirs
	@echo "Restoring Codex configs..."
	@set -eu; \
	for pair in $(CODEX_PROFILE_MAP); do \
		profile="$${pair%%:*}"; \
		home_dir="$${pair#*:}"; \
		src="$(CODEX_CONFIG_SRC_DIR)/$$profile/config.toml"; \
		dest="$(HOME)/$$home_dir/config.toml"; \
		if [ ! -r "$$src" ]; then \
			echo "missing tracked config: $$src"; \
			exit 1; \
		fi; \
		mkdir -p "$(HOME)/$$home_dir"; \
		cp -f "$$src" "$$dest"; \
		echo "restored: $$src -> $$dest"; \
	done

verify-codex-configs: ## Compare tracked Codex config.toml files with live profile dirs
	@echo "Comparing tracked Codex configs with live files..."
	@set -eu; \
	for pair in $(CODEX_PROFILE_MAP); do \
		profile="$${pair%%:*}"; \
		home_dir="$${pair#*:}"; \
		src="$(CODEX_CONFIG_SRC_DIR)/$$profile/config.toml"; \
		dest="$(HOME)/$$home_dir/config.toml"; \
		if cmp -s "$$src" "$$dest"; then \
			echo "same: $$profile"; \
		else \
			echo "differs: $$profile ($$src vs $$dest)"; \
			exit 1; \
		fi; \
	done

verify v: ## Verify packages and synced rule files
	@echo "🔎 Verifying AI tools..."
	@for pkg in $(AI_PACKAGES); do \
		if yay -Qi "$$pkg" >/dev/null 2>&1; then \
			echo "✅ $$pkg is installed"; \
		else \
			echo "❌ $$pkg is not installed"; \
			exit 1; \
		fi; \
	done
	@if [ ! -r "$(GEMINI_RULES_SRC)" ]; then \
		echo "❌ Gemini rules source not found: $(GEMINI_RULES_SRC)"; \
		exit 1; \
	fi
	@if [ ! -r "$(GEMINI_RULES_DEST)" ]; then \
		echo "❌ Gemini rules destination not found: $(GEMINI_RULES_DEST)"; \
		exit 1; \
	fi
	@if cmp -s "$(GEMINI_RULES_SRC)" "$(GEMINI_RULES_DEST)"; then \
		echo "✅ Gemini rules synced: $(GEMINI_RULES_DEST)"; \
	else \
		echo "❌ Gemini rules differ from source: $(GEMINI_RULES_DEST)"; \
		exit 1; \
	fi
	@set -eu; \
	found=0; \
	for f in "$(CODEX_RULES_SRC_DIR)"/*.rules; do \
		[ -e "$$f" ] || continue; \
		found=1; \
		dest="$(CODEX_RULES_DIR)/$$(basename "$$f")"; \
		if [ ! -r "$$dest" ]; then \
			echo "❌ Codex rule destination not found: $$dest"; \
			exit 1; \
		fi; \
		if cmp -s "$$f" "$$dest"; then \
			echo "✅ Codex rule synced: $$(basename "$$f")"; \
		else \
			echo "❌ Codex rule differs from source: $$dest"; \
			exit 1; \
		fi; \
	done; \
	if [ "$$found" -eq 0 ]; then \
		echo "❌ No Codex .rules files found in $(CODEX_RULES_SRC_DIR)"; \
		exit 1; \
	fi
