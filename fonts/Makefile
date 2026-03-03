.PHONY: all install update check refresh help

-include $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../make/help.mk)

FONTS = \
	noto-fonts \
	noto-fonts-emoji \
	ttf-jetbrains-mono \
	ttf-jetbrains-mono-nerd \
	ttf-hack \
	ttf-hack-nerd \
	ttf-ubuntu-font-family \
	ttf-ubuntu-mono-nerd \
	ttf-ubuntu-nerd \
	ttf-fira-code \
	ttf-firacode-nerd \
	ttf-sourcecodepro-nerd \
	ttf-sourcecodepro-nerd


all: install update refresh check

install:
	@echo "🔤 Installing fonts with yay..."
	@for font in $(FONTS); do \
		echo "📦 Installing $$font..."; \
		yay -S --noconfirm $$font || echo "⚠️  Failed to install $$font"; \
	done

update:
	@echo "🔁 Updating all packages with yay..."
	yay -Syu --noconfirm

refresh:
	@echo "🔄 Refreshing font cache..."
	fc-cache -fv
	@echo "✅ Font cache refreshed."

check:
	@echo "🔍 Checking if fonts are installed and showing examples..."
	@if ! command -v pango-view >/dev/null 2>&1; then \
		echo "⚠️  pango-view is not installed. Previews won't be shown."; \
	fi
	@for font in $(FONTS); do \
		if yay -Q $$font >/dev/null 2>&1; then \
			echo "✅ $$font is installed."; \
		else \
			echo "❌ $$font is NOT installed."; \
		fi; \
	done
	@echo "-------------------------------------------------------------------"
	@echo "🧪 Testing font cache (fc-list)..."
		@if ! fc-list > /dev/null 2>&1; then \
			echo "❌ Font cache seems broken or inaccessible."; \
		else \
			echo "✅ Font cache is readable."; \
		fi

list:
	@echo "📋 Fonts listed in Makefile:"
	@for font in $(FONTS); do echo " • $$font"; done
	@echo "-------------------------------------------------------------------"
	@echo "📦 Fonts from yay (installed from your list):"
	@for font in $(FONTS); do \
		if yay -Q $$font >/dev/null 2>&1; then \
			echo " ✅ $$font"; \
		else \
			echo " ❌ $$font not installed"; \
		fi \
	done
	@echo "-------------------------------------------------------------------"
	@echo "🖋  Fonts available via fontconfig (fc-list):"
	@fc-list : family | cut -d',' -f1 | sort | uniq | head -n 2000
