.PHONY: all mount create_subvolume defrag

LABEL = Work
DIR = Work
FS_TYPE = btrfs
SUBVOL = @work
OPTIONS = subvol=$(SUBVOL),compress=zstd,noatime
DUMP = 0
PASS = 2
FSTAB = /etc/fstab
UUID = $(shell sudo blkid -s UUID -o value $$(sudo findfs LABEL=$(LABEL)))
HOME_DIR = $(HOME)/$(DIR)

all: mount

mount: create_subvolume
	@echo "🔍 Searching for device with label '$(LABEL)'..."
	@if [ -z "$(UUID)" ]; then echo "❌ Device with label '$(LABEL)' not found!"; exit 1; fi
	@echo "✅ UUID found: $(UUID)"

	@echo "📁 Creating directory $(HOME_DIR) if it doesn't exist..."
	mkdir -p "$(HOME_DIR)"

	@echo "📌 Checking if entry already exists in $(FSTAB)..."
	@if grep -q "$(UUID)" $(FSTAB); then \
		echo "⚠️  Entry already exists in $(FSTAB). Skipping..."; \
	else \
		echo "📦 Backing up $(FSTAB) -> $(FSTAB).bak"; \
		sudo cp $(FSTAB) $(FSTAB).bak; \
		echo "📥 Adding new entry to $(FSTAB)..."; \
		echo "UUID=$(UUID) $(HOME_DIR) $(FS_TYPE) $(OPTIONS) $(DUMP) $(PASS)" | sudo tee -a $(FSTAB); \
	fi

	@echo "🔄 Reloading systemd daemon..."
	sudo systemctl daemon-reexec

	@echo "📦 Mounting all entries..."
	sudo mount -a || echo "❌ Mount failed. Please check /etc/fstab or subvolume existence."


	@echo "📂 Verifying mount status..."
	@if mount | grep -q "$(HOME_DIR)"; then \
		echo "✅ Mounted successfully at $(HOME_DIR)"; \
	else \
		echo "❌ Mount failed. Check /etc/fstab and system logs."; \
		exit 1; \
		fi

	@echo "📂 Listing contents of $(HOME_DIR)..."
	@ls -la "$(HOME_DIR)"

	@echo "🔐 Setting ownership and permissions for $(HOME_DIR)..."
	sudo chown -R $(USER):$(USER) "$(HOME_DIR)"
	sudo chmod -R 700 "$(HOME_DIR)"

	@echo "✅ Done. $(DIR) is mounted with options: $(OPTIONS)."

# Automatically create subvolume if it doesn't exist
create_subvolume:
	@echo "🔎 Checking if subvolume $(SUBVOL) exists on $(LABEL)..."
	@mountpoint -q /mnt || sudo mount -o subvolid=5,ro LABEL=$(LABEL) /mnt
	@if ! sudo btrfs subvolume list /mnt | grep -q "$(SUBVOL)"; then \
		echo "➕ Creating subvolume $(SUBVOL)..."; \
		sudo mount -o subvolid=5 LABEL=$(LABEL) /mnt; \
		sudo btrfs subvolume create /mnt/$(SUBVOL); \
		sudo umount /mnt; \
	else \
		echo "✅ Subvolume $(SUBVOL) already exists."; \
		sudo umount /mnt || true; \
	fi

# Manual defragmentation with compression
defrag:
	@echo "⚙️  Defragmenting and recompressing $(HOME_DIR) using zstd..."
	sudo btrfs filesystem defragment -r -v -czstd "$(HOME_DIR)"
	@echo "✅ Defragmentation completed."
