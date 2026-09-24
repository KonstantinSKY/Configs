SHELL := /bin/bash

.PHONY: help status install install-packages user verify \
	control-status control-install control-install-packages control-user control-verify \
	host-status host-install host-tailscale-up host-tailscale-up-key host-verify \
	guest-status guest-install guest-install-base guest-install-tailscale guest-tailscale-up guest-verify
.DEFAULT_GOAL := help

THIS_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
CONTROL_MAKEFILE := $(THIS_DIR)/control/Makefile
HOST_MAKEFILE := $(THIS_DIR)/host/Makefile
GUEST_MAKEFILE := $(THIS_DIR)/guest/Makefile

ADMIN_USER ?= sky
ADMIN_SHELL ?= /bin/bash
SSH_AUTHORIZED_KEYS_FILE ?=
SUDO_NOPASSWD ?= false

help: ## Show available commands
	@echo "Proxmox workspace"
	@echo
	@echo "Control node, run on the Debian/Proxmox machine used to manage VMs:"
	@echo "  make status                 inspect OS, admin user, and tools"
	@echo "  make install                create/update admin user and install tools"
	@echo "  make install-packages       install the minimal admin toolset"
	@echo "  make user                   create/update ADMIN_USER and optional SSH key"
	@echo "  make verify                 verify the expected user and commands"
	@echo
	@echo "Proxmox host:"
	@echo "  make host-status"
	@echo "  make host-install"
	@echo "  make host-tailscale-up"
	@echo "  make host-tailscale-up-key AUTH_KEY_FILE=/path/to/key"
	@echo "  make host-verify"
	@echo
	@echo "Linux guest VM:"
	@echo "  make guest-status"
	@echo "  make guest-install"
	@echo "  make guest-install-base"
	@echo "  make guest-install-tailscale"
	@echo "  make guest-tailscale-up"
	@echo "  make guest-verify"
	@echo
	@echo "Variables:"
	@echo "  ADMIN_USER=sky"
	@echo "  ADMIN_SHELL=/bin/bash"
	@echo "  SSH_AUTHORIZED_KEYS_FILE=/root/sky.authorized_keys"
	@echo "  SUDO_NOPASSWD=false"

status:
	@$(MAKE) --no-print-directory -f "$(CONTROL_MAKEFILE)" status \
		ADMIN_USER="$(ADMIN_USER)"

control-status: status

install:
	@$(MAKE) --no-print-directory -f "$(CONTROL_MAKEFILE)" install \
		ADMIN_USER="$(ADMIN_USER)" \
		ADMIN_SHELL="$(ADMIN_SHELL)" \
		SSH_AUTHORIZED_KEYS_FILE="$(SSH_AUTHORIZED_KEYS_FILE)" \
		SUDO_NOPASSWD="$(SUDO_NOPASSWD)"

control-install: install

install-packages:
	@$(MAKE) --no-print-directory -f "$(CONTROL_MAKEFILE)" install-packages

control-install-packages: install-packages

user:
	@$(MAKE) --no-print-directory -f "$(CONTROL_MAKEFILE)" user \
		ADMIN_USER="$(ADMIN_USER)" \
		ADMIN_SHELL="$(ADMIN_SHELL)" \
		SSH_AUTHORIZED_KEYS_FILE="$(SSH_AUTHORIZED_KEYS_FILE)" \
		SUDO_NOPASSWD="$(SUDO_NOPASSWD)"

control-user: user

verify:
	@$(MAKE) --no-print-directory -f "$(CONTROL_MAKEFILE)" verify \
		ADMIN_USER="$(ADMIN_USER)"

control-verify: verify

host-status:
	@$(MAKE) --no-print-directory -f "$(HOST_MAKEFILE)" status

host-install:
	@$(MAKE) --no-print-directory -f "$(HOST_MAKEFILE)" install

host-tailscale-up:
	@$(MAKE) --no-print-directory -f "$(HOST_MAKEFILE)" tailscale-up

host-tailscale-up-key:
	@$(MAKE) --no-print-directory -f "$(HOST_MAKEFILE)" tailscale-up-key \
		AUTH_KEY_FILE="$(AUTH_KEY_FILE)" \
		TS_HOSTNAME="$(TS_HOSTNAME)" \
		TS_ACCEPT_DNS="$(TS_ACCEPT_DNS)" \
		TS_ACCEPT_ROUTES="$(TS_ACCEPT_ROUTES)" \
		TS_SSH="$(TS_SSH)" \
		TS_EXTRA_ARGS="$(TS_EXTRA_ARGS)"

host-verify:
	@$(MAKE) --no-print-directory -f "$(HOST_MAKEFILE)" verify

guest-status:
	@$(MAKE) --no-print-directory -f "$(GUEST_MAKEFILE)" status

guest-install:
	@$(MAKE) --no-print-directory -f "$(GUEST_MAKEFILE)" install

guest-install-base:
	@$(MAKE) --no-print-directory -f "$(GUEST_MAKEFILE)" install-base

guest-install-tailscale:
	@$(MAKE) --no-print-directory -f "$(GUEST_MAKEFILE)" install-tailscale

guest-tailscale-up:
	@$(MAKE) --no-print-directory -f "$(GUEST_MAKEFILE)" tailscale-up

guest-verify:
	@$(MAKE) --no-print-directory -f "$(GUEST_MAKEFILE)" verify
