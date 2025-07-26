.PHONY: help all install_theme install_icons apply_theme set_gtk2 set_gtk3 set_gtk4 check_theme

GTK_THEME = Matcha-dark-sea
ICON_THEME = Papirus-Dark
FONT = Noto Sans 10

GTK2_CONFIG = $(HOME)/.gtkrc-2.0
GTK3_DIR = $(HOME)/.config/gtk-3.0
GTK3_CONFIG = $(GTK3_DIR)/settings.ini
GTK4_DIR = $(HOME)/.config/gtk-4.0
GTK4_CONFIG = $(GTK4_DIR)/settings.ini

help:
	@echo "📖 Available targets:"
	@echo "  make all           - Install and apply GTK and icon themes, then check configuration"
	@echo "  make install_theme - Install GTK theme ($(GTK_THEME)) using yay"
	@echo "  make install_icons - Install icon theme ($(ICON_THEME)) using yay"
	@echo "  make apply_theme   - Apply theme settings to GTK2/3/4 configs"
	@echo "  make set_gtk2      - Apply GTK2 settings"
	@echo "  make set_gtk3      - Apply GTK3 settings"
	@echo "  make set_gtk4      - Apply GTK4 settings"
	@echo "  make check_theme   - Check if themes are installed and configs are correct"
	@echo "  make help          - Show this help message"

all: install_theme install_icons apply_theme check_theme

install_theme:
	@echo "🎨 Installing GTK theme: $(GTK_THEME) using yay..."
	yay -S --noconfirm matcha-gtk-theme || echo "⚠️  Failed to install GTK theme."

install_icons:
	@echo "🖼️  Installing icon theme: $(ICON_THEME) using yay..."
	yay -S --noconfirm papirus-icon-theme || echo "⚠️  Failed to install icon theme."

apply_theme: set_gtk2 set_gtk3 set_gtk4
	@echo "✅ GTK themes (2/3/4) and icons applied. Restart apps to see changes."

set_gtk2:
	@echo "🛠️  Applying GTK2 theme..."
	@if [ -f "$(GTK2_CONFIG)" ]; then cp "$(GTK2_CONFIG)" "$(GTK2_CONFIG).bak"; else echo "" > "$(GTK2_CONFIG)"; fi
	@sed -i '/^gtk-theme-name=/d' $(GTK2_CONFIG)
	@sed -i '/^gtk-icon-theme-name=/d' $(GTK2_CONFIG)
	@sed -i '/^gtk-font-name=/d' $(GTK2_CONFIG)
	@echo "gtk-theme-name=\"$(GTK_THEME)\"" >> $(GTK2_CONFIG)
	@echo "gtk-icon-theme-name=\"$(ICON_THEME)\"" >> $(GTK2_CONFIG)
	@echo "gtk-font-name=\"$(FONT)\"" >> $(GTK2_CONFIG)

set_gtk3:
	@echo "🛠️  Applying GTK3 theme..."
	mkdir -p $(GTK3_DIR)
	@if [ -f "$(GTK3_CONFIG)" ]; then cp "$(GTK3_CONFIG)" "$(GTK3_CONFIG).bak"; else echo "[Settings]" > $(GTK3_CONFIG); fi
	@sed -i '/^gtk-theme-name=/d' $(GTK3_CONFIG)
	@sed -i '/^gtk-icon-theme-name=/d' $(GTK3_CONFIG)
	@sed -i '/^gtk-font-name=/d' $(GTK3_CONFIG)
	@sed -i '/^gtk-application-prefer-dark-theme=/d' $(GTK3_CONFIG)
	@echo "gtk-theme-name=$(GTK_THEME)" >> $(GTK3_CONFIG)
	@echo "gtk-icon-theme-name=$(ICON_THEME)" >> $(GTK3_CONFIG)
	@echo "gtk-font-name=$(FONT)" >> $(GTK3_CONFIG)
	@echo "gtk-application-prefer-dark-theme=true" >> $(GTK3_CONFIG)

set_gtk4:
	@echo "🛠️  Applying GTK4 theme..."
	mkdir -p $(GTK4_DIR)
	@if [ -f "$(GTK4_CONFIG)" ]; then cp "$(GTK4_CONFIG)" "$(GTK4_CONFIG).bak"; else echo "[Settings]" > $(GTK4_CONFIG); fi
	@sed -i '/^gtk-theme-name=/d' $(GTK4_CONFIG)
	@sed -i '/^gtk-icon-theme-name=/d' $(GTK4_CONFIG)
	@sed -i '/^gtk-font-name=/d' $(GTK4_CONFIG)
	@sed -i '/^gtk-application-prefer-dark-theme=/d' $(GTK4_CONFIG)
	@echo "gtk-theme-name=$(GTK_THEME)" >> $(GTK4_CONFIG)
	@echo "gtk-icon-theme-name=$(ICON_THEME)" >> $(GTK4_CONFIG)
	@echo "gtk-font-name=$(FONT)" >> $(GTK4_CONFIG)
	@echo "gtk-application-prefer-dark-theme=true" >> $(GTK4_CONFIG)

check_theme:
	@echo "🔍 Проверка установки и конфигурации тем GTK..."
	@if yay -Q matcha-gtk-theme >/dev/null 2>&1; then \
		echo "✅ GTK theme '$(GTK_THEME)' is installed."; \
	else \
		echo "❌ GTK theme '$(GTK_THEME)' is NOT installed."; \
	fi
	@if yay -Q papirus-icon-theme >/dev/null 2>&1; then \
		echo "✅ Icon theme '$(ICON_THEME)' is installed."; \
	else \
		echo "❌ Icon theme '$(ICON_THEME)' is NOT installed."; \
	fi
	@echo "📝 GTK2 config:"; grep -E 'gtk-(theme|icon|font)' $(GTK2_CONFIG) || echo "⚠️  Not configured."
	@echo "📝 GTK3 config:"; grep -E 'gtk-(theme|icon|font)' $(GTK3_CONFIG) || echo "⚠️  Not configured."
	@echo "📝 GTK4 config:"; grep -E 'gtk-(theme|icon|font)' $(GTK4_CONFIG) || echo "⚠️  Not configured."
