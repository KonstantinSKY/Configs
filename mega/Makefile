# IMPORTANT FOR AI AGENTS:
# Do not modify this file without explicit user confirmation.

.PHONY: help h install setup auth login check sync s
.DEFAULT_GOAL := help

MAKEFLAGS += --no-print-directory

## ---------------------------
## 🧩 Path configuration
## ---------------------------
THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)
MANJARO_MAKEFILE := $(CONFIGS_DIR)/manjaro/Makefile

## ---------------------------
## 🧩 MegaCMD configuration
## ---------------------------
SEPARATOR := ---------------------------------------------------------------------
MEGA_LOGIN_COMMANDS := mega-whoami mega-login
MEGA_SYNC_COMMANDS := mega-whoami mega-ls mega-mkdir mega-sync

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

## ---------------------------
## 📦 Installation
## ---------------------------
install: ## Install MegaCMD package only
	@echo "📦 Installing MegaCMD..."
	@$(MAKE) -s -f "$(MANJARO_MAKEFILE)" install megacmd
	@echo "$(SEPARATOR)"
	@echo "✅ MegaCMD package installation finished."
	@echo "   Next step: make -f $(THIS_MAKEFILE) auth"

setup: ## Install MegaCMD, run interactive login, and verify access
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" install
	@echo "$(SEPARATOR)"
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" auth
	@echo "$(SEPARATOR)"
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" check

## ---------------------------
## 🔐 Authentication
## ---------------------------
auth login: ## Run interactive MegaCMD login unless an active session already exists
	@echo "🔍 Verifying MegaCMD tools..."
	@for cmd in $(MEGA_LOGIN_COMMANDS); do \
		if ! command -v "$$cmd" >/dev/null 2>&1; then \
			echo "❌ Missing MegaCMD command: $$cmd"; \
			echo "   Run: make -f $(THIS_MAKEFILE) install"; \
			exit 1; \
		fi; \
	done
	@echo "✅ MegaCMD tools are available."
	@echo "$(SEPARATOR)"
	@if mega-whoami >/dev/null 2>&1; then \
		echo "✅ MegaCMD session is already active."; \
		mega-whoami; \
	else \
		echo "🔐 Starting interactive MegaCMD login..."; \
		echo "   Enter your Mega account credentials in the prompt window."; \
		mega-login; \
	fi

check: ## Verify MegaCMD commands exist and that the current session is authenticated
	@echo "🔍 Verifying MegaCMD tools..."
	@for cmd in $(MEGA_SYNC_COMMANDS); do \
		if ! command -v "$$cmd" >/dev/null 2>&1; then \
			echo "❌ Missing MegaCMD command: $$cmd"; \
			echo "   Run: make -f $(THIS_MAKEFILE) install"; \
			exit 1; \
		fi; \
	done
	@echo "✅ MegaCMD tools are available."
	@echo "$(SEPARATOR)"
	@echo "🔐 Verifying Mega login..."
	@if mega-whoami >/dev/null 2>&1; then \
		echo "✅ MegaCMD session is active:"; \
		mega-whoami; \
	else \
		echo "🚫 MegaCMD is not logged in. Run: make -f $(THIS_MAKEFILE) auth"; \
		exit 1; \
	fi

## ---------------------------
## 🔄 Sync
## ---------------------------
sync s: ## Create or verify a MegaCMD sync between a local and remote path
	@if [ $(words $(MAKECMDGOALS)) -ne 3 ]; then \
		echo "❌ Usage: make sync <LOCAL_PATH> <REMOTE_PATH>"; \
		echo "Example: make sync /home/user/deploy /MyProjectDeploys/MyApp"; \
		exit 1; \
	fi; \
	LOCAL_PATH="$(word 2, $(MAKECMDGOALS))"; \
	REMOTE_PATH="$(word 3, $(MAKECMDGOALS))"; \
	\
	echo "📁 Local path: $$LOCAL_PATH"; \
	echo "🌐 Remote path: $$REMOTE_PATH"; \
	echo "$(SEPARATOR)"; \
	\
	echo "🔍 Verifying local path..."; \
	if [ ! -d "$$LOCAL_PATH" ]; then \
		echo "❌ Local path not found: $$LOCAL_PATH"; \
		exit 1; \
	fi; \
	echo "✅ Local path exists: $$LOCAL_PATH"; \
	echo "$(SEPARATOR)"; \
	\
	echo "🔍 Verifying MegaCMD environment..."; \
	for cmd in $(MEGA_SYNC_COMMANDS); do \
		if ! command -v "$$cmd" >/dev/null 2>&1; then \
			echo "❌ Missing MegaCMD command: $$cmd"; \
			echo "   Run: make -f $(THIS_MAKEFILE) install"; \
			exit 1; \
		fi; \
	done; \
	if ! mega-whoami >/dev/null 2>&1; then \
		echo "🚫 MegaCMD is not logged in. Run: make -f $(THIS_MAKEFILE) auth"; \
		exit 1; \
	fi; \
	echo "✅ MegaCMD environment is ready."; \
	echo "$(SEPARATOR)"; \
	\
	echo "🔍 Checking remote folder..."; \
	if ! mega-ls "$$REMOTE_PATH" >/dev/null 2>&1; then \
		echo "📁 Remote folder not found. Creating..."; \
		mega-mkdir -p "$$REMOTE_PATH" || { echo "❌ Failed to create remote folder"; exit 1; }; \
	fi; \
	echo "✅ Remote folder ready."; \
	echo "$(SEPARATOR)"; \
	\
	echo "📋 Checking for an existing sync..."; \
	if mega-sync | grep -F "$$LOCAL_PATH" | grep -F "$$REMOTE_PATH" >/dev/null; then \
		echo "✅ Sync already exists."; \
		exit 0; \
	fi; \
	echo "ℹ️  Existing sync not found. Creating a new one..."; \
	echo "$(SEPARATOR)"; \
	\
	echo "🔁 Starting sync..."; \
	mega-sync "$$LOCAL_PATH" "$$REMOTE_PATH" || { echo "❌ mega-sync failed"; exit 1; }; \
	echo "$(SEPARATOR)"; \
	\
	echo "📋 Verifying sync is active..."; \
	if mega-sync | grep -F "$$LOCAL_PATH" | grep -F "$$REMOTE_PATH" >/dev/null; then \
		echo "✅ Sync established."; \
	else \
		echo "⚠️  Sync not listed. Please verify manually."; \
			exit 1; \
		fi

# Prevent make from treating extra sync arguments as targets
%:
	@:
