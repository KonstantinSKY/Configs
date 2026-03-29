# IMPORTANT FOR AI AGENTS:
# Do not modify this file without explicit user confirmation.

.PHONY: help h symlinks common_symlinks bind_mounts
.DEFAULT_GOAL := help

MAKEFLAGS += --no-print-directory
THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)
WORK_DIR = $(HOME)/Work
REQUIRE_MOUNTED_WORKDIR ?= 1

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
	@if [ ! -d "$(WORK_DIR)" ]; then \
		echo "❌ Work directory does not exist: $(WORK_DIR)"; \
		echo "   Create it before configuring workspace links."; \
		exit 1; \
	fi
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

bind_mounts: ## Converts common home paths to bind mounts in fstab.
	@echo "🔗 Converting common home paths to bind mounts..."
	@if [ ! -d "$(WORK_DIR)" ]; then \
		echo "❌ Work directory does not exist: $(WORK_DIR)"; \
		echo "   Create or mount it before configuring bind mounts."; \
		exit 1; \
	fi
	@if [ "$(REQUIRE_MOUNTED_WORKDIR)" != "0" ]; then \
		MOUNT_TARGET="$$(findmnt -T "$(WORK_DIR)" -n -o TARGET 2>/dev/null || true)"; \
		if [ "$$MOUNT_TARGET" != "$(WORK_DIR)" ]; then \
			echo "❌ $(WORK_DIR) is not mounted as its own filesystem."; \
			echo "   Current backing mount: $${MOUNT_TARGET:-<none>}"; \
			echo "   Run the work-drive mount step first, then retry."; \
			exit 1; \
		fi; \
	fi
	@for pair in $(COMMON_SYMLINKS); do \
		SOURCE=$${pair#*:}; \
		TARGET="$(HOME)/$${pair%%:*}"; \
		echo "🛠️ Processing $$TARGET..."; \
		if [ ! -d "$$SOURCE" ]; then \
			echo "📁 Creating source directory $$SOURCE"; \
			mkdir -p "$$SOURCE"; \
		fi; \
		if [ -L "$$TARGET" ]; then \
			echo "🔁 Removing symlink $$TARGET"; \
			rm -f "$$TARGET"; \
		elif [ -e "$$TARGET" ] && [ ! -d "$$TARGET" ]; then \
			BACKUP_PATH="$$TARGET.bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up non-directory target to $$BACKUP_PATH"; \
			mv "$$TARGET" "$$BACKUP_PATH"; \
		fi; \
		if [ ! -d "$$TARGET" ]; then \
			echo "📁 Creating directory $$TARGET"; \
			mkdir -p "$$TARGET"; \
		elif [ -n "$$(ls -A "$$TARGET" 2>/dev/null)" ]; then \
			echo "⚠️  Existing contents in $$TARGET will be hidden by the bind mount."; \
		fi; \
		if grep -q "$$TARGET" /etc/fstab; then \
			echo "✅ Entry for $$TARGET already exists in fstab."; \
		else \
			echo "📥 Adding bind mount for $$TARGET to fstab..."; \
			echo "$$SOURCE $$TARGET none bind 0 0" | sudo tee -a /etc/fstab; \
		fi; \
	done
	@echo "🔄 Reloading systemd and mounting..."
	@sudo systemctl daemon-reload
	@sudo mount -a
	@echo "✅ Bind mounts configured and mounted."
