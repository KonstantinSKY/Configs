SHELL              := /bin/bash
APP_DIR            := $(shell cd "$(dir $(lastword $(MAKEFILE_LIST)))" && pwd)

# ── Paths ──────────────────────────────────────────────────────────────────────
DESKTOP_NAME       := voice-ptt.desktop
DESKTOP_SRC        := $(APP_DIR)/$(DESKTOP_NAME)
AUTOSTART_DIR      := $(HOME)/.config/autostart
AUTOSTART_DST      := $(AUTOSTART_DIR)/$(DESKTOP_NAME)

PLIST_NAME         := com.sky.voice-ptt.plist
PLIST_SRC          := $(APP_DIR)/$(PLIST_NAME)
LAUNCH_AGENTS_DIR  := $(HOME)/Library/LaunchAgents
PLIST_DST          := $(LAUNCH_AGENTS_DIR)/$(PLIST_NAME)
LAUNCHD_LABEL      := com.sky.voice-ptt

ENV_FILE           := $(APP_DIR)/.env
ENV_EXAMPLE        := $(APP_DIR)/.env.example
ENV_PLACEHOLDER    := sk-\.\.\.

RESTART_SCRIPT     := $(APP_DIR)/restart_voice_ptt.sh

.DEFAULT_GOAL := help
.PHONY: help install install-linux install-macos check-env

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Auto-detect OS and install
	@case "$$(uname)" in \
	  Darwin) $(MAKE) install-macos ;; \
	  Linux)  $(MAKE) install-linux ;; \
	  *) echo "Unsupported OS: $$(uname)"; exit 1 ;; \
	esac

# ── Linux ──────────────────────────────────────────────────────────────────────

install-linux: ## Install on Linux (autostart symlink), then start if .env is ready
	@mkdir -p "$(AUTOSTART_DIR)"
	@ln -sf "$(DESKTOP_SRC)" "$(AUTOSTART_DST)"
	@echo "Linked autostart entry → $(AUTOSTART_DST)"
	@if $(MAKE) --no-print-directory -s check-env 2>/dev/null; then \
		echo "Starting voice-ptt..."; \
		bash "$(RESTART_SCRIPT)"; \
	else \
		echo "voice-ptt will not start — fix .env and run: make install-linux"; \
	fi

# ── macOS ──────────────────────────────────────────────────────────────────────

install-macos: ## Install on macOS (LaunchAgent), then start if .env is ready
	@mkdir -p "$(LAUNCH_AGENTS_DIR)"
	@install -m 644 "$(PLIST_SRC)" "$(PLIST_DST)"
	@echo "Installed $(PLIST_DST)"
	@DOMAIN="gui/$$(id -u)"; \
	launchctl bootout "$$DOMAIN/$(LAUNCHD_LABEL)" >/dev/null 2>&1 || true; \
	launchctl bootstrap "$$DOMAIN" "$(PLIST_DST)"; \
	launchctl enable "$$DOMAIN/$(LAUNCHD_LABEL)"; \
	echo "Loaded $$DOMAIN/$(LAUNCHD_LABEL)"; \
	if $(MAKE) --no-print-directory -s check-env 2>/dev/null; then \
		echo "Starting voice-ptt..."; \
		launchctl kickstart -k "$$DOMAIN/$(LAUNCHD_LABEL)"; \
	else \
		echo "voice-ptt will not start — fix .env and run: make install-macos"; \
	fi

# ── helpers ────────────────────────────────────────────────────────────────────

check-env: ## Check .env exists and has a real key (exit 1 with warning otherwise)
	@if [ ! -f "$(ENV_FILE)" ]; then \
		echo "WARNING: .env not found. Create it: cp $(ENV_EXAMPLE) $(ENV_FILE)"; \
		exit 1; \
	fi
	@if grep -q "$(ENV_PLACEHOLDER)" "$(ENV_FILE)"; then \
		echo "WARNING: OPENAI_API_KEY is still a placeholder — edit $(ENV_FILE)"; \
		exit 1; \
	fi
