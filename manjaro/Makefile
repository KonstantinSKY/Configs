# IMPORTANT:
# Humans and AI agents must not modify this file without explicit user confirmation.

.PHONY: \
	help \
	setup \
	cleanup \
	audit \
	detach-i3-profile \
	refresh-keyrings \
	notifications \
	mirrors \
	install-yay \
	enable-aur \
	update u \
	yay-update \
	install i \
	install-base \
	no_beep \
	power_button \
	laptop \
	xprofile xp \
	mimeapps ma \
	zsh \
	check
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)
BROWSERS_MAKEFILE := $(CONFIGS_DIR)/browsers/Makefile
GTK_MAKEFILE := $(CONFIGS_DIR)/gtk/Makefile
QT_MAKEFILE := $(CONFIGS_DIR)/qt/Makefile

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif
include $(CONFIGS_DIR)/make/update.mk

TARGET_XPROFILE_FILE = $(HOME)/.xprofile
XPROFILE_SOURCE_FILE = $(CONFIGS_DIR)/xprofile/.xprofile
TARGET_MIMEAPPS_FILE = $(HOME)/.config/mimeapps.list
MIMEAPPS_SOURCE_FILE = $(THIS_DIR)/mimeapps.list
ZSH_TARGET_RC = $(HOME)/.zshrc
ZSH_CUSTOM_RC = $(CONFIGS_DIR)/zsh/rc
ZSH_INCLUDE_START = \# >>> custom shell config >>>
ZSH_INCLUDE_END = \# <<< custom shell config <<<
ZSH_INCLUDE_LINE = [ -r "$(ZSH_CUSTOM_RC)" ] && source "$(ZSH_CUSTOM_RC)"

BASE_PACKAGES = \
	base-devel \
	manjaro-settings-manager \
	fzf \
	git \
	github-cli \
	curl \
	wget \
	jq \
	rsync \
	zip \
	unzip \
	man-db \
	man-pages \
	file \
	which \
	lsof \
	nmap \
	ripgrep \
	bat \
	tmux \
	tree \
	matcha-gtk-theme \
	papirus-icon-theme \
	qt5ct \
	qt6ct \
	kvantum \
	kvantum-qt5 \
	alsa-utils \
	pulseaudio

KEYRING_PACKAGES = \
	archlinux-keyring \
	manjaro-keyring

CLEANUP_PACKAGES = \
	palemoon \
	palemoon-bin \
	vim \
	ex-vi-compat \
	b43-fwcutter \
	xorg-twm

I3_PROFILE_KEEP_PACKAGES = \
	i3-wm \
	i3status \
	i3lock \
	i3-scrot \
	i3-scripts \
	i3-help \
	nitrogen \
	picom \
	qt5ct \
	qt6ct \
	dmenu-manjaro \
	conky-i3 \
	i3-default-artwork \
	adapta-maia-theme \
	papirus-maia-icon-theme \
	breeze-cursors5 \
	rxvt-unicode \
	urxvt-perls \
	xorg-fonts-misc \
	xorg-mkfontscale \
	manjaro-base-skel

## ---------------------------
## 🧩 Setup
## ---------------------------
setup: ## Run the full Manjaro bootstrap flow via yay
	@$(MAKE) -s -f $(THIS_MAKEFILE) cleanup
	@$(MAKE) -s -f $(THIS_MAKEFILE) refresh-keyrings
	@echo "⬆️  Updating all system packages via pacman before yay bootstrap..."
	@sudo pacman -Syu --noconfirm
	@$(MAKE) -s -f $(THIS_MAKEFILE) install-yay
	@$(MAKE) -s -f $(THIS_MAKEFILE) mirrors
	@$(MAKE) -s -f $(THIS_MAKEFILE) zsh
	@$(MAKE) -s -f $(THIS_MAKEFILE) xprofile
	@$(MAKE) -s -f $(THIS_MAKEFILE) mimeapps
	@$(MAKE) -s -f $(THIS_MAKEFILE) install-base
	@$(MAKE) -s -f $(THIS_MAKEFILE) notifications
	@$(MAKE) -s -f $(THIS_MAKEFILE) update
	@$(MAKE) -s -f $(GTK_MAKEFILE) link
	@$(MAKE) -s -f $(GTK_MAKEFILE) verify
	@$(MAKE) -s -f $(QT_MAKEFILE) link
	@$(MAKE) -s -f $(QT_MAKEFILE) verify
	@echo "✅ Manjaro i3 setup complete!"

cleanup: ## Remove legacy preinstalled packages and prune orphaned dependencies
	@echo "🧹 Removing legacy preinstalled packages..."
	@for pkg in $(CLEANUP_PACKAGES); do \
		if pacman -Q "$$pkg" >/dev/null 2>&1; then \
			echo "🗑️  Removing $$pkg..."; \
			sudo pacman -Rns --noconfirm "$$pkg"; \
		else \
			echo "ℹ️  $$pkg is not installed"; \
		fi; \
	done
	@echo "🧹 Removing orphaned dependencies..."
	@ORPHANS="$$(pacman -Qqdt 2>/dev/null || true)"; \
	if [ -n "$$ORPHANS" ]; then \
		sudo pacman -Rns --noconfirm $$ORPHANS; \
	else \
		echo "✅ No orphaned dependencies found"; \
	fi
	@echo "-------------------------------------------------------------------------------"

detach-i3-profile: ## Keep the current i3 stack, then remove manjaro-i3-settings and dunst
	@echo "🧩 Detaching from manjaro-i3-settings while preserving the current i3 stack..."
	@echo "📌 Marking retained i3 packages as explicitly installed..."
	@sudo pacman -D --asexplicit $(I3_PROFILE_KEEP_PACKAGES)
	@if pacman -Q manjaro-i3-settings >/dev/null 2>&1; then \
		echo "🗑️  Removing manjaro-i3-settings..."; \
		sudo pacman -R --noconfirm manjaro-i3-settings; \
	else \
		echo "ℹ️  manjaro-i3-settings is not installed"; \
	fi
	@if pacman -Q dunst >/dev/null 2>&1; then \
		echo "🗑️  Removing dunst..."; \
		sudo pacman -R --noconfirm dunst; \
	else \
		echo "ℹ️  dunst is not installed"; \
	fi
	@echo "✅ manjaro-i3-settings and dunst have been detached from this system."
	@echo "-------------------------------------------------------------------------------"

audit: ## Print a package audit focused on duplicate tools, Manjaro presets, and cleanup candidates
	@echo "🧾 Package Audit"
	@echo "-------------------------------------------------------------------------------"
	@printf "Installed packages: "; pacman -Qq | wc -l
	@printf "Explicit packages : "; pacman -Qqe | wc -l
	@printf "Dependency pkgs   : "; pacman -Qqd | wc -l
	@echo ""
	@echo "🖥️  Terminals:"
	@TERMINALS="$$(pacman -Qq | rg '^(alacritty|rxvt-unicode|xterm|kitty|wezterm|gnome-terminal|konsole|tilix|xfce4-terminal|foot|terminator)$$' || true)"; \
	if [ -n "$$TERMINALS" ]; then \
		printf '%s\n' "$$TERMINALS"; \
	else \
		echo "ℹ️  No known terminal packages matched"; \
	fi
	@echo ""
	@echo "📝 Editors:"
	@EDITORS="$$(pacman -Qq | rg '^(neovim|vim|nano|micro|zed|code)$$' || true)"; \
	if [ -n "$$EDITORS" ]; then \
		printf '%s\n' "$$EDITORS"; \
	else \
		echo "ℹ️  No known editor packages matched"; \
	fi
	@echo ""
	@echo "🎨 Themes and Appearance:"
	@THEMES="$$(pacman -Qq | rg '^(matcha-gtk-theme|materia-gtk-theme|adapta-maia-theme|papirus-icon-theme|papirus-maia-icon-theme|breeze-cursors5|kvantum-manjaro|qt5ct|qt6ct|nitrogen|picom|conky|conky-i3)$$' || true)"; \
	if [ -n "$$THEMES" ]; then \
		printf '%s\n' "$$THEMES"; \
	else \
		echo "ℹ️  No known theme/appearance packages matched"; \
	fi
	@echo ""
	@echo "📦 Manjaro Presets and Meta Packages:"
	@MANJARO_PKGS="$$(pacman -Qq | rg '^(manjaro-.*|dmenu-manjaro|i3-default-artwork|i3-help|i3-scripts|i3-scrot|dunst)$$' || true)"; \
	if [ -n "$$MANJARO_PKGS" ]; then \
		printf '%s\n' "$$MANJARO_PKGS"; \
	else \
		echo "ℹ️  No matching Manjaro preset packages found"; \
	fi
	@echo ""
	@echo "🌐 Network and Remote Access Extras:"
	@NET_PKGS="$$(pacman -Qq | rg '^(networkmanager-openconnect|networkmanager-openvpn|networkmanager-vpnc|modemmanager|nfs-utils|avahi|nss-mdns|blueman|bluez|bluez-utils|network-manager-applet|wpa_supplicant|netctl)$$' || true)"; \
	if [ -n "$$NET_PKGS" ]; then \
		printf '%s\n' "$$NET_PKGS"; \
	else \
		echo "ℹ️  No matching network extras found"; \
	fi
	@echo ""
	@echo "🧰 Developer Tooling:"
	@DEV_PKGS="$$(pacman -Qq | rg '^(autoconf|automake|bison|flex|fakeroot|pkgconf|make|patch|patchutils|cmake|rustup|zig|tree-sitter-cli|github-cli|claude-code|gemini-cli|openai-codex-bin)$$' || true)"; \
	if [ -n "$$DEV_PKGS" ]; then \
		printf '%s\n' "$$DEV_PKGS"; \
	else \
		echo "ℹ️  No matching development tools found"; \
	fi
	@echo ""
	@echo "🖼️  Desktop Utilities:"
	@UTIL_PKGS="$$(pacman -Qq | rg '^(clipit|font-manager|galculator|gcolor3|mousepad|viewnior|pavucontrol|pcmanfm|lxappearance|lxinput|screenfetch|btop|htop|powertop|dfc|duf|eza|ncdu|telegram-desktop|zoom|megacmd|mupdf|pass|sbxkb)$$' || true)"; \
	if [ -n "$$UTIL_PKGS" ]; then \
		printf '%s\n' "$$UTIL_PKGS"; \
	else \
		echo "ℹ️  No matching desktop utilities found"; \
	fi
	@echo ""
	@echo "🧪 Virtualization Stack:"
	@VIRT_PKGS="$$(pacman -Qq | rg '^(libvirt|virt-manager|qemu-full|edk2-ovmf|swtpm|dnsmasq)$$' || true)"; \
	if [ -n "$$VIRT_PKGS" ]; then \
		printf '%s\n' "$$VIRT_PKGS"; \
	else \
		echo "ℹ️  No matching virtualization packages found"; \
	fi
	@echo ""
	@echo "🗑️  Cleanup Target Package Set:"
	@printf '%s\n' $(CLEANUP_PACKAGES)
	@echo ""
	@echo "🧹 Orphaned Dependencies:"
	@ORPHANS="$$(pacman -Qqdt 2>/dev/null || true)"; \
	if [ -n "$$ORPHANS" ]; then \
		printf '%s\n' "$$ORPHANS"; \
	else \
		echo "✅ No orphaned dependencies found"; \
	fi
	@echo "-------------------------------------------------------------------------------"

## ---------------------------
## 📦 Updates
## ---------------------------
refresh-keyrings: ## Refresh Arch and Manjaro keyrings before system upgrades
	@echo "🔑 Refreshing pacman keyrings..."
	@sudo pacman -Sy --needed --noconfirm $(KEYRING_PACKAGES)
	@echo "-------------------------------------------------------------------------------"

notifications: ## Ensure xfce4-notifyd is the active desktop notification daemon
	@echo "🔔 Configuring notification stack for i3..."
	@sudo pacman -S --needed --noconfirm xfce4-notifyd
	@if pacman -Q dunst >/dev/null 2>&1; then \
		echo "🧹 Removing dunst to avoid D-Bus notification provider conflicts..."; \
		sudo pacman -Rns --noconfirm dunst; \
	else \
		echo "✅ dunst is not installed"; \
	fi
	@rm -f "$(HOME)/.config/autostart/xfce4-notifyd.desktop"
	@systemctl --user stop dunst.service >/dev/null 2>&1 || true
	@pkill -x dunst >/dev/null 2>&1 || true
	@systemctl --user reset-failed xfce4-notifyd.service >/dev/null 2>&1 || true
	@systemctl --user start xfce4-notifyd.service >/dev/null 2>&1 || true
	@echo "✅ xfce4-notifyd is now the only managed notification daemon for this user."
	@echo "-------------------------------------------------------------------------------"

mirrors: ## Refresh Manjaro mirrors and package databases
	@echo "🔄 Updating mirrors..."
	@sudo pacman-mirrors --fasttrack
	@if command -v yay >/dev/null 2>&1; then \
		yay -Syy --noconfirm; \
	else \
		echo "ℹ️  yay is not installed yet; package database refresh will happen after bootstrap."; \
	fi
	@echo "-------------------------------------------------------------------------------"

install-yay: ## Install yay if needed, using pacman only for bootstrap
	@if command -v yay >/dev/null 2>&1; then \
		echo "✅ yay is already installed."; \
	else \
		echo "📦 Installing yay from official repository..."; \
		sudo pacman -Sy --needed --noconfirm $(KEYRING_PACKAGES); \
		sudo pacman -S --needed --noconfirm yay; \
	fi
	@echo "-------------------------------------------------------------------------------"

yay-update: ## Update official and AUR packages via yay
	@if ! command -v yay >/dev/null 2>&1; then \
		echo "❌ yay is not installed. Run 'make -f $(THIS_MAKEFILE) setup' first."; \
		exit 1; \
	fi
	@echo "⬆️  Updating AUR and system packages with yay..."
	@yay -Syu --noconfirm --answerclean None --answerdiff None
	@echo "-------------------------------------------------------------------------------"

enable-aur: ## Enable AUR support in pamac when pamac is available
	@echo "⚙️  Enabling AUR support in pamac (if applicable)..."
	@if command -v pamac >/dev/null 2>&1; then \
		pamac config --enable-aur; \
	else \
		echo "ℹ️  pamac not found, skipping AUR GUI enabling..."; \
	fi
	@echo "-------------------------------------------------------------------------------"

update u: ## Run full maintenance: yay update, orphan cleanup, cache cleanup, flatpak update
	@if ! command -v yay >/dev/null 2>&1; then \
		echo "❌ yay is not installed. Update expects an already bootstrapped system."; \
		echo "   Run 'make -f $(THIS_MAKEFILE) setup' first."; \
		exit 1; \
	fi
	@$(MAKE) -s -f $(THIS_MAKEFILE) yay-update
	@echo "-------------------------------------------------------------------------------"
	@echo "🧹 Removing unused dependencies..."
	@ORPHANS="$$(yay -Qtdq 2>/dev/null || true)"; \
	if [ -n "$$ORPHANS" ]; then \
		yay -Rns --noconfirm $$ORPHANS; \
	else \
		echo "✅ No unused dependencies found"; \
	fi
	@echo "-------------------------------------------------------------------------------"
	@echo "🧼 Cleaning cache..."
	@yay -Sc --noconfirm
	@echo "-------------------------------------------------------------------------------"
	@echo "⬆️  Updating flatpak apps/runtimes..."
	@flatpak update -y || { rc=$$?; [ $$rc -eq 127 ] && echo "⚠️ flatpak not installed — skipping" || exit $$rc; }
	@echo "🧹 Cleaning flat unused flatpak runtimes..."
	@flatpak uninstall -y --unused || { rc=$$?; [ $$rc -eq 127 ] && echo "⚠️ runtime not installed — skipping cleanup" || exit $$rc; }
	@echo "-------------------------------------------------------------------------------"
	@echo "✅ Update completed successfully!"
	@echo "-------------------------------------------------------------------------------"

## ---------------------------
## 📦 Installation
## ---------------------------
install i: ## Install one or more packages via yay after updating the system
	@if [ "$(wordlist 2,999,$(MAKECMDGOALS))" = "" ]; then \
		echo "❌ No packages specified. Usage: make install [list of packages]"; \
		exit 1; \
	fi
	@$(call ensure_system_updated)
	@echo "📦 Installing packages:"
	@echo "-------------------------------------------------------------------------------"
	@status=0; \
	for pkg in $(wordlist 2,999,$(MAKECMDGOALS)); do \
		echo "📦 Processing: $$pkg"; \
		if yay -Qi "$$pkg" >/dev/null 2>&1; then \
			current_ver=$$(yay -Qi "$$pkg" | awk -F': ' '/^Version/ {print $$2}'); \
			echo "🔁 Already installed: $$pkg @ $$current_ver — skipping"; \
		else \
			echo "⬇️  Installing: $$pkg"; \
			if yay -S --noconfirm --needed "$$pkg"; then \
				if yay -Qi "$$pkg" >/dev/null 2>&1; then \
					new_ver=$$(yay -Qi "$$pkg" | awk -F': ' '/^Version/ {print $$2}'); \
					echo "✅ Installed: $$pkg @ $$new_ver"; \
				else \
					echo "❌ Failed to install or not found: $$pkg"; \
					status=1; \
				fi; \
			else \
				echo "❌ Failed to install or not found: $$pkg"; \
				status=1; \
			fi; \
		fi; \
	done; \
	exit $$status
	@echo "-------------------------------------------------------------------------------"
	@echo "✅ Installation process complete."

install-base: ## Install the default base package set via yay
	@if ! command -v yay >/dev/null 2>&1; then \
		echo "❌ yay is not installed. Run 'make -f $(THIS_MAKEFILE) setup' first."; \
		exit 1; \
	fi
	@echo "📦 Installing essential packages via yay..."
	yay -S --needed --noconfirm $(BASE_PACKAGES)
	@echo "✅ Base packages installed via yay."
	@echo "-------------------------------------------------------------------------------"

## ---------------------------
## 💻 Laptop
## ---------------------------
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

laptop: ## Applies laptop-specific Manjaro settings.
	@$(MAKE) -s -f $(THIS_MAKEFILE) no_beep
	@$(MAKE) -s -f $(THIS_MAKEFILE) power_button

## ---------------------------
## 👤 User Session
## ---------------------------
xprofile xp: ## Link .xprofile via a direct symlink
	@$(call require_exists,$(XPROFILE_SOURCE_FILE),Source xprofile not found)
	@echo "📦 Preparing existing $(TARGET_XPROFILE_FILE)..."
	@if [ -L "$(TARGET_XPROFILE_FILE)" ]; then \
		CURRENT_LINK="$$(readlink -f "$(TARGET_XPROFILE_FILE)" 2>/dev/null || true)"; \
		DESIRED_LINK="$$(readlink -f "$(XPROFILE_SOURCE_FILE)" 2>/dev/null || true)"; \
		if [ "$$CURRENT_LINK" != "$$DESIRED_LINK" ]; then \
			BACKUP_PATH="$(TARGET_XPROFILE_FILE).bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up existing .xprofile symlink to $$BACKUP_PATH"; \
			mv "$(TARGET_XPROFILE_FILE)" "$$BACKUP_PATH"; \
		fi; \
	fi
	@$(call backup_if_needed,$(TARGET_XPROFILE_FILE))
	@echo "🔗 Linking $(TARGET_XPROFILE_FILE) → $(XPROFILE_SOURCE_FILE)..."
	@ln -sfn "$(XPROFILE_SOURCE_FILE)" "$(TARGET_XPROFILE_FILE)"
	@echo "✅ xprofile linked to $(TARGET_XPROFILE_FILE)"

mimeapps ma: ## Link managed XDG default applications file
	@$(call require_exists,$(MIMEAPPS_SOURCE_FILE),Source mimeapps file not found)
	@mkdir -p "$(dir $(TARGET_MIMEAPPS_FILE))"
	@echo "📦 Preparing existing $(TARGET_MIMEAPPS_FILE)..."
	@if [ -L "$(TARGET_MIMEAPPS_FILE)" ]; then \
		CURRENT_LINK="$$(readlink -f "$(TARGET_MIMEAPPS_FILE)" 2>/dev/null || true)"; \
		DESIRED_LINK="$$(readlink -f "$(MIMEAPPS_SOURCE_FILE)" 2>/dev/null || true)"; \
		if [ "$$CURRENT_LINK" != "$$DESIRED_LINK" ]; then \
			BACKUP_PATH="$(TARGET_MIMEAPPS_FILE).bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up existing mimeapps symlink to $$BACKUP_PATH"; \
			mv "$(TARGET_MIMEAPPS_FILE)" "$$BACKUP_PATH"; \
		fi; \
	fi
	@$(call backup_if_needed,$(TARGET_MIMEAPPS_FILE))
	@echo "🔗 Linking $(TARGET_MIMEAPPS_FILE) → $(MIMEAPPS_SOURCE_FILE)..."
	@ln -sfn "$(MIMEAPPS_SOURCE_FILE)" "$(TARGET_MIMEAPPS_FILE)"
	@echo "✅ mimeapps linked to $(TARGET_MIMEAPPS_FILE)"

zsh: ## Install zsh if needed and switch current user to it
	@if ! command -v yay >/dev/null 2>&1; then \
		echo "❌ yay is not installed. Run 'make -f $(THIS_MAKEFILE) setup' first."; \
		exit 1; \
	fi
	@echo "🔍 Checking zsh installation..."
	@if command -v zsh >/dev/null 2>&1; then \
		ZSH_PATH="$$(command -v zsh)"; \
		echo "✅ zsh is installed: $$ZSH_PATH"; \
	else \
		echo "📦 Installing zsh..."; \
		yay -S --needed --noconfirm zsh; \
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
	@$(call require_exists,$(ZSH_CUSTOM_RC),Custom zsh rc not found)
	@echo "🧩 Ensuring $(ZSH_TARGET_RC) loads $(ZSH_CUSTOM_RC)..."
	@if [ ! -e "$(ZSH_TARGET_RC)" ]; then \
		echo "📄 Creating new $(ZSH_TARGET_RC)"; \
		{ \
			printf '%s\n' '$(ZSH_INCLUDE_START)'; \
			printf '%s\n' '$(ZSH_INCLUDE_LINE)'; \
			printf '%s\n' '$(ZSH_INCLUDE_END)'; \
		} > "$(ZSH_TARGET_RC)"; \
	elif grep -Fqx '$(ZSH_INCLUDE_LINE)' "$(ZSH_TARGET_RC)"; then \
		echo "✅ Custom zsh include already present in $(ZSH_TARGET_RC)"; \
	else \
		printf '\n%s\n%s\n%s\n' '$(ZSH_INCLUDE_START)' '$(ZSH_INCLUDE_LINE)' '$(ZSH_INCLUDE_END)' >> "$(ZSH_TARGET_RC)"; \
		echo "✅ Added custom zsh include to $(ZSH_TARGET_RC)"; \
	fi

## ---------------------------
## 🔎 Diagnostics
## ---------------------------
check: ## Run a full local system diagnostic report
	@echo "🔍 Starting full system diagnostic..."
	@echo ""
	@echo "👤 User and Host Info:"
	@echo "User: $$(whoami)"
	@echo "Host: $$(hostname)"
	@echo "Home Dir: $$HOME"
	@echo ""
	@echo "🕒 Uptime and Load:"
	@uptime
	@echo ""
	@echo "🧠 Memory and Swap Usage:"
	@free -h
	@echo ""
	@echo "💾 Disk Usage for / and /var:"
	@df -hT -x squashfs -x tmpfs -x devtmpfs
	@echo ""
	@echo "🔌 Network Interfaces:"
	@ip -brief address
	@echo ""
	@echo "🌐 Open Network Ports:"
	@ss -tuln
	@echo ""
	@echo "📊 Top Processes Snapshot:"
	@top -bn1 | head -15
	@echo ""
	@echo "⚙️  Systemd Services with Errors:"
	@systemctl --failed --no-pager
	@echo ""
	@echo "👻 Zombie or Suspicious Processes:"
	@ps -eo pid,ppid,stat,cmd | awk '$$3 ~ /^Z/ { found=1; print } END { exit(found ? 0 : 1) }' || echo "✔️  No zombie processes found"
	@echo ""
	@echo "🔐 Running Processes as root:"
	@ps -U root -u root u
	@echo ""
	@echo "📄 Recent System Errors (priority 3, current boot):"
	@journalctl -p 3 -xb -n 20 || echo "✔️  No recent critical errors"
	@echo ""
	@echo "🚨 Kernel Critical Logs (OOM, segfaults, panics):"
	@journalctl -k -p 0..3 | grep -Ei 'Out of memory|Kernel panic|segfault' || echo "✔️  No kernel-level issues detected"
	@echo ""
	@echo "⏱️  Active Timers (Cron/Systemd):"
	@systemctl list-timers --all --no-pager | head -15
	@echo ""
	@echo "🔑 Wheel (Admin) Group Members:"
	@grep '^wheel:' /etc/group || echo "ℹ️  No 'wheel' group found"
	@echo ""
	@echo "🔥 Temperature Sensors (if available):"
	@command -v sensors >/dev/null && sensors || echo "ℹ️  'sensors' command not available"
	@echo ""
	@echo "🔔 Notification Providers:"
	@INSTALLED=""; \
	for pkg in xfce4-notifyd dunst; do \
		if pacman -Q "$$pkg" >/dev/null 2>&1; then \
			echo "✔️  $$pkg installed"; \
			INSTALLED="$$INSTALLED $$pkg"; \
		else \
			echo "ℹ️  $$pkg not installed"; \
		fi; \
	done; \
	set -- $$INSTALLED; \
	if pacman -Q xfce4-notifyd >/dev/null 2>&1 && ! pacman -Q dunst >/dev/null 2>&1; then \
		echo "✅ Notification provider selection is clean"; \
	elif [ "$$#" -gt 1 ]; then \
		echo "❌ Multiple notification providers installed:$$INSTALLED"; \
	else \
		echo "⚠️  Expected xfce4-notifyd only, found:$$INSTALLED"; \
	fi
	@OVERRIDE="$(HOME)/.config/autostart/xfce4-notifyd.desktop"; \
	if [ -f "$$OVERRIDE" ]; then \
		echo "⚠️  xfce4-notifyd autostart override is still present"; \
	else \
		echo "✅ xfce4-notifyd autostart override is not blocking startup"; \
	fi
	@echo ""
	@echo "🐳 Docker Status:"
	@if command -v docker >/dev/null; then \
		echo "Docker is installed."; \
		docker info --format='Version: {{.ServerVersion}}, OS: {{.OperatingSystem}}'; \
		systemctl is-active docker && echo "✔️  Docker is running" || echo "❌ Docker is not running"; \
		echo "Running containers:"; \
		docker ps --format='  - {{.Names}} ({{.Image}})' || echo "❌ Failed to list containers"; \
	else \
		echo "ℹ️  Docker is not installed."; \
	fi
	@echo ""
	@echo "\n🧪 Testing Desktop Notification:"
	@if command -v notify-send >/dev/null 2>&1; then \
		notify-send "Notification test" "Desktop notifications are working!" || echo "⚠️  Notification could not be delivered"; \
	else \
		echo "ℹ️  notify-send is not installed"; \
	fi
	@echo "✅ System check completed."

# Prevent make from treating package names as targets
%:
	@:
