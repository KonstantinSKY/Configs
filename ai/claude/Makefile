# IMPORTANT:
# Humans and AI agents must not modify this file without explicit user confirmation.

.PHONY: help link backup-claude-settings restore-claude-settings verify-claude-settings
.DEFAULT_GOAL := help

THIS_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
CONFIGS_DIR := $(abspath $(THIS_DIR)/../..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif
ifeq ($(filter $(CONFIGS_DIR)/make/link.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/link.mk
endif

STATUSLINE_SOURCE = $(THIS_DIR)/statusline-command.sh
STATUSLINE_TARGET = $(HOME)/.claude/statusline-command.sh
CLAUDE_SETTINGS_SRC_DIR = $(THIS_DIR)/profiles
CLAUDE_PROFILE_MAP = default:.claude:.claude.json m:.claude-m:.claude-m/.claude.json

## ---------------------------
## 🤖 Claude Code
## ---------------------------
link: ## Link Claude Code config files into ~/.claude
	@$(call link,$(STATUSLINE_SOURCE),$(STATUSLINE_TARGET))
	@chmod +x "$(STATUSLINE_SOURCE)"

backup-claude-settings: ## Copy live Claude settings into this repo
	@echo "Saving live Claude settings..."
	@set -eu; \
	for entry in $(CLAUDE_PROFILE_MAP); do \
		profile="$${entry%%:*}"; \
		rest="$${entry#*:}"; \
		config_dir="$${rest%%:*}"; \
		root_file="$${rest#*:}"; \
		dest_dir="$(CLAUDE_SETTINGS_SRC_DIR)/$$profile"; \
		mkdir -p "$$dest_dir"; \
		jq 'del(.oauthAccount)' "$(HOME)/$$root_file" > "$$dest_dir/claude.json"; \
		cp -f "$(HOME)/$$config_dir/settings.json" "$$dest_dir/settings.json"; \
		if [ -r "$(HOME)/$$config_dir/settings.local.json" ]; then \
			cp -f "$(HOME)/$$config_dir/settings.local.json" "$$dest_dir/settings.local.json"; \
		fi; \
		echo "saved: $$profile"; \
	done

restore-claude-settings: ## Copy tracked Claude settings into live profile dirs
	@echo "Restoring Claude settings..."
	@set -eu; \
	for entry in $(CLAUDE_PROFILE_MAP); do \
		profile="$${entry%%:*}"; \
		rest="$${entry#*:}"; \
		config_dir="$${rest%%:*}"; \
		root_file="$${rest#*:}"; \
		src_dir="$(CLAUDE_SETTINGS_SRC_DIR)/$$profile"; \
		mkdir -p "$(HOME)/$$config_dir"; \
		cp -f "$$src_dir/claude.json" "$(HOME)/$$root_file"; \
		cp -f "$$src_dir/settings.json" "$(HOME)/$$config_dir/settings.json"; \
		if [ -r "$$src_dir/settings.local.json" ]; then \
			cp -f "$$src_dir/settings.local.json" "$(HOME)/$$config_dir/settings.local.json"; \
		fi; \
		echo "restored: $$profile"; \
	done

verify-claude-settings: ## Compare tracked Claude settings with live files
	@echo "Comparing tracked Claude settings with live files..."
	@set -eu; \
	for entry in $(CLAUDE_PROFILE_MAP); do \
		profile="$${entry%%:*}"; \
		rest="$${entry#*:}"; \
		config_dir="$${rest%%:*}"; \
		root_file="$${rest#*:}"; \
		src_dir="$(CLAUDE_SETTINGS_SRC_DIR)/$$profile"; \
		tmp="$$(mktemp)"; \
		jq 'del(.oauthAccount)' "$(HOME)/$$root_file" > "$$tmp"; \
		if cmp -s "$$src_dir/claude.json" "$$tmp"; then \
			rm -f "$$tmp"; \
		else \
			rm -f "$$tmp"; \
			echo "differs: $$profile claude.json"; \
			exit 1; \
		fi; \
		if ! cmp -s "$$src_dir/settings.json" "$(HOME)/$$config_dir/settings.json"; then \
			echo "differs: $$profile settings.json"; \
			exit 1; \
		fi; \
		if [ -r "$$src_dir/settings.local.json" ]; then \
			if ! cmp -s "$$src_dir/settings.local.json" "$(HOME)/$$config_dir/settings.local.json"; then \
				echo "differs: $$profile settings.local.json"; \
				exit 1; \
			fi; \
		fi; \
		echo "same: $$profile"; \
	done
