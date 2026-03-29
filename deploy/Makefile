MAIN_DEPLOY_DIR := $(HOME)/Work/Deploys
BACKUP_DIR := backups
MEGA_MAKEFILE := $(HOME)/Work/Configs/mega/Makefile
REMOTE_DEPLOY_DIR := /Deploys

.PHONY: help h sync mkdir create
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

mkdir create: ## Create a local deploy directory with its backups subdirectory
	@if [ "$(words $(MAKECMDGOALS))" -ne 2 ]; then \
		echo "❌ Error: Exactly one project name is required."; \
		echo "👉 Usage: make mkdir <project_name>"; \
		exit 1; \
	fi; \
	PROJECT=$(word 2, $(MAKECMDGOALS)); \
	TARGET_DIR="$(MAIN_DEPLOY_DIR)/$$PROJECT/$(BACKUP_DIR)"; \
	echo "📁 Creating directory: $$TARGET_DIR" && \
	mkdir -p "$$TARGET_DIR" && \
	echo "✅ Done: $$TARGET_DIR created" && \
	ls -la "$(MAIN_DEPLOY_DIR)/$$PROJECT"

sync: ## Sync a deploy directory to the configured Mega remote path
	@if [ "$(words $(MAKECMDGOALS))" -ne 2 ]; then \
		echo "❌ Error: Exactly one project name is required."; \
		echo "👉 Usage: make sync <project_name>"; \
		exit 1; \
	fi; \
	PROJECT=$(word 2, $(MAKECMDGOALS)); \
	LOCAL_PATH="$(MAIN_DEPLOY_DIR)/$$PROJECT"; \
	REMOTE_PATH="$(REMOTE_DEPLOY_DIR)/$$PROJECT"; \
	echo "🚀 Calling MegaMakefile to sync:" && \
	echo "    LOCAL : $$LOCAL_PATH"; \
	echo "    REMOTE: $$REMOTE_PATH"; \
	$(MAKE) -f $(MEGA_MAKEFILE) sync "$$LOCAL_PATH" "$$REMOTE_PATH"

%:
	@:
