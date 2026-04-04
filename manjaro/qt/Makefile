# Qt theming bootstrap for Manjaro / i3
# - Installs qt5ct, qt6ct, Kvantum for Qt5/Qt6
# - Links repo-managed config files into ~/.config
# - Expects Qt environment variables to be managed by ~/.xprofile

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/../..)

ifeq ($(filter $(CONFIGS_DIR)/make/link.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/link.mk
endif

XPROFILE ?= $(HOME)/.xprofile
KVANTUM_THEME ?= KvAdaptaMaiaDark
QT_PACKAGES = qt5ct qt6ct kvantum kvantum-qt5

KVANTUM_SOURCE := $(THIS_DIR)/Kvantum/kvantum.kvconfig
QT5CT_SOURCE := $(THIS_DIR)/qt5ct/qt5ct.conf
QT6CT_SOURCE := $(THIS_DIR)/qt6ct/qt6ct.conf

KVANTUM_TARGET := $(HOME)/.config/Kvantum/kvantum.kvconfig
QT5CT_TARGET := $(HOME)/.config/qt5ct/qt5ct.conf
QT6CT_TARGET := $(HOME)/.config/qt6ct/qt6ct.conf

.PHONY: help all install i env e xprofile xp theme t link l verify v
.DEFAULT_GOAL := help

all: install

install i: ## Install Qt/Kvantum packages and link managed configs
	@$(require_yay)
	@echo "📦 Installing Qt packages: $(QT_PACKAGES)..."
	@yay -S --needed --noconfirm $(QT_PACKAGES)
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" link
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ Qt installed and configured."

env e xprofile xp:
	@echo "🔎 Qt environment is managed via $(XPROFILE)"
	@if [ -r "$(XPROFILE)" ]; then \
		grep -E '^export QT_(QPA_PLATFORMTHEME|STYLE_OVERRIDE)=' "$(XPROFILE)" || \
			echo "⚠️  No QT_* exports found in $(XPROFILE)"; \
	else \
		echo "⚠️  $(XPROFILE) does not exist or is not readable."; \
	fi

link l: ## Link Qt and Kvantum configs into ~/.config
	@$(call link,$(KVANTUM_SOURCE),$(KVANTUM_TARGET))
	@$(call link,$(QT5CT_SOURCE),$(QT5CT_TARGET))
	@$(call link,$(QT6CT_SOURCE),$(QT6CT_TARGET))

theme t:
	@echo "🎨 Updating repo-managed Kvantum theme config..."
	@printf "[General]\ntheme=$(KVANTUM_THEME)\n" > "$(KVANTUM_SOURCE)"
	@echo "✅ Theme written to $(KVANTUM_SOURCE)"
	@echo "ℹ️  If $(KVANTUM_TARGET) is linked, the change is already active after re-login or app restart."

verify v: ## Verify Qt/Kvantum config symlinks and environment
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" xprofile
	@echo "🔎 Current home targets:"
	@$(call verify_link,$(KVANTUM_TARGET))
	@$(call verify_link,$(QT5CT_TARGET))
	@$(call verify_link,$(QT6CT_TARGET))
