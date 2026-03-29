# IMPORTANT FOR AI AGENTS:
# Do not modify this file without explicit user confirmation.

.PHONY: help h symlinks common_symlinks
.DEFAULT_GOAL := help

MAKEFLAGS += --no-print-directory
THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)
WORK_DIR = $(HOME)/Work

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

COMMON_SYMLINKS = \
	Configs:$(WORK_DIR)/Configs \
	Projects:$(WORK_DIR)/Projects \
	Deploys:$(WORK_DIR)/Deploys \
	Music:$(WORK_DIR)/Music \
	Documents:$(WORK_DIR)/Documents \
	Downloads:$(WORK_DIR)/Downloads \
	Pictures:$(WORK_DIR)/Pictures

symlinks: ## Configures common home paths as symbolic links into $(WORK_DIR).
	@echo "🔗 Converting common home paths to symbolic links..."
	@mkdir -p "$(WORK_DIR)"
	@for pair in $(COMMON_SYMLINKS); do \
		SOURCE=$${pair#*:}; \
		TARGET="$(HOME)/$${pair%%:*}"; \
		echo "🛠️ Processing $$TARGET..."; \
		mkdir -p "$$SOURCE"; \
		if [ -L "$$TARGET" ]; then \
			CURRENT_LINK="$$(readlink -f "$$TARGET" 2>/dev/null || true)"; \
			DESIRED_LINK="$$(readlink -f "$$SOURCE" 2>/dev/null || true)"; \
			if [ "$$CURRENT_LINK" = "$$DESIRED_LINK" ]; then \
				echo "✅ Symlink already correct: $$TARGET -> $$SOURCE"; \
				continue; \
			fi; \
			BACKUP_PATH="$$TARGET.bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up existing symlink to $$BACKUP_PATH"; \
			mv "$$TARGET" "$$BACKUP_PATH"; \
		elif [ -d "$$TARGET" ]; then \
			if [ -n "$$(ls -A "$$TARGET" 2>/dev/null)" ]; then \
				BACKUP_PATH="$$TARGET.bak.$$(date +%Y%m%d_%H%M%S)"; \
				echo "📦 Backing up non-empty directory to $$BACKUP_PATH"; \
				mv "$$TARGET" "$$BACKUP_PATH"; \
			else \
				echo "🧹 Removing empty directory $$TARGET"; \
				rmdir "$$TARGET"; \
			fi; \
		elif [ -e "$$TARGET" ]; then \
			BACKUP_PATH="$$TARGET.bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up existing target to $$BACKUP_PATH"; \
			mv "$$TARGET" "$$BACKUP_PATH"; \
		fi; \
		echo "🔗 Linking $$TARGET -> $$SOURCE"; \
		ln -sfn "$$SOURCE" "$$TARGET"; \
	done
	@echo "✅ Workspace symbolic links configured."

common_symlinks: symlinks ## Backward-compatible alias; configures symbolic links.
