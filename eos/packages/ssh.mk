.PHONY: install-ssh ssh ssh-password-on ssh-password-off

SSH_PACKAGE := openssh
SSH_CONFIG := /etc/ssh/sshd_config

define ssh_set_password
	echo "$(2) password authentication in $(SSH_CONFIG)..."; \
	sudo test -f "$(SSH_CONFIG)"; \
	for param in PasswordAuthentication KbdInteractiveAuthentication; do \
		if sudo grep -qE "^[#[:space:]]*$$param[[:space:]]" "$(SSH_CONFIG)"; then \
			sudo sed -i "s/^[#[:space:]]*$$param[[:space:]].*/$$param $(1)/" "$(SSH_CONFIG)"; \
		else \
			printf '\n%s %s\n' "$$param" "$(1)" | sudo tee -a "$(SSH_CONFIG)" >/dev/null; \
			echo "$$param was missing; appended to $(SSH_CONFIG)"; \
		fi; \
	done; \
	echo "Validating sshd configuration..."; \
	sudo sshd -t; \
	echo "Restarting sshd..."; \
	sudo systemctl restart sshd
endef

install-ssh ssh: ## Install OpenSSH and enable sshd
	@$(MAKE) -s -f $(THIS_MAKEFILE) update
	@sudo pacman -S --needed --noconfirm $(SSH_PACKAGE)
	@sudo systemctl enable --now sshd
	@sudo systemctl is-active sshd

ssh-password-on: ## Enable SSH password authentication
	@$(call ssh_set_password,yes,Enabling)

ssh-password-off: ## Disable SSH password authentication
	@$(call ssh_set_password,no,Disabling)
