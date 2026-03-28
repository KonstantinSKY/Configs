# IMPORTANT FOR AI AGENTS:
# Do not modify this file without explicit user confirmation.

.PHONY: help mount verify_fstab
.DEFAULT_GOAL := help

## ---------------------------
## 🧩 Directory configuration
## ---------------------------
MAKEFLAGS += --no-print-directory
WORK_DIR = $(HOME)/$(DIR)

## ---------------------------
## 🧩 Mount configuration
## ---------------------------
LABEL = Work
DIR = Work
FS_TYPE = btrfs
OPTIONS = compress=zstd,noatime
DUMP = 0
PASS = 2
FSTAB = /etc/fstab
UUID = $(shell sudo blkid -s UUID -o value $$(sudo findfs LABEL=$(LABEL)))
MOUNT_DIR = $(WORK_DIR)

mount: ## Mounts the work drive, creates mount point, and adds to fstab.
	@echo "🔍 Searching for device with label '$(LABEL)'..."
	@if [ -z "$(UUID)" ]; then \
		echo "❌ Device with label '$(LABEL)' not found!"; exit 1; \
	else \
		echo "✅ UUID found: $(UUID)"; \
	fi
	@echo "📁 Creating directory $(MOUNT_DIR) if it doesn't exist..."
	@mkdir -p "$(MOUNT_DIR)"
	@echo "📌 Checking if entry already exists in $(FSTAB)..."
	@if grep -q "$(MOUNT_DIR)" $(FSTAB); then \
		echo "⚠️  Entry already exists in $(FSTAB). Skipping..."; \
	else \
		if [ ! -f $(FSTAB).bak ]; then sudo cp $(FSTAB) $(FSTAB).bak; fi; \
		echo "📥 Adding new entry to $(FSTAB)..."; \
		echo "UUID=$(UUID) $(MOUNT_DIR) $(FS_TYPE) $(OPTIONS) $(DUMP) $(PASS)" | sudo tee -a $(FSTAB); \
	fi
	@$(MAKE) verify_fstab
	@echo "🔄 Reloading systemd daemon..."
	@sudo systemctl daemon-reexec
	@echo "📦 Mounting all entries..."
	@sudo mount -a || echo "❌ Mount failed. Please check /etc/fstab or device."
	@echo "📂 Verifying mount status..."
	@if mount | grep -q "$(MOUNT_DIR)"; then \
		echo "✅ Mounted successfully at $(MOUNT_DIR)"; \
	else \
		echo "❌ Mount failed. Check /etc/fstab and system logs."; \
		exit 1; \
	fi
	@echo "📂 Listing contents of $(MOUNT_DIR)..."
	@ls -la "$(MOUNT_DIR)"
	@echo "🔐 Setting ownership and permissions for $(MOUNT_DIR)..."
	@sudo chown -R $(shell whoami):$(shell whoami) "$(MOUNT_DIR)"
	@sudo chmod -R 700 "$(MOUNT_DIR)"
	@echo "✅ Done. $(DIR) is mounted with options: $(OPTIONS)."

verify_fstab: ## Verifies the integrity of /etc/fstab.
	@echo "🔍 Verifying integrity of $(FSTAB)..."
	@sudo findmnt --verify || { \
		echo "❌ fstab verification failed! Restoring backup..."; \
		sudo cp $(FSTAB).bak $(FSTAB); \
		exit 1; \
	}
	sudo cat $(FSTAB)

%:
	@:
