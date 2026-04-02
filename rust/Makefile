# IMPORTANT FOR AI AGENTS:
# Do not modify this file without explicit user confirmation.

.PHONY: help install i status st create c repo rp delete_repo dr copy_gitignore gi read rd
.DEFAULT_GOAL := help

MAKEFLAGS += --no-print-directory

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)
GIT_MAKEFILE := $(CONFIGS_DIR)/git/Makefile
GITIGNORE_TEMPLATE := $(THIS_DIR)/gitignore

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

SEPARATOR := ---------------------------------------------------------------------

# Project name: second word after target, or current directory name
PROJECT := $(word 2,$(MAKECMDGOALS))
ifeq ($(strip $(PROJECT)),)
PROJECT := $(notdir $(CURDIR))
endif

install i: ## Install rustup, stable toolchain, and core components
	@echo "🦀 Installing Rust via rustup..."
	@if ! command -v rustup >/dev/null 2>&1; then \
		echo "📦 Installing rustup..."; \
		sudo pacman -S --needed --noconfirm rustup; \
	else \
		echo "✅ rustup already installed: $$(rustup --version 2>/dev/null)"; \
	fi
	@echo "$(SEPARATOR)"
	@echo "🔧 Installing stable toolchain..."
	@rustup toolchain install stable
	@rustup default stable
	@echo "$(SEPARATOR)"
	@echo "📦 Adding core components..."
	@rustup component add rust-analyzer rust-src clippy rustfmt
	@echo "$(SEPARATOR)"
	@$(MAKE) -f "$(THIS_MAKEFILE)" status

status st: ## Show Rust toolchain, components, and targets
	@echo "Rust status"
	@echo "$(SEPARATOR)"
	@if command -v rustc >/dev/null 2>&1; then \
		echo "✅ rustc:   $$(rustc --version)"; \
	else \
		echo "❌ rustc not found"; \
	fi
	@if command -v cargo >/dev/null 2>&1; then \
		echo "✅ cargo:   $$(cargo --version)"; \
	else \
		echo "❌ cargo not found"; \
	fi
	@if command -v rustup >/dev/null 2>&1; then \
		echo "✅ rustup:  $$(rustup --version 2>/dev/null)"; \
	else \
		echo "❌ rustup not found"; \
	fi
	@echo "$(SEPARATOR)"
	@echo "🔧 Installed toolchains:"
	@rustup toolchain list 2>/dev/null || echo "  (rustup not available)"
	@echo "$(SEPARATOR)"
	@echo "📦 Installed components:"
	@rustup component list --installed 2>/dev/null || echo "  (rustup not available)"
	@echo "$(SEPARATOR)"
	@echo "🎯 Installed targets:"
	@rustup target list --installed 2>/dev/null || echo "  (rustup not available)"

create c: ## Create a new Rust project: make create <name>
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
	echo "📦 Creating Rust project: $$project"; \
	cargo new "$$project" --vcs none; \
	echo "🔗 Linking shared Makefile into project"; \
	ln -sfn "$(THIS_MAKEFILE)" "$$project/Makefile"; \
	echo "$(SEPARATOR)"; \
	echo "✅ Done → $$project"

repo rp: ## Init git, create GitHub repo, copy .gitignore: make repo [name]
	@set -e; \
	project="$(PROJECT)"; \
	echo "📦 Project: $$project"; \
	echo "$(SEPARATOR)"; \
	echo "🌿 Initializing git repository..."; \
	$(MAKE) -f "$(GIT_MAKEFILE)" git-init; \
	echo "$(SEPARATOR)"; \
	echo "🛰  Creating GitHub repo: $$project"; \
	gh repo create "$$project" --private --source=. --remote=origin --push; \
	echo "$(SEPARATOR)"; \
	$(MAKE) -f "$(THIS_MAKEFILE)" gi

delete_repo dr: ## Delete GitHub repo for current directory
	@echo "🗑  Deleting GitHub repo: $(notdir $(CURDIR))"; \
	gh repo delete "$(notdir $(CURDIR))" --yes

copy_gitignore gi: ## Copy .gitignore template into current project
	@if [ -f "$(GITIGNORE_TEMPLATE)" ]; then \
		cp -f "$(GITIGNORE_TEMPLATE)" .gitignore; \
		echo "📄 Copied .gitignore"; \
	else \
		echo "⚠️  gitignore template not found: $(GITIGNORE_TEMPLATE)"; \
	fi

read rd: ## Show Cargo.toml and git status for current project
	@echo "📖 Cargo.toml:"
	@sed -n '1,30p' Cargo.toml 2>/dev/null || echo "⚠️  Cargo.toml not found"
	@echo "$(SEPARATOR)"
	@echo "🌿 Git status:"
	@git status -sb 2>/dev/null || echo "⚠️  Not a git repo"

# Prevent make from treating project name as a target
%:
	@:
