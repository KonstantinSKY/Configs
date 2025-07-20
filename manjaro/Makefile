.PHONY: setup mirrors pacman-update install-yay enable-aur update

# Main target
setup: mirrors pacman-update install-yay yay-update enable-aur
	@echo "✅ Manjaro i3 setup complete!"

# mirrors update
mirrors:
	@echo "🔄 Updating mirrors..."
	sudo pacman-mirrors --fasttrack && sudo pacman -Syy

# Full update with pamac
pacman-update:
	@echo "⬆️  Running full system upgrade..."
	sudo pacman -Syu --noconfirm

yay-update:
	@echo "⬆️  Updating AUR and system packages with yay..."
	@yay -Syu --noconfirm

# Включение AUR (только если используется pamac)
enable-aur:
	@echo "⚙️  Enabling AUR support in pamac (if applicable)..."
	@if command -v pamac >/dev/null 2>&1; then \
		pamac config --enable-aur; \
	else \
		echo "ℹ️  pamac not found, skipping AUR GUI enabling..."; \
	fi
# Обновление AUR и системных пакетов через yay
update:
	@echo "⬆️  Updating AUR and system packages with yay..."
	@yay -Syyu --noconfirm
