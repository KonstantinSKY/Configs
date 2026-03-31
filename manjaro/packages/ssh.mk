.PHONY: install-ssh ssh-password-on ssh-password-off

SSH_PACKAGE := openssh
SSH_CONFIG := /etc/ssh/sshd_config

install-ssh: ## Install OpenSSH server package and enable sshd
	@echo "📦 Installing $(SSH_PACKAGE)..."
	@sudo pacman -S --needed --noconfirm $(SSH_PACKAGE)
	@echo "⚙️  Enabling and starting sshd..."
	@sudo systemctl enable --now sshd
	@echo "🔍 Checking sshd status..."
	@sudo systemctl is-active sshd
	@echo "-------------------------------------------------------------------------------"

ssh-password-on: ## Enable password authentication in sshd
	@echo "🔓 Enabling password authentication in $(SSH_CONFIG)..."
	@sudo test -f "$(SSH_CONFIG)"
	@sudo sed -i \
		-e 's/^[#[:space:]]*PasswordAuthentication[[:space:]].*/PasswordAuthentication yes/' \
		-e 's/^[#[:space:]]*KbdInteractiveAuthentication[[:space:]].*/KbdInteractiveAuthentication yes/' \
		"$(SSH_CONFIG)"
	@echo "🔍 Validating sshd configuration..."
	@sudo sshd -t
	@echo "🔄 Restarting sshd service..."
	@sudo systemctl restart sshd
	@echo "-------------------------------------------------------------------------------"

ssh-password-off: ## Disable password authentication in sshd
	@echo "🔐 Disabling password authentication in $(SSH_CONFIG)..."
	@sudo test -f "$(SSH_CONFIG)"
	@sudo sed -i \
		-e 's/^[#[:space:]]*PasswordAuthentication[[:space:]].*/PasswordAuthentication no/' \
		-e 's/^[#[:space:]]*KbdInteractiveAuthentication[[:space:]].*/KbdInteractiveAuthentication no/' \
		"$(SSH_CONFIG)"
	@echo "🔍 Validating sshd configuration..."
	@sudo sshd -t
	@echo "🔄 Restarting sshd service..."
	@sudo systemctl restart sshd
	@echo "-------------------------------------------------------------------------------"
