.PHONY: help install i enable e status s update u cleanup c
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)
EOS_MAKEFILE := $(CONFIGS_DIR)/eos/Makefile

install i:
	@echo "🛠 Installing runtime..."
	@$(MAKE) -s -f "$(EOS_MAKEFILE)" install PKGS="flatpak"
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
