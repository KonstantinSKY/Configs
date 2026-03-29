# IMPORTANT FOR AI AGENTS:
# Do not modify this file without explicit user confirmation.

.PHONY: help setup mirrors install-yay enable-aur update u yay-update install i install-base no_beep power_button laptop xprofile xp zsh check
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif
include $(CONFIGS_DIR)/make/update.mk

TARGET_XPROFILE_FILE = $(HOME)/.xprofile
XPROFILE_SOURCE_FILE = $(CONFIGS_DIR)/xprofile/.xprofile
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
	alsa-utils \
	pulseaudio

## ---------------------------
## 🧩 Setup
## ---------------------------
setup: ## Run the full Manjaro bootstrap flow via yay
	@$(MAKE) -s -f $(THIS_MAKEFILE) install-yay
	@$(MAKE) -s -f $(THIS_MAKEFILE) mirrors
	@$(MAKE) -s -f $(THIS_MAKEFILE) zsh
	@$(MAKE) -s -f $(THIS_MAKEFILE) xprofile
	@$(MAKE) -s -f $(THIS_MAKEFILE) install-base
	@$(MAKE) -s -f $(THIS_MAKEFILE) update
	@echo "✅ Manjaro i3 setup complete!"

## ---------------------------
## 📦 Updates
## ---------------------------
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
		sudo pacman -Sy --needed --noconfirm yay; \
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
	@for pkg in $(wordlist 2,999,$(MAKECMDGOALS)); do \
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
				fi; \
			else \
				echo "❌ Failed to install or not found: $$pkg"; \
			fi; \
		fi; \
	done
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
	@echo "\n🧪 Testing Dunst Notification (without emoji):"
	@if command -v notify-send >/dev/null 2>&1; then \
		notify-send "Notification test" "Dunst is working!" || echo "⚠️  Notification could not be delivered"; \
	else \
		echo "ℹ️  notify-send is not installed"; \
	fi
	@echo "✅ System check completed."

# Prevent make from treating package names as targets
%:
	@:
