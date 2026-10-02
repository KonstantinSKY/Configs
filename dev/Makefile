SHELL := /bin/bash
export PATH := $(HOME)/.local/bin:$(HOME)/.cargo/bin:$(PATH)

.PHONY: help h status st restore r restore-packages restore-workspace restore-user \
	restore-ai restore-desktop restore-devtools verify v verify-shell verify-ai \
	verify-devtools restore-rust restore-python-tools rust-install python-tools-install \
	verify-rust devtools-install devtools-verify
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)
WORK_DIR ?= $(HOME)/Work
CANONICAL_CONFIGS := $(WORK_DIR)/Configs
STATE_DIR := $(HOME)/.local/state/configs/dev-v1

PACKAGES_MAKEFILE := $(CONFIGS_DIR)/packages/Makefile
WORKSPACE_MAKEFILE := $(CONFIGS_DIR)/workspace/Makefile
SHELL_MAKEFILE := $(CONFIGS_DIR)/shell/Makefile
AI_MAKEFILE := $(CONFIGS_DIR)/ai/Makefile
TMUX_MAKEFILE := $(CONFIGS_DIR)/tmux/Makefile
RUST_MAKEFILE := $(CONFIGS_DIR)/rust/Makefile

SUDO := $(shell if [ "$$(id -u)" -eq 0 ]; then echo ""; else echo "sudo"; fi)

DEV_PACKAGES_ARCH := \
	rustup \
	nodejs \
	npm \
	python \
	python-pip \
	uv \
	sqlite \
	clang \
	pkgconf \
	openssl \
	docker \
	docker-compose

DEV_PACKAGES_DEBIAN := \
	build-essential \
	rustup \
	nodejs \
	npm \
	python3 \
	python3-pip \
	python3-venv \
	sqlite3 \
	clang \
	pkg-config \
	libssl-dev \
	docker.io \
	docker-compose-v2

help h: ## Show dev restore commands
	@echo "Dev restore profile (without AIX)"
	@echo
	@echo "  make -f dev/Makefile status"
	@echo "  make -f dev/Makefile restore"
	@echo "  make -f dev/Makefile verify"
	@echo
	@echo "Stages:"
	@echo "  restore-packages   base, tailscale, workstation packages"
	@echo "  restore-workspace  Work directories and XDG symlinks"
	@echo "  restore-user       shell rc loader"
	@echo "  restore-ai         Codex/Claude binaries and shared profile links"
	@echo "  restore-desktop    desktop packages/fonts when supported"
	@echo "  restore-devtools   Rust/Node/Python/Docker/SQLite build tools"
	@echo "  restore-rust       Rust toolchains, components, targets, and cargo tools"
	@echo "  restore-python-tools Modern Python tools, currently uv"
	@echo
	@echo "AIX is intentionally not installed or verified by this profile."

check-work:
	@if [[ "$$(realpath -m "$(CONFIGS_DIR)")" != "$$(realpath -m "$(CANONICAL_CONFIGS)")" ]]; then \
		echo "ERROR: run dev restore from $(CANONICAL_CONFIGS)."; \
		echo "Current repository: $(CONFIGS_DIR)"; \
		exit 1; \
	fi
	@if [[ ! -d "$(CONFIGS_DIR)/.git" ]]; then \
		echo "ERROR: Git repository not found at $(CONFIGS_DIR)."; \
		exit 1; \
	fi

status st: ## Inspect dev restore progress without changes
	@set -u; \
	echo "Configs root: $(CONFIGS_DIR)"; \
	echo "Work path:    $(WORK_DIR)"; \
	$(MAKE) --no-print-directory -f "$(PACKAGES_MAKEFILE)" detect || true; \
	echo "Checkpoints:  $(STATE_DIR)"; \
	for stage in packages workspace user ai desktop devtools rust python-tools verify; do \
		if [[ -f "$(STATE_DIR)/$$stage" ]]; then echo "DONE: $$stage"; else echo "PENDING: $$stage"; fi; \
	done; \
	if [[ -d "$(WORK_DIR)" ]]; then echo "OK: Work directory exists"; else echo "MISSING: $(WORK_DIR)"; fi; \
	$(MAKE) --no-print-directory -f "$(SHELL_MAKEFILE)" status || true; \
	$(MAKE) --no-print-directory -f "$(AI_MAKEFILE)" logins || true; \
	$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" STATUS_ONLY=1 devtools-verify; \
	$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" STATUS_ONLY=1 verify-rust

restore r: check-work ## Restore dev profile in resumable stages, without AIX
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" restore-packages
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" restore-workspace
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" restore-user
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" restore-ai
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" restore-desktop
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" restore-devtools
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" restore-rust
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" restore-python-tools
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" verify
	@echo "Dev restore complete. Open a new shell or re-login to load shell changes."

restore-packages: check-work ## Install base, Tailscale, and workstation package profile
	@if [[ -f "$(STATE_DIR)/packages" ]]; then \
		echo "SKIP: packages checkpoint already completed"; \
	else \
		$(MAKE) --no-print-directory -f "$(PACKAGES_MAKEFILE)" install-profile; \
		mkdir -p "$(STATE_DIR)"; \
		printf '%s\n' packages > "$(STATE_DIR)/packages"; \
	fi

restore-workspace: check-work ## Restore Work directories and XDG home symlinks
	@if [[ -f "$(STATE_DIR)/workspace" ]]; then \
		echo "SKIP: workspace checkpoint already completed"; \
	else \
		$(MAKE) --no-print-directory -f "$(WORKSPACE_MAKEFILE)" symlinks; \
		mkdir -p "$(STATE_DIR)"; \
		printf '%s\n' workspace > "$(STATE_DIR)/workspace"; \
	fi

restore-user: check-work ## Link Configs shell rc into bash/zsh
	@$(MAKE) --no-print-directory -f "$(TMUX_MAKEFILE)" install
	@if [[ -f "$(STATE_DIR)/user" ]]; then \
		echo "SKIP: user checkpoint already completed"; \
	else \
		$(MAKE) --no-print-directory -f "$(SHELL_MAKEFILE)" link; \
		mkdir -p "$(STATE_DIR)"; \
		printf '%s\n' user > "$(STATE_DIR)/user"; \
	fi

restore-ai: check-work ## Install Codex/Claude and link shared AI profile config
	@if [[ -f "$(STATE_DIR)/ai" ]]; then \
		echo "SKIP: ai checkpoint already completed"; \
	else \
		$(MAKE) --no-print-directory -f "$(AI_MAKEFILE)" install-no-update; \
		$(MAKE) --no-print-directory -f "$(AI_MAKEFILE)" accounts; \
		mkdir -p "$(STATE_DIR)"; \
		printf '%s\n' ai > "$(STATE_DIR)/ai"; \
	fi

restore-desktop: check-work ## Install desktop/font packages when supported by the host profile
	@if [[ -f "$(STATE_DIR)/desktop" ]]; then \
		echo "SKIP: desktop checkpoint already completed"; \
	else \
		profile="$$($(MAKE) --no-print-directory -s -f "$(PACKAGES_MAKEFILE)" profile)"; \
		case "$$profile" in \
			arch-desktop) \
				$(MAKE) --no-print-directory -f "$(PACKAGES_MAKEFILE)" install-desktop; \
				$(MAKE) --no-print-directory -f "$(PACKAGES_MAKEFILE)" install-fonts ;; \
			*) echo "SKIP: desktop restore is not mapped for profile $$profile" ;; \
		esac; \
		mkdir -p "$(STATE_DIR)"; \
		printf '%s\n' desktop > "$(STATE_DIR)/desktop"; \
	fi

restore-devtools: check-work devtools-install ## Install development tools and save checkpoint
	@mkdir -p "$(STATE_DIR)"
	@printf '%s\n' devtools > "$(STATE_DIR)/devtools"

restore-rust: check-work ## Install Rust toolchains, components, targets, and cargo tools
	@if [[ -f "$(STATE_DIR)/rust" ]]; then \
		echo "SKIP: rust checkpoint already completed"; \
	else \
		$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" rust-install; \
		mkdir -p "$(STATE_DIR)"; \
		printf '%s\n' rust > "$(STATE_DIR)/rust"; \
	fi

restore-python-tools: check-work python-tools-install ## Install modern Python tooling and save checkpoint
	@mkdir -p "$(STATE_DIR)"
	@printf '%s\n' python-tools > "$(STATE_DIR)/python-tools"

rust-install: ## Install Rust workstation tooling used by local projects
	@$(MAKE) --no-print-directory -f "$(RUST_MAKEFILE)" install
	@echo "🧰 Installing project-specific Rust cargo tools..."
	@cargo install wasm-pack --locked
	@cargo install sqlx-cli --locked

python-tools-install: ## Install modern Python project tools
	@set -euo pipefail; \
	if command -v uv >/dev/null 2>&1; then \
		echo "OK: uv already installed"; \
	else \
		echo "🧰 Installing uv..."; \
		tmp_dir="$$(mktemp -d)"; \
		trap 'rm -rf "$$tmp_dir"' EXIT; \
		curl -LsSf https://astral.sh/uv/install.sh -o "$$tmp_dir/install-uv.sh"; \
		mkdir -p "$(HOME)/.local/bin"; \
		env UV_INSTALL_DIR="$(HOME)/.local/bin" UV_NO_MODIFY_PATH=1 sh "$$tmp_dir/install-uv.sh"; \
	fi

devtools-install: ## Install Rust/Node/Python/Docker/SQLite build tools for this distro family
	@set -euo pipefail; \
	. /etc/os-release; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) \
			command -v yay >/dev/null 2>&1 || $(MAKE) --no-print-directory -f "$(PACKAGES_MAKEFILE)" install-yay-arch; \
			yay -S --needed --noconfirm $(DEV_PACKAGES_ARCH); \
			$(SUDO) systemctl enable --now docker.service ;; \
		*' debian '*|*' ubuntu '*) \
			$(SUDO) apt-get update; \
			$(SUDO) DEBIAN_FRONTEND=noninteractive apt-get install -y $(DEV_PACKAGES_DEBIAN); \
			$(SUDO) systemctl enable --now docker.service ;; \
		*) echo "ERROR: unsupported devtools distro: ID=$${ID:-unknown} ID_LIKE=$${ID_LIKE:-none}"; exit 1 ;; \
	esac

verify v: check-work ## Verify dev profile without AIX
	@$(MAKE) --no-print-directory -f "$(PACKAGES_MAKEFILE)" verify-profile
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" verify-shell
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" verify-ai
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" verify-devtools
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" verify-rust
	@mkdir -p "$(STATE_DIR)"
	@printf '%s\n' verify > "$(STATE_DIR)/verify"

verify-shell: ## Verify shell rc syntax and loader status
	@$(MAKE) --no-print-directory -f "$(SHELL_MAKEFILE)" verify
	@$(MAKE) --no-print-directory -f "$(SHELL_MAKEFILE)" status

verify-ai: ## Verify Codex/Claude binaries and shared config links
	@$(MAKE) --no-print-directory -f "$(AI_MAKEFILE)" verify
	@$(MAKE) --no-print-directory -f "$(AI_MAKEFILE)" logins

verify-devtools devtools-verify: ## Verify development tools without AIX
	@set -euo pipefail; \
	failed=0; \
	for command_name in git make ssh curl zsh tmux nvim node npm sqlite3 clang docker; do \
		if command -v "$$command_name" >/dev/null 2>&1; then echo "OK: $$command_name"; \
		else echo "MISSING: $$command_name"; failed=1; fi; \
	done; \
	if command -v python3 >/dev/null 2>&1; then echo "OK: python3"; \
	elif command -v python >/dev/null 2>&1; then echo "OK: python"; \
	else echo "MISSING: python/python3"; failed=1; fi; \
	if command -v pip3 >/dev/null 2>&1; then echo "OK: pip3"; \
	elif command -v pip >/dev/null 2>&1; then echo "OK: pip"; \
	else echo "MISSING: pip/pip3"; failed=1; fi; \
	if command -v uv >/dev/null 2>&1; then echo "OK: uv"; \
	else echo "MISSING: uv"; failed=1; fi; \
	if command -v cargo >/dev/null 2>&1; then echo "OK: cargo"; \
	elif command -v rustup >/dev/null 2>&1; then echo "OK: rustup (cargo may appear after rustup default stable)"; \
	else echo "MISSING: rustup/cargo"; failed=1; fi; \
	if command -v systemctl >/dev/null 2>&1 && systemctl show --property=Version --value >/dev/null 2>&1; then \
		if systemctl is-active --quiet docker.service; then echo "ACTIVE: docker.service"; \
		else echo "INACTIVE: docker.service"; failed=1; fi; \
	else \
		echo "UNKNOWN: systemd unavailable"; \
	fi; \
	if [[ "$(STATUS_ONLY)" = 1 ]]; then exit 0; fi; \
	exit "$$failed"

verify-rust: ## Verify Rust toolchains, targets, and cargo tools
	@set -euo pipefail; \
	failed=0; \
	for command_name in rustc cargo rustup rust-analyzer cargo-nextest cargo-audit cargo-deny cargo-machete cargo-watch cargo-leptos wasm-pack sqlx; do \
		if command -v "$$command_name" >/dev/null 2>&1; then echo "OK: $$command_name"; \
		else echo "MISSING: $$command_name"; failed=1; fi; \
	done; \
	rustup toolchain list 2>/dev/null | grep -q '^stable' && echo "OK: stable toolchain" || { echo "MISSING: stable toolchain"; failed=1; }; \
	rustup toolchain list 2>/dev/null | grep -q '^nightly' && echo "OK: nightly toolchain" || { echo "MISSING: nightly toolchain"; failed=1; }; \
	rustup target list --installed 2>/dev/null | grep -qx 'wasm32-unknown-unknown' && echo "OK: wasm32-unknown-unknown" || { echo "MISSING: wasm32-unknown-unknown"; failed=1; }; \
	if [[ "$(STATUS_ONLY)" = 1 ]]; then exit 0; fi; \
	exit "$$failed"
