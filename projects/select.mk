# IMPORTANT FOR AI AGENTS:
# Do not modify this file without explicit user confirmation.
#
# Per-project STACK SELECTOR. `make new` links this as <project>/Makefile, so a fresh
# project has NO language baked in. Picking a stack (make rust / node / python) relinks
# Makefile to that stack's toolkit and scaffolds it. The language is chosen HERE, not
# at project-creation time.

.PHONY: help h rust rs node nd python py
.DEFAULT_GOAL := help

MAKEFLAGS += --no-print-directory

THIS_MAKEFILE := $(realpath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

SEPARATOR := ---------------------------------------------------------------------

rust rs: ## Use Rust: link the Rust toolkit and scaffold a Cargo workspace
	@set -e; \
	echo "🔗 Stack → rust"; \
	ln -sfn "$(CONFIGS_DIR)/rust/Makefile" Makefile; \
	echo "$(SEPARATOR)"; \
	$(MAKE) rust

node nd: ## Use Node (toolkit TBD): link the Node toolkit and scaffold
	@set -e; \
	toolkit="$(CONFIGS_DIR)/node/Makefile"; \
	if [ ! -f "$$toolkit" ]; then echo "❌ No Node toolkit yet. Add $$toolkit with a 'node' target (same shape as rust/)."; exit 1; fi; \
	echo "🔗 Stack → node"; \
	ln -sfn "$$toolkit" Makefile; \
	echo "$(SEPARATOR)"; \
	$(MAKE) node

python py: ## Use Python (toolkit TBD): link the Python toolkit and scaffold
	@set -e; \
	toolkit="$(CONFIGS_DIR)/python/Makefile"; \
	if [ ! -f "$$toolkit" ]; then echo "❌ No Python toolkit yet. Add $$toolkit with a 'python' target (same shape as rust/)."; exit 1; fi; \
	echo "🔗 Stack → python"; \
	ln -sfn "$$toolkit" Makefile; \
	echo "$(SEPARATOR)"; \
	$(MAKE) python
