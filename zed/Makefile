.PHONY: install clean
-include $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../make/help.mk)

MANJARO_MAKEFILE = ~/Configs/manjaro/Makefile
ZED_CONFIG = ~/Configs/zed
ZED_TARGET_CONFIG = ~/.config/zed

install: ## Install Zed and link configuration
	@echo "Installing zed..."
	yay -S zed --noconfirm
	@echo "✅ Zed installed."
	@echo "🔗 Linking Zed config folder..."
	ln -sf $(ZED_CONFIG) $(ZED_TARGET_CONFIG)


clean: ## Cleanup placeholder target for Zed
	@echo "Cleaning zed..."
	@echo "✅ Zed cleaned."
