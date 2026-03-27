.PHONY: get ai

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
AI_MAKEFILE := $(THIS_DIR)/ai/Makefile

REPO_HTTP=https://github.com/KonstantinSKY/Configs.git
REPO_SSH=git@github.com:KonstantinSKY/Configs.git
DIR_NAME=Configs

get: ## Clone Configs repo via HTTPS and switch remote to SSH
	@echo "🔍 Checking if ./$(DIR_NAME) exists..."
	@if [ -d "$(DIR_NAME)" ]; then \
		TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
		BACKUP_NAME="$(DIR_NAME).backup_$$TIMESTAMP"; \
		echo "📦 Found existing directory. Backing up to ./$$BACKUP_NAME..."; \
		mv "$(DIR_NAME)" "$$BACKUP_NAME"; \
	else \
		echo "✅ No existing $(DIR_NAME) found."; \
	fi

	@echo "⬇️  Cloning via HTTPS..."
	@git clone $(REPO_HTTP)

	@echo "🔄 Switching remote to SSH..."
	@cd $(DIR_NAME) && git remote set-url origin $(REPO_SSH)

	@echo "✅ Done! Cloned to ./$(DIR_NAME) with SSH remote."

ai: ## Install AI CLI tools and setup Gemini shell policy
	@$(MAKE) -f "$(AI_MAKEFILE)" install
