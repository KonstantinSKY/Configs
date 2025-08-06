# Makefile for creating a deploy directory and its backup subdirectory
# URL: https://github.com/yourusername/yourrepo (замени на свой)

MAIN_DEPLOY_DIR := $(HOME)/Deploys
BACKUP_DIR := backups
MEGA_MAKEFILE := $(HOME)/Configs/mega/Makefile
REMOTE_DEPLOY_DIR := /Deploys

.PHONY: help create mkdir

help:
	@echo "📦 Usage:"
	@echo "    make create <project_name>"
	@echo "💡 This will create:"
	@echo "    $(MAIN_DEPLOY_DIR)/<project_name>/backup"

mkdir:
	@if [ "$(words $(MAKECMDGOALS))" -ne 2 ]; then \
		echo "❌ Error: Exactly one project name is required."; \
		echo "👉 Usage: make create <project_name>"; \
		exit 1; \
	fi; \
	PROJECT=$(word 2, $(MAKECMDGOALS)); \
	TARGET_DIR="$(MAIN_DEPLOY_DIR)/$$PROJECT/$(BACKUP_DIR)"; \
	echo "📁 Creating directory: $$TARGET_DIR" && \
	mkdir -p "$$TARGET_DIR" && \
	echo "✅ Done: $$TARGET_DIR created" && \
	ls -la "$(MAIN_DEPLOY_DIR)/$$PROJECT"

sync:
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
