# IMPORTANT:
# Humans and AI agents must not modify this file without explicit user confirmation.

.PHONY: \
	help \
	setup \
	mirrors \
	enable-aur \
	update u
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
GTK_MAKEFILE := $(THIS_DIR)/gtk/Makefile
QT_MAKEFILE := $(THIS_DIR)/qt/Makefile

include $(THIS_DIR)/packages/keyrings.mk
include $(THIS_DIR)/packages/base-packages.mk
include $(THIS_DIR)/packages/install.mk
include $(THIS_DIR)/packages/clean.mk
include $(THIS_DIR)/packages/ssh.mk
include $(THIS_DIR)/packages/audio.mk
include $(THIS_DIR)/packages/notifications.mk
include $(THIS_DIR)/packages/audit.mk
include $(THIS_DIR)/laptop.mk
include $(THIS_DIR)/session.mk
include $(THIS_DIR)/check.mk

	## ---------------------------
	## 🧩 Setup
	## ---------------------------
setup: ## Run the full Manjaro bootstrap flow via yay
	@$(MAKE) -s -f $(THIS_MAKEFILE) refresh-keyrings
	@$(MAKE) -s -f $(THIS_MAKEFILE) cleanup
	@$(MAKE) -s -f $(THIS_MAKEFILE) remove-audio
	@$(MAKE) -s -f $(THIS_MAKEFILE) remove-notifications
	@echo "⬆️  Updating all system packages via pacman before yay bootstrap..."
	@sudo pacman -Syu --noconfirm
	@$(MAKE) -s -f $(THIS_MAKEFILE) install-ssh
	@$(MAKE) -s -f $(THIS_MAKEFILE) install-yay
	@$(MAKE) -s -f $(THIS_MAKEFILE) mirrors
	@$(MAKE) -s -f $(THIS_MAKEFILE) zsh
	@$(MAKE) -s -f $(THIS_MAKEFILE) xprofile
	@$(MAKE) -s -f $(THIS_MAKEFILE) mimeapps
	@$(MAKE) -s -f $(THIS_MAKEFILE) install-base
	@$(MAKE) -s -f $(THIS_MAKEFILE) install-audio
	@$(MAKE) -s -f $(GTK_MAKEFILE) install
	@$(MAKE) -s -f $(QT_MAKEFILE) install
	@$(MAKE) -s -f $(THIS_MAKEFILE) install-notifications
	@$(MAKE) -s -f $(THIS_MAKEFILE) configure-notifications
	@$(MAKE) -s -f $(THIS_MAKEFILE) clean-orphans
	@echo "✅ Manjaro i3 setup complete!"

mirrors: ## Refresh Manjaro mirrors and package databases
	@echo "🔄 Updating mirrors..."
	@sudo pacman-mirrors --fasttrack --timeout 3
	@if command -v yay >/dev/null 2>&1; then \
		yay -Syy --noconfirm; \
	else \
		echo "ℹ️  yay is not installed yet; package database refresh will happen after bootstrap."; \
	fi
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
	@$(require_yay)
	@$(MAKE) -s -f $(THIS_MAKEFILE) yay-update
	@$(MAKE) -s -f $(THIS_MAKEFILE) clean-orphans
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

# Prevent make from treating package names as targets
%:
	@:
