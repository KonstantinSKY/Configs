.PHONY: install password-on password-off

MAKEFLAGS += --no-print-directory

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

include $(CONFIGS_DIR)/make/update.mk

PACKAGE_NAME := openssh
TARGET_CONFIG := /etc/ssh/sshd_config

install: ## Install OpenSSH server package and start sshd
	@$(call ensure_system_updated)
	@echo "📦 Installing $(PACKAGE_NAME)..."
	sudo pacman -S --needed --noconfirm $(PACKAGE_NAME)
	@echo "⚙️  Enabling and starting sshd..."
	sudo systemctl enable --now sshd
	@echo "🔍 Checking sshd status..."
	sudo systemctl is-active sshd

password-on: ## Enable password authentication in sshd
	@echo "🔓 Enabling password authentication in $(TARGET_CONFIG)..."
	@sudo test -f "$(TARGET_CONFIG)"
	@sudo sed -i \
		-e 's/^[#[:space:]]*PasswordAuthentication[[:space:]].*/PasswordAuthentication yes/' \
		-e 's/^[#[:space:]]*KbdInteractiveAuthentication[[:space:]].*/KbdInteractiveAuthentication yes/' \
		"$(TARGET_CONFIG)"
	@echo "🔍 Validating sshd configuration..."
	sudo sshd -t
	@echo "🔄 Restarting sshd service..."
	sudo systemctl restart sshd

password-off: ## Disable password authentication in sshd
	@echo "🔐 Disabling password authentication in $(TARGET_CONFIG)..."
	@sudo test -f "$(TARGET_CONFIG)"
	@sudo sed -i \
		-e 's/^[#[:space:]]*PasswordAuthentication[[:space:]].*/PasswordAuthentication no/' \
		-e 's/^[#[:space:]]*KbdInteractiveAuthentication[[:space:]].*/KbdInteractiveAuthentication no/' \
		"$(TARGET_CONFIG)"
	@echo "🔍 Validating sshd configuration..."
	sudo sshd -t
	@echo "🔄 Restarting sshd service..."
	sudo systemctl restart sshd
