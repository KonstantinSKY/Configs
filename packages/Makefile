SHELL := /bin/bash

.PHONY: help status detect install-base install-base-arch install-base-debian install-tailscale install-tailscale-arch install-tailscale-debian verify-base verify-tailscale
.DEFAULT_GOAL := help

BASE_PACKAGES_ARCH := \
	ca-certificates \
	curl \
	git \
	make \
	openssh

BASE_PACKAGES_DEBIAN := \
	ca-certificates \
	curl \
	git \
	make \
	openssh-client \
	openssh-server

help: ## Show package bootstrap commands
	@echo "Public package bootstrap"
	@echo
	@echo "  make status    detect supported package family"
	@echo "  make detect    print OS and package family"
	@echo "  make install-base"
	@echo "  make install-tailscale"
	@echo "  make verify-base"
	@echo "  make verify-tailscale"

status: detect ## Detect supported package family

detect: ## Print OS and package family without changes
	@set -euo pipefail; \
	if [[ "$$(uname -s)" != Linux ]]; then \
		echo "OS: $$(uname -s)"; \
		echo "PACKAGE_FAMILY: unsupported"; \
		exit 0; \
	fi; \
	. /etc/os-release; \
	family=unsupported; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) family=arch ;; \
		*' debian '*|*' ubuntu '*) family=debian ;; \
	esac; \
	echo "OS: Linux"; \
	echo "DISTRO: $${ID:-unknown}"; \
	echo "DISTRO_LIKE: $${ID_LIKE:-none}"; \
	echo "PACKAGE_FAMILY: $$family"

install-base: ## Install public base packages for the detected package family
	@set -euo pipefail; \
	. /etc/os-release; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-base-arch ;; \
		*' debian '*|*' ubuntu '*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-base-debian ;; \
		*) echo "ERROR: unsupported package family: ID=$${ID:-unknown} ID_LIKE=$${ID_LIKE:-none}"; exit 1 ;; \
	esac

install-base-arch: ## Install public base packages on Arch-like systems
	@set -euo pipefail; \
	command -v pacman >/dev/null 2>&1 || { echo "ERROR: pacman is required"; exit 1; }; \
	sudo pacman -S --needed --noconfirm $(BASE_PACKAGES_ARCH); \
	sudo systemctl enable --now sshd.service

install-base-debian: ## Install public base packages on Debian/Ubuntu systems
	@set -euo pipefail; \
	command -v apt-get >/dev/null 2>&1 || { echo "ERROR: apt-get is required"; exit 1; }; \
	sudo apt-get update; \
	sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $(BASE_PACKAGES_DEBIAN); \
	ssh_service="$$(systemctl list-unit-files ssh.service --no-legend 2>/dev/null | grep -q '^ssh.service' && echo ssh.service || echo sshd.service)"; \
	sudo systemctl enable --now "$$ssh_service"

install-tailscale: ## Install and enable Tailscale for the detected package family
	@set -euo pipefail; \
	. /etc/os-release; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' endeavouros '*|*' arch '*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-tailscale-arch ;; \
		*' debian '*|*' ubuntu '*) $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-tailscale-debian ;; \
		*) echo "ERROR: unsupported package family: ID=$${ID:-unknown} ID_LIKE=$${ID_LIKE:-none}"; exit 1 ;; \
	esac

install-tailscale-arch: ## Install and enable Tailscale on Arch-like systems
	@set -euo pipefail; \
	command -v pacman >/dev/null 2>&1 || { echo "ERROR: pacman is required"; exit 1; }; \
	sudo pacman -S --needed --noconfirm tailscale; \
	sudo systemctl enable --now tailscaled.service

install-tailscale-debian: ## Install and enable Tailscale on Debian/Ubuntu systems
	@set -euo pipefail; \
	if command -v tailscale >/dev/null 2>&1; then \
		sudo systemctl enable --now tailscaled.service; \
	else \
		command -v curl >/dev/null 2>&1 || { sudo apt-get update; sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl; }; \
		installer="$$(mktemp)"; \
		curl -fsSL https://tailscale.com/install.sh -o "$$installer"; \
		sudo sh "$$installer"; \
		rm -f "$$installer"; \
		sudo systemctl enable --now tailscaled.service; \
	fi

verify-base: ## Verify public base commands and SSH service without changes
	@set -euo pipefail; \
	failed=0; \
	for command_name in curl git make ssh sshd; do \
		if command -v "$$command_name" >/dev/null 2>&1 || [[ -x "/usr/sbin/$$command_name" || -x "/sbin/$$command_name" ]]; then \
			echo "OK: $$command_name"; \
		else \
			echo "MISSING: $$command_name"; \
			failed=1; \
		fi; \
	done; \
	ssh_service="$$(systemctl list-unit-files ssh.service --no-legend 2>/dev/null | grep -q '^ssh.service' && echo ssh.service || echo sshd.service)"; \
	if ! command -v systemctl >/dev/null 2>&1; then \
		echo "UNKNOWN: systemctl unavailable"; \
	elif ! systemctl show --property=Version --value >/dev/null 2>&1; then \
		echo "UNKNOWN: systemd system bus unavailable"; \
	elif systemctl is-active --quiet "$$ssh_service"; then \
		echo "ACTIVE: $$ssh_service"; \
	else \
		echo "INACTIVE: $$ssh_service"; \
		failed=1; \
	fi; \
	exit "$$failed"

verify-tailscale: ## Verify Tailscale command, service, and login without changes
	@set -euo pipefail; \
	failed=0; \
	if command -v tailscale >/dev/null 2>&1; then \
		echo "OK: tailscale"; \
	else \
		echo "MISSING: tailscale"; \
		failed=1; \
	fi; \
	if ! command -v systemctl >/dev/null 2>&1; then \
		echo "UNKNOWN: systemctl unavailable"; \
	elif ! systemctl show --property=Version --value >/dev/null 2>&1; then \
		echo "UNKNOWN: systemd system bus unavailable"; \
	elif systemctl is-active --quiet tailscaled.service; then \
		echo "ACTIVE: tailscaled.service"; \
	else \
		echo "INACTIVE: tailscaled.service"; \
		failed=1; \
	fi; \
	if command -v tailscale >/dev/null 2>&1; then \
		ip_output="$$(tailscale ip -4 2>&1)" && { echo "CONNECTED: Tailscale ($$ip_output)"; exit "$$failed"; }; \
		case "$$ip_output" in \
			*"operation not permitted"*|*"permission denied"*|*"Access denied"*|*"Failed to connect to local Tailscale daemon"*) \
				echo "UNKNOWN: Tailscale local API unavailable";; \
			*) \
				echo "NOT_CONNECTED: Tailscale"; \
				failed=1;; \
		esac; \
	fi; \
	exit "$$failed"
