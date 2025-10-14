# --- Defaults
SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

# --- Paths (use $(HOME), not ~)
RUST_MAKEFILE := $(HOME)/Configs/rust/Makefile
JS_MAKEFILE   := $(HOME)/Configs/js/Makefile
PY_MAKEFILE   := $(HOME)/Configs/python/Makefile
GIT_MAKEFILE  := $(HOME)/Configs/git/Makefile

.PHONY: help h setup rust r js j python p repo rp

help h:
	@echo "🛠  Makefile commands:"
	@echo "  make setup            — 🔗 Link ~/Projects/Makefile → ~/Configs/projects/Makefile"
	@echo "  make rust <name>      — 🦀 Create new Rust project"
	@echo "  make js <name>        — 🟨 Create new JavaScript project"
	@echo "  make python <name>    — 🐍 Create new Python project"
	@echo "  make repo [name]      — 🛰  Init Git repo + create GitHub repo (SSH remote)"
	@echo "  make h, help          — Show this help message"
	@echo
	@echo "Examples:"
	@echo "  make rust myproj"
	@echo "  make js myproj"
	@echo "  make python myproj"
	@echo "  make repo myrepo"

setup:
	ln -s "$(HOME)/Configs/projects/Makefile" "$(HOME)/Projects/Makefile"

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
