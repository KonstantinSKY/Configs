# Self-documenting Makefile: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: all mount defrag_work verify_fstab defrag_root compress_root no_beep symlinks help

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

help: ## Shows this help message.
	@echo "Available commands:"
	@echo "  mount          - Mounts the work drive, creates mount point, and adds to fstab."
	@echo "  defrag_work    - Defragments and recompresses the work drive."
	@echo "  defrag_root    - Defragments and recompresses the root filesystem."
	@echo "  compress_root  - Adds compression options to the root filesystem in fstab."
	@echo "  verify_fstab   - Verifies the integrity of /etc/fstab."
	@echo "  no_beep        - Disables the PC speaker beep."
	@echo "  symlinks       - Creates symbolic links for configs and directories."


mount: ## Mounts the work drive, creates mount point, and adds to fstab.
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
defrag_work: ## Defragments and recompresses the work drive.
	@echo "⚙️  Defragmenting and recompressing $(MOUNT_DIR) using zstd..."
	@sudo btrfs filesystem defragment -r -v -czstd "$(MOUNT_DIR)"
	@echo "✅ Defragmentation completed."

defrag_root: ## Defragments and recompresses the root filesystem.
	@echo "⚙️  Full system defragmentation and compression (root Btrfs volume)..."
	sudo btrfs filesystem defragment -r -v -czstd /
	@echo "✅ Defragmentation of root completed."

compress_root: ## Adds compression options to the root filesystem in fstab.
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


verify_fstab: ## Verifies the integrity of /etc/fstab.
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

no_beep: ## Disables the PC speaker beep.
	@echo "🔇 Disabling PC speaker (pcspkr)..."
	@if [ ! -f /etc/modprobe.d/nobeep.conf ]; then \
		echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf >/dev/null; \
		echo "✅ Configuration file created: /etc/modprobe.d/nobeep.conf"; \
	else \
		echo "⚠️  Configuration already exists: /etc/modprobe.d/nobeep.conf"; \
	fi

	@if lsmod | grep -q pcspkr; then \
		echo "⚠️  pcspkr module is currently loaded. Attempting to unload..."; \
		sudo rmmod pcspkr && echo "✅ Module pcspkr successfully unloaded. No reboot required."; \
	else \
		echo "✅ pcspkr module is not loaded. Beep is already disabled."; \
	fi

symlinks: ## Creates symbolic links for configs and directories.
	@echo "🔗 Creating system symbolic links..."

	$(call create_symlink,Configs,/home/sky/Work/Configs)
	$(call create_symlink,Projects,/home/sky/Work/Projects)
	$(call create_symlink,Prompts,/home/sky/Work/Prompts)
	$(call create_symlink,Music,/home/sky/Work/Music)
	$(call create_symlink,Documents,/home/sky/Work/Documents)
	$(call create_symlink,Downloads,/home/sky/Work/Downloads)
	$(call create_symlink,.password-store,/home/sky/Work/.password-store)
	$(call create_symlink,Pictures,/home/sky/Work/Pictures)
	$(call create_symlink,.profile,/home/sky/Work/Configs/profile)
	$(call create_symlink,.Xresources,/home/sky/Work/Configs/Xresources)
	$(call create_symlink,Security,/home/sky/Work/Security)

define create_symlink
	@echo "➡️  $(1) -> $(2)"
	@dir=$$(dirname $(2)); \
	if [ ! -d "$$dir" ]; then \
		echo "📁 Creating parent directory: $$dir"; \
		mkdir -p "$$dir"; \
	fi; \
	if [ ! -e "$(2)" ]; then \
		echo "📄 Creating target file: $(2)"; \
		touch "$(2)"; \
	fi

	@if [ -L $$HOME/$(1) ]; then \
		if [ "$$(readlink -f $$HOME/$(1))" = "$(2)" ]; then \
			echo "✅ Link $$HOME/$(1) already correct."; \
		else \
			echo "♻️  Updating incorrect link: $$HOME/$(1)"; \
			ln -sf "$(2)" $$HOME/$(1); \
		fi \
	elif [ -e $$HOME/$(1) ]; then \
		echo "⚠️  File exists: $$HOME/$(1), not a symlink. Skipping."; \
	else \
		echo "➕ Creating symlink: $$HOME/$(1) -> $(2)"; \
		ln -s "$(2)" $$HOME/$(1); \
	fi
endef
