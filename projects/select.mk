# IMPORTANT FOR AI AGENTS:
# Do not modify this file without explicit user confirmation.
#
# Per-project STACK SELECTOR. `make new` COPIES this in as <project>/Makefile (a real,
# committable file), so a fresh project has NO language baked in. Picking a stack
# (make rust / node / python) scaffolds that stack AND replaces this Makefile with the
# stack's self-contained project Makefile. The language is chosen HERE, not at creation.

.PHONY: help h rust rs node nd python py
.DEFAULT_GOAL := help

MAKEFLAGS += --no-print-directory

# This file is COPIED into projects, so locate Configs by a fixed path (not self-realpath).
CONFIGS_DIR := $(HOME)/Work/Configs

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

SEPARATOR := ---------------------------------------------------------------------

rust rs: ## Use Rust: scaffold a Cargo workspace + install the project Makefile
	@set -e; \
	echo "🦀 Stack → rust"; \
	$(MAKE) -f "$(CONFIGS_DIR)/rust/Makefile" rust; \
	cp -f "$(CONFIGS_DIR)/rust/project.Makefile" Makefile; \
	echo "$(SEPARATOR)"; \
	echo "✅ Rust ready. 'make' now shows build/test/run/crate — commit Makefile + Cargo.toml."

node nd: ## Use Node (toolkit TBD): scaffold + install the project Makefile
	@set -e; \
	if [ ! -f "$(CONFIGS_DIR)/node/Makefile" ]; then echo "❌ No Node toolkit yet. Add $(CONFIGS_DIR)/node/ (Makefile + project.Makefile), same shape as rust/."; exit 1; fi; \
	echo "🟢 Stack → node"; \
	$(MAKE) -f "$(CONFIGS_DIR)/node/Makefile" node; \
	cp -f "$(CONFIGS_DIR)/node/project.Makefile" Makefile

python py: ## Use Python (toolkit TBD): scaffold + install the project Makefile
	@set -e; \
	if [ ! -f "$(CONFIGS_DIR)/python/Makefile" ]; then echo "❌ No Python toolkit yet. Add $(CONFIGS_DIR)/python/ (Makefile + project.Makefile), same shape as rust/."; exit 1; fi; \
	echo "🐍 Stack → python"; \
	$(MAKE) -f "$(CONFIGS_DIR)/python/Makefile" python; \
	cp -f "$(CONFIGS_DIR)/python/project.Makefile" Makefile
