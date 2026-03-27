# Global stow helpers for GNU Make
# Included via all.mk

ensure_stow_installed = \
	if ! command -v stow >/dev/null 2>&1; then \
		echo "📦 Installing stow..."; \
		sudo pacman -S --needed --noconfirm stow; \
	fi

stow_package = \
	stow -d "$(1)" -t "$(2)" "$(3)"
