.PHONY: all install_fonts update_fonts check_fonts refresh_fonts help

FONTS = \
	noto-fonts \
	noto-fonts-emoji \
	ttf-jetbrains-mono \
	ttf-hack \
	ttf-hack-nerd

all: install_fonts update_fonts refresh_fonts check_fonts

help:
	@echo "📖 Available targets:"
	@echo "  make install_fonts   – Install all fonts via yay"
	@echo "  make update_fonts    – Update system packages"
	@echo "  make refresh_fonts   – Rebuild font cache (fc-cache)"
	@echo "  make check_fonts     – Check if fonts are installed"
	@echo "  make all             – Run install, update, refresh, and check"
	@echo "  make help            – Show this help message"

install_fonts:
	@echo "🔤 Installing fonts with yay..."
	@for font in $(FONTS); do \
		echo "📦 Installing $$font..."; \
		yay -S --noconfirm $$font || echo "⚠️  Failed to install $$font"; \
	done

update_fonts:
	@echo "🔁 Updating all packages with yay..."
	yay -Syu --noconfirm

refresh_fonts:
	@echo "🔄 Refreshing font cache..."
	fc-cache -fv
	@echo "✅ Font cache refreshed."

check_fonts:
	@echo "🔍 Checking if fonts are installed and showing examples..."
	@for font in $(FONTS); do \
		if yay -Q $$font >/dev/null 2>&1; then \
			echo "✅ $$font is installed."; \
			MATCHED=$$(fc-match ":family=$${font}" | cut -d: -f1); \
			if [ -n "$$MATCHED" ]; then \
				echo "📝 Sample (using $$MATCHED):"; \
				echo "    → The quick brown fox jumps over the lazy dog." | \
				PANGOCAIRO_BACKEND=fc \
				PANGO_FONT="$${MATCHED}" \
				pango-view --text="The quick brown fox jumps over the lazy dog." \
					--font="$${MATCHED} 12" \
					--no-display --annotate=none --dpi=96 --output=/dev/null \
				|| echo "⚠️  Can't render preview for $$MATCHED."; \
			fi \
		else \
			echo "❌ $$font is NOT installed."; \
		fi; \
	done
