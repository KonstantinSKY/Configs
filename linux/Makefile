.PHONY: all mount update_fstab defrag

LABEL = Work
DIR = Work
FS_TYPE = btrfs
OPTIONS = subvol=@work,compress=zstd,noatime
DUMP = 0
PASS = 2
FSTAB = /etc/fstab
UUID = $(shell sudo blkid -s UUID -o value $$(sudo findfs LABEL=$(LABEL)))
HOME_DIR = $(HOME)/$(DIR)

# Default target (optional)
all: mount

mount:
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
	sudo mount -a

	@echo "🔐 Setting ownership and permissions for $(HOME_DIR)..."
	sudo chown -R $(USER):$(USER) "$(HOME_DIR)"
	sudo chmod -R 700 "$(HOME_DIR)"

	@echo "✅ Done. $(DIR) is mounted with options: $(OPTIONS)."

# Separate target for manual defragmentation and recompression
defrag:
	@echo "⚙️  Defragmenting and recompressing $(HOME_DIR) using zstd..."
	sudo btrfs filesystem defragment -r -v -czstd "$(HOME_DIR)"
	@echo "✅ Defragmentation completed."
