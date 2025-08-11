# Qt theming bootstrap for Manjaro / i3
# - Installs qt5ct, qt6ct, Kvantum for Qt5/Qt6
# - Exports env vars in ~/.profile (idempotent)
# - Ensures ~/.xprofile sources ~/.profile for GUI sessions

MANJARO_MAKEFILE ?= $(HOME)/Configs/manjaro/Makefile
PROFILE          ?= $(HOME)/.profile
XPROFILE         ?= $(HOME)/.xprofile

# Default Kvantum theme (can be changed later in Kvantum Manager)
KVANTUM_THEME    ?= KvAdaptaDark

.PHONY: help install i env e xprofile xp theme t verify v all

help:
	@echo "Targets:"
	@echo "  install | i   - Install qt5ct, qt6ct, Kvantum (+qt5 plugin if available)"
	@echo "  env     | e   - Export QT vars to ~/.profile (Qt5+Qt6, Kvantum)"
	@echo "  xprofile| xp  - Ensure ~/.xprofile sources ~/.profile"
	@echo "  theme   | t   - Precreate Kvantum config with $(KVANTUM_THEME) (optional)"
	@echo "  verify  | v   - Show effective Qt env + Kvantum config info"
	@echo "  all           - install -> env -> xprofile -> theme -> verify"

install i:
	@echo "📦 Installing qt5ct, qt6ct, Kvantum..."
	@make -f $(MANJARO_MAKEFILE) install qt5ct qt6ct kvantum

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
