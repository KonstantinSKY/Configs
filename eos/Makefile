SHELL := /bin/bash

.PHONY: help check bootstrap mirror-tools mirrors upgrade install-yay enable-aur \
	install i yay-update update u full-update update-full uf UF updf
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/all.mk,$(abspath $(MAKEFILE_LIST))),)
include $(CONFIGS_DIR)/make/all.mk
endif

include $(THIS_DIR)/packages/ai-tools.mk
include $(THIS_DIR)/packages/base-tools.mk
include $(THIS_DIR)/packages/browsers.mk
include $(THIS_DIR)/packages/ssh.mk

PKGS ?= $(filter-out install i,$(MAKECMDGOALS))
ARCH_MIRRORLIST := /etc/pacman.d/mirrorlist
EOS_MIRRORLIST := /etc/pacman.d/endeavouros-mirrorlist
REFLECTOR_CONFIG := /etc/xdg/reflector/reflector.conf
REFLECTOR_CONFIG_SOURCE := $(THIS_DIR)/reflector.conf

bootstrap: mirror-tools mirrors upgrade install-yay enable-aur ## Prepare fresh EndeavourOS package management
	@echo "EndeavourOS bootstrap complete."

mirror-tools: ## Ensure EndeavourOS mirror management tools are installed
	@sudo pacman -S --needed --noconfirm reflector eos-rankmirrors

mirrors: ## Configure and rank Arch and EndeavourOS mirrors with rollback
	@command -v reflector >/dev/null 2>&1 || { echo "ERROR: reflector is required"; exit 1; }
	@command -v eos-rankmirrors >/dev/null 2>&1 || { echo "ERROR: eos-rankmirrors is required"; exit 1; }
	@test -s "$(REFLECTOR_CONFIG_SOURCE)" || { echo "ERROR: missing $(REFLECTOR_CONFIG_SOURCE)"; exit 1; }
	@set -eu; \
	stamp="$$(date +%Y%m%d_%H%M%S)"; \
	arch_backup="$(ARCH_MIRRORLIST).bak.$$stamp"; \
	eos_backup="$(EOS_MIRRORLIST).bak.$$stamp"; \
	sudo cp -a "$(ARCH_MIRRORLIST)" "$$arch_backup"; \
	sudo cp -a "$(EOS_MIRRORLIST)" "$$eos_backup"; \
	restore() { \
		echo "ERROR: mirror update failed; restoring backups"; \
		sudo cp -a "$$arch_backup" "$(ARCH_MIRRORLIST)"; \
		sudo cp -a "$$eos_backup" "$(EOS_MIRRORLIST)"; \
	}; \
	trap restore ERR; \
	sudo install -Dm644 "$(REFLECTOR_CONFIG_SOURCE)" "$(REFLECTOR_CONFIG)"; \
	sudo reflector --country US --protocol https --latest 20 --sort age \
		--download-timeout 5 --save "$(ARCH_MIRRORLIST)"; \
	sudo eos-rankmirrors --parallel --sort rate --timeout 10; \
	grep -q '^Server = ' "$(ARCH_MIRRORLIST)"; \
	grep -q '^Server = ' "$(EOS_MIRRORLIST)"; \
	trap - ERR; \
	echo "Mirror lists updated; backups: $$arch_backup $$eos_backup"

upgrade: ## Fully upgrade EndeavourOS and refresh both keyrings
	@sudo pacman -Syu --needed --noconfirm archlinux-keyring endeavouros-keyring

install-yay: ## Ensure the EndeavourOS-supported AUR helper is installed
	@sudo pacman -S --needed --noconfirm yay

enable-aur: ## Enable AUR in Pamac when Pamac is installed
	@if command -v pamac >/dev/null 2>&1; then \
		pamac config --enable-aur; \
	else \
		echo "Pamac is not installed; yay provides AUR access."; \
	fi

install i: ## Install one or more packages without another full system update
	@if [[ -z "$(strip $(PKGS))" ]]; then \
		echo "Usage: make -f eos/Makefile install PKGS='package ...'"; \
		exit 1; \
	fi
	@yay -S --needed --noconfirm $(PKGS)

yay-update: update ## Compatibility alias for shared leaf installers

check: ## Inspect current EndeavourOS state without changing anything
	@echo "EndeavourOS check: read-only"
	@echo "-------------------------------------------------------------------------------"
	@echo "OS:"
	@cat /etc/os-release
	@echo ""
	@echo "Failed systemd units:"
	@systemctl --failed --no-pager
	@echo ""
	@echo "Keyrings:"
	@pacman -Q archlinux-keyring endeavouros-keyring 2>/dev/null || true
	@echo ""
	@echo "AUR helper:"
	@command -v yay || true
	@command -v paru || true
	@echo ""
	@echo "Notification provider:"
	@pacman -Q dunst libnotify 2>/dev/null || true
	@echo ""
	@echo "Audio stack:"
	@pacman -Q pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber pavucontrol 2>/dev/null || true
	@echo ""
	@echo "AI tools:"
	@pacman -Q $(AI_TOOLS) 2>/dev/null || true
	@echo ""
	@echo "Base tools:"
	@pacman -Q $(BASE_TOOLS) 2>/dev/null || true
	@echo ""
	@echo "Browsers:"
	@pacman -Q $(BROWSERS) 2>/dev/null || true
	@echo ""
	@echo "SSH:"
	@pacman -Q openssh 2>/dev/null || true
	@systemctl is-enabled sshd 2>/dev/null || true
	@systemctl is-active sshd 2>/dev/null || true

update u: ## Update system and AUR packages via yay
	@yay -Syu --noconfirm --answerclean None --answerdiff None

full-update update-full uf UF updf: ## Full maintenance: update, remove orphans, clean cache, update flatpak
	@$(MAKE) -s -f $(THIS_MAKEFILE) update
	@echo "Removing orphaned pacman dependencies..."
	@ORPHANS="$$(pacman -Qqdt 2>/dev/null || true)"; \
	if [ -n "$$ORPHANS" ]; then \
		sudo pacman -Rns --noconfirm $$ORPHANS; \
	else \
		echo "No orphaned dependencies found."; \
	fi
	@echo "Cleaning pacman package cache..."
	@if command -v paccache >/dev/null 2>&1; then \
		paccache -rk1; \
	else \
		echo "paccache is not installed; skipping cache cleanup."; \
	fi
	@echo "Updating flatpak apps and runtimes..."
	@if command -v flatpak >/dev/null 2>&1; then \
		flatpak update -y; \
		flatpak uninstall -y --unused; \
	else \
		echo "flatpak is not installed; skipping flatpak maintenance."; \
	fi
