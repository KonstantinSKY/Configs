.PHONY: refresh-keyrings

KEYRING_PACKAGES = \
	archlinux-keyring \
	manjaro-keyring

refresh-keyrings: ## Refresh Arch and Manjaro keyrings before package operations
	@echo "🔑 Refreshing pacman keyrings..."
	@sudo pacman -Sy --needed --noconfirm $(KEYRING_PACKAGES)
	@echo "-------------------------------------------------------------------------------"
