.PHONY: all install i sync-rules sync-gemini-rules sync-codex-rules verify v status codex-status mvs codex-mvs sasha codex-sasha
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)
SECURITY_DIR := $(abspath $(CONFIGS_DIR)/../Security)
CODEX_PROFILE_SWITCH := $(SECURITY_DIR)/ai/codex/switch_profile.sh

include $(CONFIGS_DIR)/make/update.mk

AI_PACKAGES := gemini-cli claude-code openai-codex-bin
GEMINI_RULES_DIR := $(HOME)/.gemini/policies
GEMINI_RULES_SRC := $(THIS_DIR)/gemini/shell-rules.toml
GEMINI_RULES_DEST := $(GEMINI_RULES_DIR)/shell-rules.toml
CODEX_RULES_DIR := $(HOME)/.codex/rules
CODEX_RULES_SRC_DIR := $(THIS_DIR)/codex

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

status codex-status: ## Show active Codex auth profile
	@bash "$(CODEX_PROFILE_SWITCH)" status

mvs codex-mvs: ## Switch Codex auth to mvs
	@bash "$(CODEX_PROFILE_SWITCH)" switch mvs

sasha codex-sasha: ## Switch Codex auth to sasha
	@bash "$(CODEX_PROFILE_SWITCH)" switch sasha

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
