.PHONY: all mount defrag_work verify_fstab defrag_root compress_root no_beep symlinks help rc profile setup

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

RC_FILE = $(HOME)/Work/Configs/config/linux/rc
RC_LINE = [ -f "$(RC_FILE)" ] && source "$(RC_FILE)"
PROFILE_FILE = $(HOME)/Work/Configs/config/linux/profile
PROFILE_LINE = [ -f "$(PROFILE_FILE)" ] && source "$(PROFILE_FILE)"

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
	@echo "  rc             - Adds 'source' line to .bashrc and .zshrc for loading shared rc."
	@echo "  profile        - Adds 'source' line to .profile for loading shared profile."
	@echo "  setup          - Runs initial setup: symlinks, no_beep, rc, and profile."

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
	@echo "📋 Checking /etc/fstab entry for root (/)..."
	@if grep -q "UUID=$(ROOT_UUID).* / " $(FSTAB); then \
		sudo cp $(FSTAB) $(FSTAB).bak; \
		sudo sed -i "s|UUID=$(ROOT_UUID).* / .*|UUID=$(ROOT_UUID) / btrfs $(OPTIONS) 0 1|" $(FSTAB); \
	else \
		echo "UUID=$(ROOT_UUID) / btrfs $(OPTIONS) 0 1" | sudo tee -a $(FSTAB); \
	fi
	@$(MAKE) verify_fstab
	@echo "🔄 Reloading systemd daemon..."
	sudo systemctl daemon-reexec
	sudo mount -o remount /
	@echo "✅ Root is mounted with $(OPTIONS)"

verify_fstab: ## Verifies the integrity of /etc/fstab.
	@echo "🔍 Verifying integrity of $(FSTAB)..."
	@sudo findmnt --verify || { \
		echo "❌ fstab verification failed! Restoring backup..."; \
		sudo cp $(FSTAB).bak $(FSTAB); \
		exit 1; \
	}
	sudo cat $(FSTAB)

no_beep: ## Disables the PC speaker beep.
	@echo "🔇 Disabling PC speaker (pcspkr)..."
	@if [ ! -f /etc/modprobe.d/nobeep.conf ]; then \
		echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf >/dev/null; \
	else \
		echo "⚠️  Configuration already exists."; \
	fi
	@if lsmod | grep -q pcspkr; then \
		sudo rmmod pcspkr && echo "✅ pcspkr unloaded."; \
	else \
		echo "✅ pcspkr not loaded."; \
	fi

symlinks: ## Creates symbolic links for configs and directories.
	@echo "🔗 Creating system symbolic links..."
	$(call create_symlink,Configs,$(HOME)/Work/Configs)
	$(call create_symlink,Projects,$(HOME)/Work/Projects)
	$(call create_symlink,Prompts,$(HOME)/Work/Prompts)
	$(call create_symlink,Music,$(HOME)/Work/Music)
	$(call create_symlink,Documents,$(HOME)/Work/Documents)
	$(call create_symlink,Downloads,$(HOME)/Work/Downloads)
	$(call create_symlink,Pictures,$(HOME)/Work/Pictures)

rc: ## Adds source to custom rc in .bashrc and .zshrc if not present
	@for rcfile in $(HOME)/.bashrc $(HOME)/.zshrc; do \
		if [ ! -f "$$rcfile" ]; then \
			echo "📄 File $$rcfile not found. Creating..."; \
			touch "$$rcfile"; \
		fi; \
		if ! grep -Fxq '$(RC_LINE)' "$$rcfile"; then \
			echo '$(RC_LINE)' >> "$$rcfile" && echo "➕ Linked: $$rcfile"; \
		else \
			echo "✅ Already linked: $$rcfile"; \
		fi; \
	done

profile: ## Adds source to custom profile if not present
	@if grep -Fxq '$(PROFILE_LINE)' $(HOME)/.profile; then \
		echo "✅ Already linked: .profile"; \
	else \
		echo '$(PROFILE_LINE)' >> $(HOME)/.profile; \
		echo "➕ Linked: .profile"; \
	fi

setup: ## Runs initial setup: symlinks, no_beep, rc, and profile
	@$(MAKE) symlinks
	@$(MAKE) no_beep
	@$(MAKE) rc
	@$(MAKE) profile

# Macro for symbolic linking
# Params: 1 = link name in $HOME, 2 = target path

define create_symlink
	@echo "➡️  $(1) -> $(2)"
	@dir=$$(dirname $(2)); \
	if [ ! -d "$$dir" ]; then \
		echo "📁 Creating parent directory: $$dir"; \
		mkdir -p "$$dir"; \
	fi; \
	if [ -L $$HOME/$(1) ]; then \
		if [ "$$\(readlink -f $$HOME/$(1))" = "$(2)" ]; then \
			echo "✅ Link $$HOME/$(1) already correct."; \
		else \
			echo "♻️  Updating incorrect link: $$HOME/$(1)"; \
			ln -sf "$(2)" $$HOME/$(1); \
		fi; \
	elif [ -e $$HOME/$(1) ]; then \
		echo "⚠️  File exists: $$HOME/$(1), not a symlink. Skipping."; \
	else \
		echo "➕ Creating symlink: $$HOME/$(1) -> $(2)"; \
		ln -s "$(2)" $$HOME/$(1); \
	fi
endef
