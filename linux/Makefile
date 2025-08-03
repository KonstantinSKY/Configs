.PHONY: all mount defrag_work verify_fstab defrag_root compress_root no_beep common_symlinks symlink help rc profile setup

## ---------------------------
## 🧩 Directory configuration
## ---------------------------
MAKEFLAGS += --no-print-directory
WORK_DIR = $(HOME)/$(DIR)
CONFIGS_DIR = $(WORK_DIR)/Configs
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
ROOT_UUID = $(shell findmnt -no UUID /)
MOUNT_DIR = $(WORK_DIR)
## ---------------------------
## 🧩 RC / Profile configuration
## ---------------------------
RC_FILE = $(CONFIGS_DIR)/linux/rc
RC_LINE = [ -f "$(RC_FILE)" ] && source "$(RC_FILE)"
PROFILE_FILE = $(CONFIGS_DIR)/linux/profile
PROFILE_LINE = [ -f "$(PROFILE_FILE)" ] && source "$(PROFILE_FILE)"
## ---------------------------
## 🧩 Work directory and symlinks
## ---------------------------
COMMON_SYMLINKS = \
	Configs:$(WORK_DIR)/Configs \
	Projects:$(WORK_DIR)/Projects \
	Prompts:$(WORK_DIR)/Prompts \
	Music:$(WORK_DIR)/Music \
	Documents:$(WORK_DIR)/Documents \
	Downloads:$(WORK_DIR)/Downloads \
	Pictures:$(WORK_DIR)/Pictures

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
	@echo "  common_symlinks - Creates common symbolic links from Work directory to home."
	@echo "  rc             - Adds 'source' line to .bashrc and .zshrc for loading shared rc."
	@echo "  profile        - Adds 'source' line to .profile for loading shared profile."
	@echo "  setup          - Runs initial setup: symlinks, no_beep, rc, and profile."
	@echo "  symlink        - Creates a symbolic link: make symlink <target> <source>."

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

common_symlinks: ## Creates common symbolic links from $(WORK_DIR) to $(HOME)
	@echo "🔗 Creating common symbolic links..."
	@for pair in $(COMMON_SYMLINKS); do \
		SOURCE=$${pair#*:}; \
		TARGET="$(HOME)/$${pair%%:*}"; \
		echo "🔄 Linking $$TARGET → $$SOURCE"; \
		$(MAKE) symlink "$$TARGET" "$$SOURCE"; \
	done

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
	@$(MAKE) common_symlinks
	@$(MAKE) no_beep
	@$(MAKE) rc
	@$(MAKE) profile

symlink:  ## Create a symbolic link: make symlink <target> <source>
	@TARGET=$(word 2, $(MAKECMDGOALS)); \
	SOURCE=$(word 3, $(MAKECMDGOALS)); \
	if [ -z "$$TARGET" ] || [ -z "$$SOURCE" ]; then \
		echo "❌ Usage: make symlink <target> <source>"; \
		exit 1; \
	fi; \
	echo "------------------------------------------------------------"; \
	echo "🔍 Checking if source exists: $$SOURCE"; \
	if [ ! -e "$$SOURCE" ]; then \
		echo "🚫 Source does not exist → $$SOURCE"; \
		exit 1; \
	fi; \
	echo "------------------------------------------------------------"; \
	echo "🔗 Creating symlink: $$TARGET → $$SOURCE"; \
	ln -sv "$$SOURCE" "$$TARGET"; \
	echo "------------------------------------------------------------"; \
	echo "🔍 Verifying symlink..."; \
	if [ ! -L "$$TARGET" ]; then \
		echo "❌ Error: $$TARGET is not a symbolic link"; \
		exit 1; \
	fi; \
	LINK_TEXT="$$(readlink "$$TARGET")"; \
	if [ "$$LINK_TEXT" = "$$SOURCE" ]; then \
		echo "✅ Symlink text points to correct target: $$TARGET → $$LINK_TEXT"; \
	else \
		echo "⚠️  Symlink text differs: $$TARGET → $$LINK_TEXT (expected: $$SOURCE)"; \
	fi

%:
	@:
