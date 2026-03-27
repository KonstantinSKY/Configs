.PHONY: all mount defrag_work verify_fstab defrag_root compress_root no_beep power_button common_symlinks symlinks symlink rc xprofile xp setup bind_mounts zsh
.DEFAULT_GOAL :=
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
XPROFILE_PACKAGE = xprofile
TARGET_XPROFILE_FILE = $(HOME)/.xprofile
## ---------------------------
## 🧩 Work directory and symlinks
## ---------------------------
COMMON_SYMLINKS = \
	Configs:$(WORK_DIR)/Configs \
	Projects:$(WORK_DIR)/Projects \
	Deploys:$(WORK_DIR)/Deploys \
	Music:$(WORK_DIR)/Music \
	Documents:$(WORK_DIR)/Documents \
	Downloads:$(WORK_DIR)/Downloads \
	Pictures:$(WORK_DIR)/Pictures
# Default target
all:
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
power_button: ## Configures power button: ignore short press, shutdown on long press.
	@echo "🔌 Configuring power button..."
	@if command -v xfconf-query >/dev/null; then \
		xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/power-button-action -n -t int -s 0 && echo "✅ XFCE Power Manager configured."; \
	fi
	@sudo sed -i 's/^#\?HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
	@sudo sed -i 's/^#\?HandlePowerKeyLongPress=.*/HandlePowerKeyLongPress=poweroff/' /etc/systemd/logind.conf
	@sudo systemctl restart systemd-logind && echo "✅ systemd-logind configured and restarted."
symlinks: bind_mounts ## Configures common home paths via bind mounts in /etc/fstab.
common_symlinks: symlinks ## Backward-compatible alias; uses bind mounts.
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
xprofile xp: ## Link .xprofile from the stow package
	@echo "🔗 Linking .xprofile with stow..."
	@if ! command -v stow >/dev/null 2>&1; then \
		echo "📦 Installing stow..."; \
		sudo pacman -S --needed --noconfirm stow; \
	fi
	stow -d "$(CONFIGS_DIR)" -t "$(HOME)" $(XPROFILE_PACKAGE)
	@echo "✅ xprofile linked to $(TARGET_XPROFILE_FILE)"
setup: ## Runs initial setup: symlinks, no_beep, rc, and xprofile
	@$(MAKE) symlinks
	@$(MAKE) no_beep
	@$(MAKE) rc
	@$(MAKE) xprofile
zsh: ## Install zsh if needed and switch current user to it
	@echo "🔍 Checking zsh installation..."
	@if command -v zsh >/dev/null 2>&1; then \
		ZSH_PATH="$$(command -v zsh)"; \
		echo "✅ zsh is installed: $$ZSH_PATH"; \
	else \
		echo "📦 Installing zsh..."; \
		sudo pacman -S --needed --noconfirm zsh; \
		ZSH_PATH="$$(command -v zsh)"; \
	fi; \
	CURRENT_SHELL="$$(getent passwd "$$USER" | cut -d: -f7)"; \
	echo "👤 Current login shell: $$CURRENT_SHELL"; \
	if [ "$$CURRENT_SHELL" = "$$ZSH_PATH" ]; then \
		echo "✅ Login shell is already set to $$ZSH_PATH"; \
	else \
		echo "🔄 Switching login shell to $$ZSH_PATH"; \
		chsh -s "$$ZSH_PATH"; \
		echo "✅ Login shell updated. Open a new session to use zsh by default."; \
	fi
	@echo "🔗 Linking zsh config with stow..."
	@if ! command -v stow >/dev/null 2>&1; then \
		echo "📦 Installing stow..."; \
		sudo pacman -S --needed --noconfirm stow; \
	fi
	stow -d "$(CONFIGS_DIR)" -t "$(HOME)" zsh
	@echo "✅ zsh config linked to $(HOME)/.zshrc"
bind_mounts: ## Converts symlinks to bind mounts in fstab.
	@echo "🔗 Converting common symlinks to bind mounts..."
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
	echo "📁 Checking target path: $$TARGET"; \
	if [ -L "$$TARGET" ]; then \
		echo "🔁 Existing symlink found. Removing..."; \
		rm -f "$$TARGET"; \
	elif [ -d "$$TARGET" ]; then \
		if [ -z "$$(ls -A "$$TARGET")" ]; then \
			echo "🧹 Empty directory found. Removing..."; \
			rmdir "$$TARGET"; \
		else \
			echo "📦 Directory not empty. Creating backup: $$TARGET.back"; \
			mv "$$TARGET" "$$TARGET.back"; \
		fi; \
	elif [ -f "$$TARGET" ]; then \
		echo "📄 File found. Creating backup: $$TARGET.back"; \
		mv "$$TARGET" "$$TARGET.back"; \
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
