# IMPORTANT FOR AI AGENTS:
# Do not modify this file without explicit user confirmation.

.PHONY: help h new n
.DEFAULT_GOAL := help

MAKEFLAGS += --no-print-directory

THIS_MAKEFILE := $(realpath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

SEPARATOR := ---------------------------------------------------------------------
SELECTOR := $(CONFIGS_DIR)/projects/select.mk

ARG_GOALS := new n
EXTRA_GOALS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

# Project name: second word after the target (e.g. `make new myapp`)
PROJECT := $(word 2,$(MAKECMDGOALS))

new n: ## Create a private GitHub repo and clone it here: make new <name>
	@set -e; \
	project="$(PROJECT)"; \
	if [ -z "$${project//[[:space:]]/}" ]; then \
		read -p "📛 Enter project name: " project; \
	fi; \
	if [ -z "$${project//[[:space:]]/}" ]; then \
		echo "❌ Project name is required."; exit 1; \
	fi; \
	if [ -e "$$project" ]; then \
		echo "❌ Path already exists: $$project"; exit 1; \
	fi; \
	echo "🛰  Creating private GitHub repo and cloning: $$project"; \
	gh repo create "$$project" --private --clone; \
	cp "$(SELECTOR)" "$$project/Makefile"; \
	printf '%s\n' '# OS / editor noise' '.DS_Store' '*.swp' '*.swo' > "$$project/.gitignore"; \
	echo "$(SEPARATOR)"; \
	echo "📂 Inside $$project:"; ls -la "$$project"; \
	echo "$(SEPARATOR)"; \
	echo "✅ Done → $$project (git repo + origin, stack selector copied in — no language yet)"; \
	echo "👉 Next: cd $$project && make rust   (or: make node / python — pick the stack)"; \
	echo "   (make can't move your shell — run the cd yourself)"

ifneq ($(filter $(firstword $(MAKECMDGOALS)),$(ARG_GOALS)),)
$(EXTRA_GOALS):
	@:
endif
