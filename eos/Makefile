.PHONY: help check update u full-update update-full uf UF updf
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/all.mk,$(abspath $(MAKEFILE_LIST))),)
include $(CONFIGS_DIR)/make/all.mk
endif

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
	@echo "Notification provider:"
	@pacman -Q dunst libnotify 2>/dev/null || true
	@echo ""
	@echo "Audio stack:"
	@pacman -Q pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber pavucontrol 2>/dev/null || true

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
