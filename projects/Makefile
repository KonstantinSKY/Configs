# --- Defaults
SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help
# --- Paths (use $(HOME), not ~)
WORK_DIR      ?= $(HOME)/Work
CONFIGS_DIR   ?= $(WORK_DIR)/Configs
PROJECTS_DIR  ?= $(WORK_DIR)/Projects
RUST_MAKEFILE := $(CONFIGS_DIR)/rust/Makefile
JS_MAKEFILE   := $(CONFIGS_DIR)/js/Makefile
PY_MAKEFILE   := $(CONFIGS_DIR)/python/Makefile
GIT_MAKEFILE  := $(CONFIGS_DIR)/git/Makefile
.PHONY: help setup rust r js j python p repo rp
setup:
	@mkdir -p "$(PROJECTS_DIR)"
	ln -sfn "$(CONFIGS_DIR)/projects/Makefile" "$(PROJECTS_DIR)/Makefile"
rust r:
	@proj="$(word 2,$(MAKECMDGOALS))"; \
	if [ -z "$$proj" ]; then read -p "📛 Enter Rust project name: " proj; fi; \
	if [[ -z "$${proj//[[:space:]]/}" ]]; then echo "❌ Project name is required."; exit 1; fi; \
	echo "🦀 Creating Rust project via sub-make: $$proj"; \
	$(MAKE) -f "$(RUST_MAKEFILE)" create PROJECT="$$proj"
js j:
	@proj="$(word 2,$(MAKECMDGOALS))"; \
	if [ -z "$$proj" ]; then read -p "📛 Enter JS project name: " proj; fi; \
	if [[ -z "$${proj//[[:space:]]/}" ]]; then echo "❌ Project name is required."; exit 1; fi; \
	$(MAKE) -f "$(JS_MAKEFILE)" create PROJECT="$$proj"
python p:
	@proj="$(word 2,$(MAKECMDGOALS))"; \
	if [ -z "$$proj" ]; then read -p "📛 Enter Python project name: " proj; fi; \
	if [[ -z "$${proj//[[:space:]]/}" ]]; then echo "❌ Project name is required."; exit 1; fi; \
	$(MAKE) -f "$(PY_MAKEFILE)" create PROJECT="$$proj"
repo rp:
	@set -e; \
	project="$(word 2,$(MAKECMDGOALS))"; \
	if [ -z "$$project" ]; then project="$(notdir "$$PWD")"; fi; \
	echo "📦 Project and repo name: $$project"; \
	echo "🌿 Initializing Git repository"; \
	$(MAKE) -f "$(GIT_MAKEFILE)" init; \
	echo "🛰  Creating GitHub repo"; \
	$(MAKE) -f "$(GIT_MAKEFILE)" create_repo "$$project"; \
	echo "🔐 Forcing SSH remote"; \
	$(MAKE) -f "$(GIT_MAKEFILE)" force_ssh "$$project"; \
	$(MAKE) -f "$(GIT_MAKEFILE)" copy_gitignore
