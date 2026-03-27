.PHONY: install i enable e status s update u cleanup c

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

include $(CONFIGS_DIR)/make/update.mk

install i:
	@echo "🛠 Installing runtime..."
	@$(call ensure_system_updated)
	@yay -S --needed --noconfirm flatpak || { echo '❌ yay failed'; exit 1; }
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" enable
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" status
	@echo "✅ Done."
	@echo "-----------------------------------------------------------------------------------"
enable e:
	@echo "🛰 Adding Flathub remote (if missing)..."
	@flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	@echo "✅ Flathub configured."
	@echo "-----------------------------------------------------------------------------------"
status s:
	@echo "ℹ️  runtime:"
	@flatpak --version 2>/dev/null || echo "not installed"
	@echo "-----------------------------"
	@echo "ℹ️  remotes:"
	@flatpak remotes 2>/dev/null || true
	@echo "-----------------------------------------------------------------------------------"
update u:
	@echo "⬆️  Updating apps and runtimes..."
	@flatpak update -y || true
	@echo "-----------------------------------------------------------------------------------"
cleanup c:
	@echo "🧹 Removing unused runtimes..."
	@flatpak uninstall -y --unused || true
	@echo "-----------------------------------------------------------------------------------"
