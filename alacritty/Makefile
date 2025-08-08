# Makefile for installing and configuring Alacritty on Manjaro

.PHONY: help install

MANJARO_MAKEFILE := ~/Configs/manjaro/Makefile
CONFIG_DIR := $(HOME)/.config/alacritty
CONFIG_FILE_NAME := alacritty.toml
SOURCE_CONFIG := $(HOME)/Configs/alacritty/$(CONFIG_FILE_NAME)
TARGET_CONFIG := $(CONFIG_DIR)/$(CONFIG_FILE_NAME)

help:
	@echo "📦 Available targets:"
	@echo "  make install     – Update system, install Alacritty, and link config"
	@echo "  make help        – Show this help message"

install:
	@echo "🔄 Updating system before installation..."
	@$(MAKE) -f $(MANJARO_MAKEFILE) update

	@echo "-------------------------------------------------------------------------------"
	@echo "📥 Installing Alacritty via yay..."
	yay -S alacritty --noconfirm
	@echo "-------------------------------------------------------------------------------"

	@echo "📁 Ensuring config directory exists at $(CONFIG_DIR)..."
	mkdir -p $(CONFIG_DIR)
	@echo "-------------------------------------------------------------------------------"

	@echo "🔗 Creating symbolic link to config file..."
	ln -sf $(SOURCE_CONFIG) $(TARGET_CONFIG)
	@echo "-------------------------------------------------------------------------------"

	@echo "✅ Alacritty installed and configured!"
