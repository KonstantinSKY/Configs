.PHONY: all mount defrag

LABEL = Work
DIR = Work
FS_TYPE = btrfs
OPTIONS = compress=zstd,noatime
DUMP = 0
PASS = 2
FSTAB = /etc/fstab
UUID = $(shell sudo blkid -s UUID -o value $$(sudo findfs LABEL=$(LABEL)))
ROOT_UUID = $(shell findmnt -no UUID /)
MOUNT_DIR = $(HOME)/$(DIR)

# Default target
all: mount

mount:
	@echo "🔍 Searching for device with label '$(LABEL)'..."
	@if [ -z "$(UUID)" ]; then \
		echo "❌ Device with label '$(LABEL)' not found!"; exit 1; \
	else \
		echo "✅ UUID found: $(UUID)"; \
	fi

	@echo "--------------------------------------------------------------"
	@echo "📁 Creating directory $(MOUNT_DIR) if it doesn't exist..."
	@mkdir -p "$(MOUNT_DIR)"
	@echo "--------------------------------------------------------------"
	@echo "📌 Checking if entry already exists in $(FSTAB)..."
	@if grep -q "$(UUID)" $(FSTAB); then \
		echo "⚠️  Entry already exists in $(FSTAB). Skipping..."; \
	else \
		echo "📦 Backing up $(FSTAB) -> $(FSTAB).bak"; \
		sudo cp $(FSTAB) $(FSTAB).bak; \
		echo "📥 Adding new entry to $(FSTAB)..."; \
		echo "UUID=$(UUID) $(MOUNT_DIR) $(FS_TYPE) $(OPTIONS) $(DUMP) $(PASS)" | sudo tee -a $(FSTAB); \
	fi
	@$(MAKE) verify_fstab
	@echo "--------------------------------------------------------------"
	@echo "🔄 Reloading systemd daemon..."
	@sudo systemctl daemon-reexec
	@echo "--------------------------------------------------------------"
	@echo "📦 Mounting all entries..."
	@sudo mount -a || echo "❌ Mount failed. Please check /etc/fstab or device."
	@echo "📂 Verifying mount status..."
	@if mount | grep -q "$(MOUNT_DIR)"; then \
		echo "✅ Mounted successfully at $(MOUNT_DIR)"; \
	else \
		echo "❌ Mount failed. Check /etc/fstab and system logs."; \
		exit 1; \
	fi
	@echo "--------------------------------------------------------------"
	@echo "📂 Listing contents of $(MOUNT_DIR)..."
	@ls -la "$(MOUNT_DIR)"
	@echo "--------------------------------------------------------------"
	@echo "🔐 Setting ownership and permissions for $(MOUNT_DIR)..."
	@sudo chown -R $(USER):$(USER) "$(MOUNT_DIR)"
	@sudo chmod -R 700 "$(MOUNT_DIR)"

	@echo "✅ Done. $(DIR) is mounted with options: $(OPTIONS)."

# Manual defragmentation with compression
defrag:
	@echo "⚙️  Defragmenting and recompressing $(MOUNT_DIR) using zstd..."
	@sudo btrfs filesystem defragment -r -v -czstd "$(MOUNT_DIR)"
	@echo "✅ Defragmentation completed."

defrag_root:
	@echo "⚙️  Full system defragmentation and compression (root Btrfs volume)..."
	sudo btrfs filesystem defragment -r -v -czstd /
	@echo "✅ Defragmentation of root completed."

compress_root:
	@echo "🔍 Checking root UUID: $(ROOT_UUID)"
	@if [ -z "$(ROOT_UUID)" ]; then \
		echo "❌ Cannot find root UUID"; exit 1; \
	fi
	@echo "--------------------------------------------------------------"
	@echo "📋 Checking /etc/fstab entry for root (/)..."
	@if grep -q "UUID=$(ROOT_UUID).* / " $(FSTAB); then \
		echo "⚠️  Entry for root exists. Updating with new options..."; \
		sudo cp $(FSTAB) $(FSTAB).bak; \
		sudo sed -i "s|UUID=$(ROOT_UUID).* / .*|UUID=$(ROOT_UUID) / btrfs $(OPTIONS) 0 1|" $(FSTAB); \
	else \
		echo "📥 Adding root entry to $(FSTAB)..."; \
		echo "UUID=$(ROOT_UUID) / btrfs $(OPTIONS) 0 1" | sudo tee -a $(FSTAB); \
	fi
	@echo "--------------------------------------------------------------"
	@$(MAKE) verify_fstab
	@echo "🔄 Reloading systemd daemon..."
	sudo systemctl daemon-reexec
	@echo "--------------------------------------------------------------"
	@echo "🔁 Remounting root..."
	sudo mount -o remount /
	@echo "--------------------------------------------------------------"


	@echo "✅ Root is mounted with $(OPTIONS)"


verify_fstab:
	@echo "🔍 Verifying integrity of $(FSTAB)..."
	@sudo findmnt --verify || { \
		echo "❌ fstab verification failed! Restoring backup..."; \
		echo "⚠️  Problematic /etc/fstab:"; \
		sudo cat $(FSTAB); \
		echo "🔁 Restoring from backup..."; \
		sudo cp $(FSTAB).bak $(FSTAB); \
		exit 1; \
	}
	sudo cat $(FSTAB)
	@echo "--------------------------------------------------------------"
