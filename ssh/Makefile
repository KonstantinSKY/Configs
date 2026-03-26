.PHONY: install package keys config validate enable restart status

MAKEFLAGS += --no-print-directory

PACKAGE_NAME := openssh
SOURCE_CONFIG := $(HOME)/Work/Configs/ssh/sshd_config
TARGET_CONFIG := /etc/ssh/sshd_config

install: package keys config validate enable restart status ## Install and configure sshd

package: ## Install OpenSSH package
	@echo "📦 Installing $(PACKAGE_NAME)..."
	sudo pacman -S --needed --noconfirm $(PACKAGE_NAME)

keys: ## Ensure host keys exist
	@echo "🔑 Ensuring SSH host keys exist..."
	sudo ssh-keygen -A

config: ## Backup existing config and install repo config
	@echo "🧪 Validating source config before install..."
	sudo sshd -t -f "$(SOURCE_CONFIG)"
	@echo "📄 Installing sshd config to $(TARGET_CONFIG)..."
	@if sudo test -f "$(TARGET_CONFIG)" && ! sudo cmp -s "$(SOURCE_CONFIG)" "$(TARGET_CONFIG)"; then \
		BACKUP_PATH="$(TARGET_CONFIG).bak.$$(date +%Y%m%d_%H%M%S)"; \
		echo "📦 Backing up existing config to $$BACKUP_PATH"; \
		sudo cp "$(TARGET_CONFIG)" "$$BACKUP_PATH"; \
	fi
	sudo install -Dm600 "$(SOURCE_CONFIG)" "$(TARGET_CONFIG)"

validate: ## Validate active sshd configuration
	@echo "🔍 Validating active sshd configuration..."
	sudo sshd -t

enable: ## Enable sshd service on boot
	@echo "⚙️  Enabling sshd service..."
	sudo systemctl enable sshd

restart: ## Restart sshd service
	@echo "🔄 Restarting sshd service..."
	sudo systemctl restart sshd

status: ## Show sshd service status
	@echo "📡 sshd service status:"
	systemctl --no-pager --full status sshd
