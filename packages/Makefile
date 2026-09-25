SHELL := /bin/bash

.PHONY: help status detect \
	install-base install-base-arch install-base-debian \
	install-tailscale install-tailscale-arch install-tailscale-debian \
	install-workstation-core install-desktop install-fonts \
	install-profile \
	install-workstation-core-arch install-workstation-core-debian \
	install-desktop-arch install-fonts-arch \
	unsupported-workstation-family unsupported-desktop-family unsupported-font-family \
	verify-base verify-tailscale verify-workstation-core verify-desktop verify-fonts \
	verify-profile
.DEFAULT_GOAL := help

SUDO := $(shell if [ "$$(id -u)" -eq 0 ]; then echo ""; else echo "sudo"; fi)

BASE_PACKAGES_ARCH := \
	ca-certificates \
	curl \
	git \
	make \
	openssh

BASE_PACKAGES_DEBIAN := \
	ca-certificates \
	curl \
	git \
	make \
	openssh-client \
	openssh-server

WORKSTATION_CORE_PACKAGES_ARCH := \
	zsh \
	zsh-theme-powerlevel10k \
	tmux \
	alacritty \
	neovim \
	tree-sitter-cli \
	zed \
	gnome-keyring \
	libsecret \
	hunspell \
	hunspell-en_us \
	hunspell-ru

WORKSTATION_CORE_PACKAGES_DEBIAN := \
	zsh \
	tmux \
	neovim

DESKTOP_PACKAGES_ARCH := \
	i3-wm \
	i3blocks \
	dunst \
	libnotify \
	rofi \
	picom \
	xss-lock \
	xsettingsd \
	qt5ct \
	qt6ct \
	kvantum \
	kvantum-qt5 \
	kvantum-theme-arc \
	capitaine-cursors \
	qogir-icon-theme

FONT_PACKAGES_ARCH := \
	noto-fonts \
	noto-fonts-emoji \
	ttf-jetbrains-mono \
	ttf-jetbrains-mono-nerd \
	ttf-hack \
	ttf-hack-nerd \
	ttf-ubuntu-font-family \
	ttf-ubuntu-mono-nerd \
	ttf-ubuntu-nerd \
	ttf-fira-code \
	ttf-firacode-nerd \
	ttf-sourcecodepro-nerd \
	ttf-nerd-fonts-symbols-mono

help: ## Show package bootstrap commands
	@echo "Public package bootstrap"
	@echo
	@echo "  make status    detect supported package family"
	@echo "  make detect    print OS and package family"
	@echo "  make install-base"
	@echo "  make install-tailscale"
	@echo "  make install-workstation-core"
	@echo "  make install-desktop"
	@echo "  make install-fonts"
	@echo "  make install-profile"
	@echo "  make verify-base"
	@echo "  make verify-tailscale"
	@echo "  make verify-workstation-core"
	@echo "  make verify-desktop"
	@echo "  make verify-fonts"
	@echo "  make verify-profile"

status: detect ## Detect supported package family

detect: ## Print OS and package family without changes
	@set -euo pipefail; \
	if [[ "$$(uname -s)" != Linux ]]; then \
		echo "OS: $$(uname -s)"; \
		echo "PACKAGE_FAMILY: unsupported"; \
		exit 0; \
	fi; \
	. /etc/os-release; \
	family=unsupported; profile=unsupported; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) family=arch; profile=arch-desktop ;; \
		*' debian '*|*' ubuntu '*) family=debian; profile=debian-server ;; \
	esac; \
	echo "OS: Linux"; \
	echo "DISTRO: $${ID:-unknown}"; \
	echo "DISTRO_LIKE: $${ID_LIKE:-none}"; \
	echo "PACKAGE_FAMILY: $$family"; \
	echo "PACKAGE_PROFILE: $$profile"

install-base: ## Install public base packages for the detected package family
	@set -euo pipefail; \
	. /etc/os-release; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-base-arch ;; \
		*' debian '*|*' ubuntu '*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-base-debian ;; \
		*) echo "ERROR: unsupported package family: ID=$${ID:-unknown} ID_LIKE=$${ID_LIKE:-none}"; exit 1 ;; \
	esac

install-base-arch: ## Install public base packages on Arch-like systems
	@set -euo pipefail; \
	command -v pacman >/dev/null 2>&1 || { echo "ERROR: pacman is required"; exit 1; }; \
	$(SUDO) pacman -S --needed --noconfirm $(BASE_PACKAGES_ARCH); \
	$(SUDO) systemctl enable --now sshd.service

install-base-debian: ## Install public base packages on Debian/Ubuntu systems
	@set -euo pipefail; \
	command -v apt-get >/dev/null 2>&1 || { echo "ERROR: apt-get is required"; exit 1; }; \
	$(SUDO) apt-get update; \
	$(SUDO) DEBIAN_FRONTEND=noninteractive apt-get install -y $(BASE_PACKAGES_DEBIAN); \
	ssh_service="$$(systemctl list-unit-files ssh.service --no-legend 2>/dev/null | grep -q '^ssh.service' && echo ssh.service || echo sshd.service)"; \
	$(SUDO) systemctl enable --now "$$ssh_service"

install-tailscale: ## Install and enable Tailscale for the detected package family
	@set -euo pipefail; \
	. /etc/os-release; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-tailscale-arch ;; \
		*' debian '*|*' ubuntu '*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-tailscale-debian ;; \
		*) echo "ERROR: unsupported package family: ID=$${ID:-unknown} ID_LIKE=$${ID_LIKE:-none}"; exit 1 ;; \
	esac

install-tailscale-arch: ## Install and enable Tailscale on Arch-like systems
	@set -euo pipefail; \
	command -v pacman >/dev/null 2>&1 || { echo "ERROR: pacman is required"; exit 1; }; \
	$(SUDO) pacman -S --needed --noconfirm tailscale; \
	$(SUDO) systemctl enable --now tailscaled.service

install-tailscale-debian: ## Install and enable Tailscale on Debian/Ubuntu systems
	@set -euo pipefail; \
	if command -v tailscale >/dev/null 2>&1; then \
		$(SUDO) systemctl enable --now tailscaled.service; \
	else \
		command -v curl >/dev/null 2>&1 || { $(SUDO) apt-get update; $(SUDO) DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl; }; \
		installer="$$(mktemp)"; \
		curl -fsSL https://tailscale.com/install.sh -o "$$installer"; \
		$(SUDO) sh "$$installer"; \
		rm -f "$$installer"; \
		$(SUDO) systemctl enable --now tailscaled.service; \
	fi

install-workstation-core: ## Install workstation core packages for the detected package family
	@set -euo pipefail; \
	. /etc/os-release; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-workstation-core-arch ;; \
		*' debian '*|*' ubuntu '*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-workstation-core-debian ;; \
		*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" unsupported-workstation-family GROUP=workstation-core ;; \
	esac

install-desktop: ## Install desktop packages for the detected package family
	@set -euo pipefail; \
	. /etc/os-release; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-desktop-arch ;; \
		*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" unsupported-desktop-family ;; \
	esac

install-fonts: ## Install font packages for the detected package family
	@set -euo pipefail; \
	. /etc/os-release; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-fonts-arch ;; \
		*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" unsupported-font-family ;; \
	esac

install-profile: ## Install the package profile selected for this distro family
	@set -euo pipefail; \
	. /etc/os-release; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) \
			echo "PROFILE: arch-desktop"; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-base; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-tailscale; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-workstation-core; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-desktop; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-fonts ;; \
		*' debian '*|*' ubuntu '*) \
			echo "PROFILE: debian-server"; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-base; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-tailscale; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-workstation-core ;; \
		*) echo "ERROR: unsupported package family: ID=$${ID:-unknown} ID_LIKE=$${ID_LIKE:-none}"; exit 1 ;; \
	esac

install-workstation-core-arch: ## Install workstation core packages on Arch-like systems
	@set -euo pipefail; \
	command -v yay >/dev/null 2>&1 || { echo "ERROR: yay is required for Arch workstation packages"; exit 1; }; \
	yay -S --needed --noconfirm $(WORKSTATION_CORE_PACKAGES_ARCH)

install-workstation-core-debian: ## Install CLI-only workstation core packages on Debian/Ubuntu systems
	@set -euo pipefail; \
	command -v apt-get >/dev/null 2>&1 || { echo "ERROR: apt-get is required"; exit 1; }; \
	$(SUDO) apt-get update; \
	$(SUDO) DEBIAN_FRONTEND=noninteractive apt-get install -y $(WORKSTATION_CORE_PACKAGES_DEBIAN)

install-desktop-arch: ## Install desktop packages on Arch-like systems
	@set -euo pipefail; \
	command -v yay >/dev/null 2>&1 || { echo "ERROR: yay is required for Arch desktop packages"; exit 1; }; \
	yay -S --needed --noconfirm $(DESKTOP_PACKAGES_ARCH)

install-fonts-arch: ## Install font packages on Arch-like systems
	@set -euo pipefail; \
	command -v yay >/dev/null 2>&1 || { echo "ERROR: yay is required for Arch font packages"; exit 1; }; \
	yay -S --needed --noconfirm $(FONT_PACKAGES_ARCH)

unsupported-workstation-family:
	@set -euo pipefail; \
	. /etc/os-release; \
	echo "ERROR: package group '$${GROUP:-unknown}' is currently mapped only for Arch-like systems."; \
	echo "DISTRO: $${ID:-unknown}"; \
	echo "DISTRO_LIKE: $${ID_LIKE:-none}"; \
	exit 1

unsupported-desktop-family:
	@set -euo pipefail; \
	. /etc/os-release; \
	echo "ERROR: desktop packages are intentionally mapped only for Arch/EndeavourOS."; \
	echo "DISTRO: $${ID:-unknown}"; \
	echo "DISTRO_LIKE: $${ID_LIKE:-none}"; \
	exit 1

unsupported-font-family:
	@set -euo pipefail; \
	. /etc/os-release; \
	echo "ERROR: font packages are intentionally mapped only for Arch/EndeavourOS desktop restore."; \
	echo "DISTRO: $${ID:-unknown}"; \
	echo "DISTRO_LIKE: $${ID_LIKE:-none}"; \
	exit 1

verify-base: ## Verify public base commands and SSH service without changes
	@set -euo pipefail; \
	failed=0; \
	for command_name in curl git make ssh sshd; do \
		if command -v "$$command_name" >/dev/null 2>&1 || [[ -x "/usr/sbin/$$command_name" || -x "/sbin/$$command_name" ]]; then \
			echo "OK: $$command_name"; \
		else \
			echo "MISSING: $$command_name"; \
			failed=1; \
		fi; \
	done; \
	ssh_service="$$(systemctl list-unit-files ssh.service --no-legend 2>/dev/null | grep -q '^ssh.service' && echo ssh.service || echo sshd.service)"; \
	if ! command -v systemctl >/dev/null 2>&1; then \
		echo "UNKNOWN: systemctl unavailable"; \
	elif ! systemctl show --property=Version --value >/dev/null 2>&1; then \
		echo "UNKNOWN: systemd system bus unavailable"; \
	elif systemctl is-active --quiet "$$ssh_service"; then \
		echo "ACTIVE: $$ssh_service"; \
	else \
		echo "INACTIVE: $$ssh_service"; \
		failed=1; \
	fi; \
	exit "$$failed"

verify-tailscale: ## Verify Tailscale command, service, and login without changes
	@set -euo pipefail; \
	failed=0; \
	if command -v tailscale >/dev/null 2>&1; then \
		echo "OK: tailscale"; \
	else \
		echo "MISSING: tailscale"; \
		failed=1; \
	fi; \
	if ! command -v systemctl >/dev/null 2>&1; then \
		echo "UNKNOWN: systemctl unavailable"; \
	elif ! systemctl show --property=Version --value >/dev/null 2>&1; then \
		echo "UNKNOWN: systemd system bus unavailable"; \
	elif systemctl is-active --quiet tailscaled.service; then \
		echo "ACTIVE: tailscaled.service"; \
	else \
		echo "INACTIVE: tailscaled.service"; \
		failed=1; \
	fi; \
	if command -v tailscale >/dev/null 2>&1; then \
		ip_output="$$(tailscale ip -4 2>&1)" && { echo "CONNECTED: Tailscale ($$ip_output)"; exit "$$failed"; }; \
		case "$$ip_output" in \
			*"operation not permitted"*|*"permission denied"*|*"Access denied"*|*"Failed to connect to local Tailscale daemon"*) \
				echo "UNKNOWN: Tailscale local API unavailable";; \
			*) \
				echo "NOT_CONNECTED: Tailscale"; \
				failed=1;; \
		esac; \
	fi; \
	exit "$$failed"

verify-workstation-core: ## Verify workstation core commands without changes
	@set -euo pipefail; \
	. /etc/os-release; \
	failed=0; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) commands="zsh tmux nvim tree-sitter alacritty zed" ;; \
		*' debian '*|*' ubuntu '*) commands="zsh tmux nvim" ;; \
		*) echo "ERROR: unsupported package family: ID=$${ID:-unknown} ID_LIKE=$${ID_LIKE:-none}"; exit 1 ;; \
	esac; \
	for command_name in $$commands; do \
		if command -v "$$command_name" >/dev/null 2>&1; then \
			echo "OK: $$command_name"; \
		else \
			echo "MISSING: $$command_name"; \
			failed=1; \
		fi; \
	done; \
	exit "$$failed"

verify-desktop: ## Verify desktop commands on Arch/EndeavourOS; skip on Debian/Ubuntu
	@set -euo pipefail; \
	. /etc/os-release; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) ;; \
		*' debian '*|*' ubuntu '*) echo "SKIPPED: desktop package verification is Arch/EndeavourOS-only"; exit 0 ;; \
		*) echo "ERROR: unsupported package family: ID=$${ID:-unknown} ID_LIKE=$${ID_LIKE:-none}"; exit 1 ;; \
	esac; \
	failed=0; \
	for command_name in i3 rofi picom dunstify xss-lock; do \
		if command -v "$$command_name" >/dev/null 2>&1; then \
			echo "OK: $$command_name"; \
		else \
			echo "MISSING: $$command_name"; \
			failed=1; \
		fi; \
	done; \
	exit "$$failed"

verify-fonts: ## Verify workstation fonts on Arch/EndeavourOS; skip on Debian/Ubuntu
	@set -euo pipefail; \
	. /etc/os-release; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) ;; \
		*' debian '*|*' ubuntu '*) echo "SKIPPED: font package verification is Arch/EndeavourOS desktop-only"; exit 0 ;; \
		*) echo "ERROR: unsupported package family: ID=$${ID:-unknown} ID_LIKE=$${ID_LIKE:-none}"; exit 1 ;; \
	esac; \
	command -v fc-match >/dev/null 2>&1 || { echo "MISSING: fc-match"; exit 1; }; \
	failed=0; \
	for font_name in "JetBrains Mono" "Hack" "Ubuntu Mono" "Fira Code" "Noto Sans"; do \
		if fc-match "$$font_name" >/dev/null 2>&1; then \
			echo "OK: $$font_name"; \
		else \
			echo "MISSING: $$font_name"; \
			failed=1; \
		fi; \
	done; \
	exit "$$failed"

verify-profile: ## Verify the package profile selected for this distro family
	@set -euo pipefail; \
	. /etc/os-release; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) \
			echo "PROFILE: arch-desktop"; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" verify-base; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" verify-tailscale; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" verify-workstation-core; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" verify-desktop; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" verify-fonts ;; \
		*' debian '*|*' ubuntu '*) \
			echo "PROFILE: debian-server"; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" verify-base; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" verify-tailscale; \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" verify-workstation-core ;; \
		*) echo "ERROR: unsupported package family: ID=$${ID:-unknown} ID_LIKE=$${ID_LIKE:-none}"; exit 1 ;; \
	esac
