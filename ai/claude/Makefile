# IMPORTANT:
# Humans and AI agents must not modify this file without explicit user confirmation.

.PHONY: help link
.DEFAULT_GOAL := help

THIS_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
CONFIGS_DIR := $(abspath $(THIS_DIR)/../..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

STATUSLINE_SOURCE = $(THIS_DIR)/statusline-command.sh
STATUSLINE_TARGET = $(HOME)/.claude/statusline-command.sh

## ---------------------------
## 🤖 Claude Code
## ---------------------------
link: ## Link Claude Code config files into ~/.claude
	@$(call link,$(STATUSLINE_SOURCE),$(STATUSLINE_TARGET))
	@chmod +x "$(STATUSLINE_SOURCE)"
