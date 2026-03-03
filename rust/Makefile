# --- Defaults
SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help


.PHONY: help h install i create c repo rp delete_repo dr copy_gitignore gi read rd

-include $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../make/help.mk)

RUST_MAKEFILE := $(HOME)/Configs/rust/Makefile
GIT_MAKEFILE := $(HOME)/Configs/git/Makefile
GITIGNORE_TEMPLATE := $(HOME)/Configs/rust/gitignore
MANJARO_MAKEFILE := $(HOME)/Configs/manjaro/Makefile

# ────────────────────────────────────────────────────────────────────────────────
# Helpers
# PROJECT аргумент: второе слово после цели, иначе текущая папка
PROJECT := $(word 2, $(MAKECMDGOALS))
ifeq ($(strip $(PROJECT)),)
PROJECT := $(notdir $(CURDIR))
endif

# ────────────────────────────────────────────────────────────────────────────────
# Create new Rust project and link shared Makefile
create c:
	@set -e; \
	# Read from env/var injected by the parent make
	project="$${PROJECT:-}"; \
	# Prompt if still empty
	if [[ -z "$${project//[[:space:]]/}" ]]; then \
		read -p "📛 Enter project name: " project; \
	fi; \
	# Validate again
	if [[ -z "$${project//[[:space:]]/}" ]]; then \
		echo "❌ Error: Project name is required."; exit 1; \
	fi; \
	# Safety: path must not already exist
	if [ -e "$$project" ]; then \
		echo "❌ Path already exists: $$project"; exit 1; \
	fi; \
	# Create and link
	echo "📦 Creating Rust project: $$project"; \
	cargo new "$$project" --vcs none; \
	echo "🔗 Linking shared Makefile into project"; \
	ln -sfn "$(HOME)/Configs/rust/Makefile" "$$project/Makefile"; \
	echo "✅ Done → $$project"

# Initialize Git and create remote repo, then force SSH & copy .gitignore
repo rp:
	@set -e; \
	project="$(word 2, $(MAKECMDGOALS))"; \
	if [ -z "$$project" ]; then project="$(notdir "$$PWD")"; fi; \
	echo "📦 Project and repo name: $$project"; \
	echo "🌿 Initializing Git repository"; \
	$(MAKE) -f $(GIT_MAKEFILE) init; \
	echo "🛰  Creating GitHub repo"; \
	$(MAKE) -f $(GIT_MAKEFILE) create_repo $$project; \
	echo "🔐 Forcing SSH remote"; \
	$(MAKE) -f $(GIT_MAKEFILE) force_ssh $$project; \
	$(MAKE) copy_gitignore

delete_repo dr:
	@$(MAKE) -f $(GIT_MAKEFILE) delete_repo $(notdir $(CURDIR))

copy_gitignore gi:
	@set -e; \
	if [ -f $(GITIGNORE_TEMPLATE) ]; then \
		cp -f $(GITIGNORE_TEMPLATE) .gitignore; \
		echo "📄 Copied gitignore template to .gitignore"; \
	else \
		echo "⚠️  Warning: gitignore template not found at $(GITIGNORE_TEMPLATE)"; \
	fi; \
	$(MAKE) -f $(GIT_MAKEFILE) commit "add gitignore"

install i:
	@echo "🦀 Installing Rust toolchain and build tools via yay..."
	@yay -S --needed --noconfirm rust cargo rust-analyzer rust-src \
		llvm lldb binutils gcc pkgconf cmake make
	@echo "✅ Rust and related tools installed."

# Quick info about project: cargo manifest + git status
read rd:
	@echo "📖 Cargo manifest:"
	@sed -n '1,120p' Cargo.toml 2>/dev/null || echo "⚠️  Cargo.toml not found"
	@echo "────────────────────────────────────────────────────────────────────"
	@echo "🌿 Git status:"
	@git status -sb 2>/dev/null || echo "⚠️  Not a git repo"
:
