# Qt theming bootstrap for Manjaro / i3
# - Installs qt5ct, qt6ct, Kvantum for Qt5/Qt6
# - Links repo-managed config files into ~/.config
# - Expects Qt environment variables to be managed by ~/.xprofile

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/../..)

MANJARO_MAKEFILE ?= $(abspath $(THIS_DIR)/..)/Makefile
XPROFILE ?= $(HOME)/.xprofile

KVANTUM_THEME ?= KvAdaptaMaiaDark

KVANTUM_SOURCE := $(THIS_DIR)/Kvantum/kvantum.kvconfig
QT5CT_SOURCE := $(THIS_DIR)/qt5ct/qt5ct.conf
QT6CT_SOURCE := $(THIS_DIR)/qt6ct/qt6ct.conf

KVANTUM_TARGET := $(HOME)/.config/Kvantum/kvantum.kvconfig
QT5CT_TARGET := $(HOME)/.config/qt5ct/qt5ct.conf
QT6CT_TARGET := $(HOME)/.config/qt6ct/qt6ct.conf

.PHONY: help all install i env e xprofile xp theme t link l verify v
.DEFAULT_GOAL := help

all: install link verify

install i:
	@echo "📦 Installing qt5ct, qt6ct, Kvantum..."
	@$(MAKE) -f "$(MANJARO_MAKEFILE)" install qt5ct qt6ct kvantum kvantum-qt5

env e xprofile xp:
	@echo "🔎 Qt environment is managed via $(XPROFILE)"
	@if [ -r "$(XPROFILE)" ]; then \
		grep -E '^export QT_(QPA_PLATFORMTHEME|STYLE_OVERRIDE)=' "$(XPROFILE)" || \
			echo "⚠️  No QT_* exports found in $(XPROFILE)"; \
	else \
		echo "⚠️  $(XPROFILE) does not exist or is not readable."; \
	fi

link l:
	@echo "🔗 Linking Qt and Kvantum configs..."
	@mkdir -p "$(HOME)/.config/Kvantum" "$(HOME)/.config/qt5ct" "$(HOME)/.config/qt6ct"
	@ln -sf "$(KVANTUM_SOURCE)" "$(KVANTUM_TARGET)"
	@ln -sf "$(QT5CT_SOURCE)" "$(QT5CT_TARGET)"
	@ln -sf "$(QT6CT_SOURCE)" "$(QT6CT_TARGET)"
	@echo "✅ Symlinks created for Kvantum, qt5ct, and qt6ct."

theme t:
	@echo "🎨 Updating repo-managed Kvantum theme config..."
	@printf "[General]\ntheme=$(KVANTUM_THEME)\n" > "$(KVANTUM_SOURCE)"
	@echo "✅ Theme written to $(KVANTUM_SOURCE)"
	@echo "ℹ️  If $(KVANTUM_TARGET) is linked, the change is already active after re-login or app restart."

verify v:
	@echo "🔎 Checking source config files..."
	@for path in "$(KVANTUM_SOURCE)" "$(QT5CT_SOURCE)" "$(QT6CT_SOURCE)"; do \
		if [ ! -r "$$path" ]; then \
			echo "❌ Missing config source: $$path"; \
			exit 1; \
		fi; \
		echo "✅ Found: $$path"; \
	done
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" xprofile
	@echo "🔎 Current home targets:"
	@for target in "$(KVANTUM_TARGET)" "$(QT5CT_TARGET)" "$(QT6CT_TARGET)"; do \
		if [ -L "$$target" ]; then \
			echo "✅ $$target -> $$(readlink -f "$$target")"; \
		elif [ -e "$$target" ]; then \
			echo "⚠️  $$target exists but is not a symlink"; \
		else \
			echo "ℹ️  $$target is not linked yet"; \
		fi; \
	done
	@echo "🔎 Kvantum config:"
	@sed -n '1,40p' "$(KVANTUM_SOURCE)"
	@echo "ℹ️  Apply by re-login or restarting affected Qt apps."
