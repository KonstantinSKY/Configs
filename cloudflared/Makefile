SHELL := /bin/bash

.PHONY: help install i verify v
.DEFAULT_GOAL := help

SUDO := $(shell if [ "$$(id -u)" -eq 0 ]; then echo ""; else echo "sudo"; fi)

help: ## Show Cloudflare Tunnel client commands
	@echo "Cloudflare Tunnel client"
	@echo
	@echo "  make install"
	@echo "  make verify"

install i: ## Install cloudflared from Cloudflare's apt repository
	@set -euo pipefail; \
	if [[ ! -r /etc/os-release ]]; then \
		echo "ERROR: /etc/os-release is required"; \
		exit 1; \
	fi; \
	. /etc/os-release; \
	case " $${ID:-} $${ID_LIKE:-} " in \
		*' debian '*|*' ubuntu '*) ;; \
		*) echo "ERROR: cloudflared install is currently mapped only for Debian/Ubuntu."; echo "DISTRO: $${ID:-unknown}"; echo "DISTRO_LIKE: $${ID_LIKE:-none}"; exit 1 ;; \
	esac; \
	command -v apt-get >/dev/null 2>&1 || { echo "ERROR: apt-get is required"; exit 1; }; \
	if command -v cloudflared >/dev/null 2>&1; then \
		cloudflared --version; \
		exit 0; \
	fi; \
	command -v curl >/dev/null 2>&1 || { $(SUDO) apt-get update; $(SUDO) DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl; }; \
	$(SUDO) install -d -m 0755 /usr/share/keyrings; \
	curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | $(SUDO) tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null; \
	echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | $(SUDO) tee /etc/apt/sources.list.d/cloudflared.list >/dev/null; \
	$(SUDO) apt-get update; \
	$(SUDO) DEBIAN_FRONTEND=noninteractive apt-get install -y cloudflared; \
	cloudflared --version

verify v: ## Verify cloudflared without changing the system
	@set -euo pipefail; \
	if command -v cloudflared >/dev/null 2>&1; then \
		cloudflared --version; \
	else \
		echo "MISSING: cloudflared"; \
		exit 1; \
	fi
