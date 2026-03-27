.PHONY: symlinks common_symlinks bind_mounts

MAKEFLAGS += --no-print-directory
WORK_DIR = $(HOME)/Work

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
	@for pair in $(COMMON_SYMLINKS); do \
		SOURCE=$${pair#*:}; \
		TARGET="$(HOME)/$${pair%%:*}"; \
		echo "🛠️ Processing $$TARGET..."; \
		if [ -L "$$TARGET" ]; then \
			echo "🔁 Removing symlink $$TARGET"; \
			rm -f "$$TARGET"; \
		fi; \
		if [ ! -d "$$TARGET" ]; then \
			echo "📁 Creating directory $$TARGET"; \
			mkdir -p "$$TARGET"; \
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
