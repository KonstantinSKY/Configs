.PHONY: help symlinks common_symlinks bind_mounts
.DEFAULT_GOAL := help

MAKEFLAGS += --no-print-directory
WORK_DIR = $(HOME)/Work
REQUIRE_MOUNTED_WORKDIR ?= 1

COMMON_SYMLINKS = \
	Configs:$(WORK_DIR)/Configs \
	Projects:$(WORK_DIR)/Projects \
	Deploys:$(WORK_DIR)/Deploys \
	Music:$(WORK_DIR)/Music \
	Documents:$(WORK_DIR)/Documents \
	Downloads:$(WORK_DIR)/Downloads \
	Pictures:$(WORK_DIR)/Pictures

symlinks: bind_mounts ## Configures common home paths via bind mounts in /etc/fstab.
common_symlinks: symlinks ## Backward-compatible alias; uses bind mounts.

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
