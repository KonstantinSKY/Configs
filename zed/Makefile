.PHONY: install clean

MANJARO_MAKEFILE = ~/Configs/manjaro/Makefile
ZED_CONFIG = ~/Configs/zed/config
ZED_TARGET_CONFIG = ~/.config/zed

install:
	@echo "Installing zed..."
	yay -S zed --noconfirm
	@echo "✅ Zed installed."
	@echo "🔗 Linking Zed config folder..."
	ln -sf $(ZED_CONFIG) $(ZED_TARGET_CONFIG)


clean:
	@echo "Cleaning zed..."
	@echo "✅ Zed cleaned."
