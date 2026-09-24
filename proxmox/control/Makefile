SHELL := /bin/bash

.PHONY: help status install install-packages user verify
.DEFAULT_GOAL := help

ADMIN_USER ?= sky
ADMIN_SHELL ?= /bin/bash
SSH_AUTHORIZED_KEYS_FILE ?=
SUDO_NOPASSWD ?= false

PACKAGES := \
	ca-certificates \
	curl \
	file \
	gh \
	git \
	gnupg \
	jq \
	less \
	make \
	neovim \
	openssh-client \
	openssh-server \
	pass \
	qemu-utils \
	rclone \
	ripgrep \
	rsync \
	sudo \
	tmux \
	tree \
	unzip \
	wget \
	zip

help:
	@echo "Proxmox control node"
	@echo
	@echo "  make status"
	@echo "  make install"
	@echo "  make install-packages"
	@echo "  make user"
	@echo "  make verify"

status:
	@set -euo pipefail; \
	. /etc/os-release; \
	printf '%-22s %s\n' "OS" "$${PRETTY_NAME:-$${ID:-unknown}}"; \
	if [[ -d /etc/pve ]] || command -v pveversion >/dev/null 2>&1; then \
		printf '%-22s yes\n' "Proxmox host"; \
	else \
		printf '%-22s not detected\n' "Proxmox host"; \
	fi; \
	if command -v apt-get >/dev/null 2>&1; then \
		printf '%-22s present\n' "apt-get"; \
	else \
		printf '%-22s missing\n' "apt-get"; \
	fi; \
	if getent passwd "$(ADMIN_USER)" >/dev/null; then \
		home="$$(getent passwd "$(ADMIN_USER)" | cut -d: -f6)"; \
		printf '%-22s present (%s)\n' "Admin user" "$$home"; \
		if id -nG "$(ADMIN_USER)" 2>/dev/null | tr ' ' '\n' | grep -qx sudo; then \
			printf '%-22s yes\n' "Sudo group"; \
		else \
			printf '%-22s no\n' "Sudo group"; \
		fi; \
	else \
		printf '%-22s missing\n' "Admin user"; \
	fi; \
	missing=""; \
	for command_name in gh git gpg pass make tmux nvim curl wget rg rclone rsync jq tree file unzip zip qemu-img ssh sshd; do \
		if ! command -v "$$command_name" >/dev/null 2>&1 && [[ ! -x "/usr/sbin/$$command_name" && ! -x "/sbin/$$command_name" ]]; then \
			missing="$$missing $$command_name"; \
		fi; \
	done; \
	if [[ -n "$$missing" ]]; then \
		printf '%-22s%s\n' "Missing tools" "$$missing"; \
	else \
		printf '%-22s ready\n' "Toolset"; \
	fi

install: user install-packages status

install-packages:
	@if [[ "$$(id -u)" -eq 0 ]]; then \
		apt-get update; \
		DEBIAN_FRONTEND=noninteractive apt-get install -y $(PACKAGES); \
		if command -v systemctl >/dev/null 2>&1; then \
			systemctl enable --now ssh.service 2>/dev/null || systemctl enable --now sshd.service 2>/dev/null || true; \
		fi; \
	else \
		sudo apt-get update; \
		sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $(PACKAGES); \
		if command -v systemctl >/dev/null 2>&1; then \
			sudo systemctl enable --now ssh.service 2>/dev/null || sudo systemctl enable --now sshd.service 2>/dev/null || true; \
		fi; \
	fi

user:
	@if [[ "$$(id -u)" -eq 0 ]]; then \
		if ! getent group sudo >/dev/null; then echo "ERROR: sudo group is missing" >&2; exit 1; fi; \
		if [[ ! -x "$(ADMIN_SHELL)" ]]; then echo "ERROR: ADMIN_SHELL is not executable: $(ADMIN_SHELL)" >&2; exit 1; fi; \
		if getent passwd "$(ADMIN_USER)" >/dev/null; then \
			usermod -s "$(ADMIN_SHELL)" "$(ADMIN_USER)"; \
			echo "Updated existing user: $(ADMIN_USER)"; \
		else \
			useradd -m -s "$(ADMIN_SHELL)" -G sudo "$(ADMIN_USER)"; \
			echo "Created user: $(ADMIN_USER)"; \
		fi; \
		if ! id -nG "$(ADMIN_USER)" 2>/dev/null | tr ' ' '\n' | grep -qx sudo; then \
			usermod -aG sudo "$(ADMIN_USER)"; \
			echo "Added $(ADMIN_USER) to sudo group."; \
		fi; \
		if [[ -n "$(SSH_AUTHORIZED_KEYS_FILE)" ]]; then \
			if [[ ! -r "$(SSH_AUTHORIZED_KEYS_FILE)" ]]; then echo "ERROR: SSH_AUTHORIZED_KEYS_FILE is not readable: $(SSH_AUTHORIZED_KEYS_FILE)" >&2; exit 1; fi; \
			home="$$(getent passwd "$(ADMIN_USER)" | cut -d: -f6)"; \
			install -d -m 700 -o "$(ADMIN_USER)" -g "$(ADMIN_USER)" "$$home/.ssh"; \
			install -m 600 -o "$(ADMIN_USER)" -g "$(ADMIN_USER)" "$(SSH_AUTHORIZED_KEYS_FILE)" "$$home/.ssh/authorized_keys"; \
			echo "Installed SSH authorized_keys for $(ADMIN_USER)."; \
		fi; \
		sudoers_file="/etc/sudoers.d/90-$(ADMIN_USER)"; \
		case "$(SUDO_NOPASSWD)" in \
			1|yes|true|on) printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$(ADMIN_USER)" > "$$sudoers_file"; chmod 440 "$$sudoers_file"; echo "Enabled passwordless sudo for $(ADMIN_USER)." ;; \
			*) if [[ -f "$$sudoers_file" ]]; then rm -f "$$sudoers_file"; echo "Removed passwordless sudo override for $(ADMIN_USER)."; fi ;; \
		esac; \
	else \
		sudo ADMIN_USER="$(ADMIN_USER)" ADMIN_SHELL="$(ADMIN_SHELL)" SSH_AUTHORIZED_KEYS_FILE="$(SSH_AUTHORIZED_KEYS_FILE)" SUDO_NOPASSWD="$(SUDO_NOPASSWD)" \
			$(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" user; \
	fi

verify:
	@set -euo pipefail; \
	failed=0; \
	if getent passwd "$(ADMIN_USER)" >/dev/null; then echo "PRESENT: user $(ADMIN_USER)"; else echo "MISSING: user $(ADMIN_USER)"; failed=1; fi; \
	if getent passwd "$(ADMIN_USER)" >/dev/null && id -nG "$(ADMIN_USER)" 2>/dev/null | tr ' ' '\n' | grep -qx sudo; then echo "PRESENT: $(ADMIN_USER) in sudo group"; else echo "MISSING: $(ADMIN_USER) in sudo group"; failed=1; fi; \
	for command_name in gh git gpg pass make tmux nvim curl wget rg rclone rsync jq tree file unzip zip qemu-img ssh sshd; do \
		if command -v "$$command_name" >/dev/null 2>&1 || [[ -x "/usr/sbin/$$command_name" || -x "/sbin/$$command_name" ]]; then \
			echo "PRESENT: $$command_name"; \
		else \
			echo "MISSING: $$command_name"; failed=1; \
		fi; \
	done; \
	[[ "$$failed" -eq 0 ]] || exit 1; \
	echo "Proxmox control-node verification passed."
