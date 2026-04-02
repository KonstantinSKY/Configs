.PHONY: install-ssh ssh-password-on ssh-password-off

SSH_PACKAGE := openssh
SSH_CONFIG := /etc/ssh/sshd_config

define ssh_set_password
	echo "$(2) password authentication in $(SSH_CONFIG)..."; \
	sudo test -f "$(SSH_CONFIG)"; \
	sudo sed -i \
		-e 's/^[#[:space:]]*PasswordAuthentication[[:space:]].*/PasswordAuthentication $(1)/' \
		-e 's/^[#[:space:]]*KbdInteractiveAuthentication[[:space:]].*/KbdInteractiveAuthentication $(1)/' \
		"$(SSH_CONFIG)"; \
	echo "🔍 Validating sshd configuration..."; \
	sudo sshd -t; \
	echo "🔄 Restarting sshd service..."; \
	sudo systemctl restart sshd; \
	echo "-------------------------------------------------------------------------------"
endef

install-ssh: ## Install OpenSSH server package and enable sshd
	@echo "📦 Installing $(SSH_PACKAGE)..."
	@sudo pacman -S --needed --noconfirm $(SSH_PACKAGE)
	@echo "⚙️  Enabling and starting sshd..."
	@sudo systemctl enable --now sshd
	@echo "🔍 Checking sshd status..."
	@sudo systemctl is-active sshd
	@echo "-------------------------------------------------------------------------------"

ssh-password-on: ## Enable password authentication in sshd
	@$(call ssh_set_password,yes,🔓 Enabling)

ssh-password-off: ## Disable password authentication in sshd
	@$(call ssh_set_password,no,🔐 Disabling)
