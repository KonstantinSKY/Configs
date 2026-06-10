# IMPORTANT FOR AI AGENTS:
# Do not modify this file without explicit user confirmation.

.PHONY: help install i update u status st doctor d macos_targets macos-targets mt macos_cross_deps macos-cross-deps mcd create c repo rp delete_repo dr copy_gitignore gi read rd rust rs crate cr
.DEFAULT_GOAL := help

MAKEFLAGS += --no-print-directory

THIS_MAKEFILE := $(realpath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)
GIT_MAKEFILE := $(CONFIGS_DIR)/make/all.mk
GITIGNORE_TEMPLATE := $(THIS_DIR)/gitignore
MACOS_TARGETS := aarch64-apple-darwin x86_64-apple-darwin
MACOS_CROSS_DEPS := clang llvm lld cmake patch python openssl xz bzip2 cpio libxml2
ARG_GOALS := create c repo rp crate cr
EXTRA_GOALS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

SEPARATOR := ---------------------------------------------------------------------

# Project name: second word after target, or current directory name
PROJECT := $(word 2,$(MAKECMDGOALS))
ifeq ($(strip $(PROJECT)),)
PROJECT := $(notdir $(CURDIR))
endif

install i: ## Install rustup, stable toolchain, core components, and macOS targets
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
	@$(MAKE) -f "$(THIS_MAKEFILE)" macos_targets
	@echo "$(SEPARATOR)"
	@$(MAKE) -f "$(THIS_MAKEFILE)" status

update u: ## Update stable toolchain and installed components
	@echo "🔄 Updating Rust stable toolchain..."
	@rustup update stable
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

doctor d: ## Check Rust, PATH, GitHub CLI auth, and macOS cross prerequisites
	@echo "Rust doctor"
	@echo "$(SEPARATOR)"
	@$(MAKE) -f "$(THIS_MAKEFILE)" status
	@echo "$(SEPARATOR)"
	@echo "🧭 PATH check:"
	@if command -v rustup >/dev/null 2>&1 || command -v cargo >/dev/null 2>&1; then \
		echo "✅ Rust commands are visible in PATH"; \
	elif echo "$$PATH" | tr ':' '\n' | grep -qx "$$HOME/.cargo/bin"; then \
		echo "⚠️  $$HOME/.cargo/bin is in PATH, but Rust commands are missing"; \
	else \
		echo "❌ $$HOME/.cargo/bin is not in PATH"; \
	fi
	@echo "$(SEPARATOR)"
	@echo "🛰  GitHub CLI:"
	@gh auth status 2>/dev/null || echo "⚠️  GitHub CLI is not authenticated"
	@echo "$(SEPARATOR)"
	@echo "🍎 macOS cross-toolchain:"
	@if command -v o64-clang >/dev/null 2>&1 || command -v arm64-apple-darwin-clang >/dev/null 2>&1; then \
		echo "✅ osxcross compiler wrapper found"; \
	else \
		echo "⚠️  osxcross compiler wrapper not found"; \
		echo "   Linux → macOS linking still needs osxcross and a MacOSX.sdk"; \
	fi

macos_targets macos-targets mt: ## Add Rust stdlib targets for macOS builds
	@echo "🍎 Adding Rust macOS targets..."
	@rustup target add $(MACOS_TARGETS)

macos_cross_deps macos-cross-deps mcd: ## Install Linux packages needed to build osxcross
	@echo "🍎 Installing Linux deps for macOS cross-toolchain..."
	@sudo pacman -S --needed --noconfirm $(MACOS_CROSS_DEPS)

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

rust rs: ## Scaffold a Cargo workspace in the CURRENT dir (root + first crate): make rust
	@set -e; \
	project="$(notdir $(CURDIR))"; \
	if [ -f Cargo.toml ]; then echo "❌ Cargo.toml already exists here — refusing to overwrite."; exit 1; fi; \
	echo "🦀 Scaffolding Cargo workspace: $$project"; \
	printf '%s\n' '[workspace]' 'resolver = "3"' 'members = ["crates/*"]' '' '[workspace.package]' 'version = "0.1.0"' 'edition = "2024"' '' '[workspace.dependencies]' > Cargo.toml; \
	printf '%s\n' '[toolchain]' 'channel = "stable"' > rust-toolchain.toml; \
	printf '%s\n' 'edition = "2024"' > rustfmt.toml; \
	if [ -f "$(GITIGNORE_TEMPLATE)" ]; then cp -f "$(GITIGNORE_TEMPLATE)" .gitignore; else printf '%s\n' '/target' > .gitignore; fi; \
	echo "$(SEPARATOR)"; \
	echo "📦 First crate: crates/$$project (lib)"; \
	cargo new --lib "crates/$$project"; \
	sed -i 's/^version = .*/version.workspace = true/; s/^edition = .*/edition.workspace = true/' "crates/$$project/Cargo.toml"; \
	echo "$(SEPARATOR)"; \
	echo "✅ Workspace ready → cargo build   |   add crates: make crate <name>"

crate cr: ## Add a crate to crates/: make crate <name>   (binary: make crate <name> BIN=1)
	@set -e; \
	name="$(word 2,$(MAKECMDGOALS))"; \
	if [ -z "$${name//[[:space:]]/}" ]; then read -p "📦 Crate name: " name; fi; \
	if [ -z "$${name//[[:space:]]/}" ]; then echo "❌ Crate name is required."; exit 1; fi; \
	if [ ! -f Cargo.toml ]; then echo "❌ No workspace here — run 'make rust' first."; exit 1; fi; \
	if [ -e "crates/$$name" ]; then echo "❌ crates/$$name already exists."; exit 1; fi; \
	echo "📦 Adding crate: crates/$$name $(if $(BIN),(bin),(lib))"; \
	cargo new $(if $(BIN),,--lib) "crates/$$name"; \
	sed -i 's/^version = .*/version.workspace = true/; s/^edition = .*/edition.workspace = true/' "crates/$$name/Cargo.toml"; \
	echo "✅ Added → crates/$$name"

repo rp: ## Init git, create GitHub repo, copy .gitignore: make repo [name]
	@echo "📦 Project: $(PROJECT)"
	@echo "$(SEPARATOR)"
	@$(MAKE) -f "$(THIS_MAKEFILE)" gi
	@echo "$(SEPARATOR)"
	@echo "🌿 Initializing git repository..."
	@$(MAKE) -f "$(GIT_MAKEFILE)" git-init
	@echo "$(SEPARATOR)"
	@echo "🛰  Creating GitHub repo: $(PROJECT)"
	@gh repo create "$(PROJECT)" --private --source=. --remote=origin --push

delete_repo dr: ## Delete GitHub repo for current directory
	@repo="$(notdir $(CURDIR))"; \
	if [ "$(CONFIRM)" != "$$repo" ]; then \
		echo "⚠️  Refusing to delete GitHub repo without confirmation."; \
		echo "   Run: make delete_repo CONFIRM=$$repo"; \
		exit 1; \
	fi; \
	echo "🗑  Deleting GitHub repo: $$repo"; \
	gh repo delete "$$repo" --yes

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

ifneq ($(filter $(firstword $(MAKECMDGOALS)),$(ARG_GOALS)),)
$(EXTRA_GOALS):
	@:
endif
