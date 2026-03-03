# Qt theming bootstrap for Manjaro / i3
# - Installs qt5ct, qt6ct, Kvantum for Qt5/Qt6
# - Exports env vars in ~/.profile (idempotent)
# - Ensures ~/.xprofile sources ~/.profile for GUI sessions

MANJARO_MAKEFILE ?= $(HOME)/Configs/manjaro/Makefile
PROFILE          ?= $(HOME)/.profile
XPROFILE         ?= $(HOME)/.xprofile

# Default Kvantum theme (can be changed later in Kvantum Manager)
KVANTUM_THEME    ?= Matcha-Dark

.PHONY: help install i env e xprofile xp theme t link l verify v all

-include $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../make/help.mk)

all: install env xprofile link verify

install i:
	@echo "📦 Installing qt5ct, qt6ct, Kvantum..."
	@make -f $(MANJARO_MAKEFILE) install qt5ct qt6ct kvantum

link l:
	@echo "🔗 Linking Qt and Kvantum configs..."
	@mkdir -p $(HOME)/.config/Kvantum $(HOME)/.config/qt5ct $(HOME)/.config/qt6ct
	@ln -sf $(CURDIR)/Kvantum/kvantum.kvconfig $(HOME)/.config/Kvantum/kvantum.kvconfig
	@ln -sf $(CURDIR)/qt5ct/qt5ct.conf $(HOME)/.config/qt5ct/qt5ct.conf
	@ln -sf $(CURDIR)/qt6ct/qt6ct.conf $(HOME)/.config/qt6ct/qt6ct.conf
	@echo "✅ Symlinks created for Kvantum, qt5ct, and qt6ct."

theme t:
	@echo "🎨 Preparing Kvantum theme config (optional)..."
	@mkdir -p $(HOME)/.config/Kvantum
	@printf "[General]\ntheme=$(KVANTUM_THEME)\n" > $(HOME)/.config/Kvantum/kvantum.kvconfig
	@echo "ℹ️  Open 'kvantummanager' to pick another theme or import *.kvconfig packs."

verify v:
	@echo "🔎 Environment variables (current shell may not reflect login files):"
	@/usr/bin/env | grep -E '^QT_(QPA_PLATFORMTHEME|STYLE_OVERRIDE)=' || true
	@echo "🔎 Kvantum config:"
	@sed -n '1,80p' $(HOME)/.config/Kvantum/kvantum.kvconfig 2>/dev/null || echo "(no kvantum.kvconfig yet)"
	@echo "ℹ️  Apply by re-login (or i3 restart). For GUI launchers, ensure they source ~/.xprofile."
