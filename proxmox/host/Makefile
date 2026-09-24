SHELL := /bin/bash

.PHONY: help status install install-tailscale tailscale-up tailscale-up-key verify
.DEFAULT_GOAL := help

AUTH_KEY_FILE ?=
TS_HOSTNAME ?=
TS_ACCEPT_DNS ?= false
TS_ACCEPT_ROUTES ?= false
TS_SSH ?= false
TS_EXTRA_ARGS ?=

help:
	@echo "Proxmox host"
	@echo
	@echo "  make status"
	@echo "  make install"
	@echo "  make tailscale-up"
	@echo "  make tailscale-up-key AUTH_KEY_FILE=/path/to/key"
	@echo "  make verify"

status:
	@set -euo pipefail; \
	. /etc/os-release; \
	printf 'OS                 %s\n' "$${PRETTY_NAME:-$${ID:-unknown}}"; \
	if [[ -d /etc/pve ]] || command -v pveversion >/dev/null 2>&1; then printf '%-19s yes\n' "Proxmox host"; else printf '%-19s not detected\n' "Proxmox host"; fi; \
	mounts="$$(awk '$$2 ~ /GDATA/ || $$1 ~ /GDATA/ { print $$2 }' /proc/mounts 2>/dev/null | sort -u | paste -sd ' ' -)"; \
	if [[ -n "$$mounts" ]]; then printf '%-19s %s\n' "GDATA mounts" "$$mounts"; else printf '%-19s not detected\n' "GDATA mounts"; fi; \
	if command -v tailscale >/dev/null 2>&1; then printf '%-19s installed\n' "Tailscale"; else printf '%-19s missing\n' "Tailscale"; fi; \
	if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet tailscaled.service; then printf '%-19s active\n' "tailscaled"; else printf '%-19s inactive\n' "tailscaled"; fi; \
	ip=""; if command -v tailscale >/dev/null 2>&1; then ip="$$(tailscale ip -4 2>/dev/null | head -n 1 || true)"; fi; \
	if [[ -n "$$ip" ]]; then printf '%-19s %s\n' "Tailscale IPv4" "$$ip"; else printf '%-19s not authenticated\n' "Tailscale login"; fi

install install-tailscale:
	@if [[ "$$(id -u)" -ne 0 ]]; then \
		sudo $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-tailscale; \
	else \
		if ! command -v tailscale >/dev/null 2>&1; then \
			command -v curl >/dev/null 2>&1 || { apt-get update; DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl; }; \
			installer="$$(mktemp)"; \
			curl -fsSL https://tailscale.com/install.sh -o "$$installer"; \
			sh "$$installer"; \
			rm -f "$$installer"; \
		fi; \
		systemctl enable --now tailscaled.service; \
	fi

tailscale-up: install-tailscale
	@if [[ "$$(id -u)" -eq 0 ]]; then \
		tailscale up --accept-dns="$(TS_ACCEPT_DNS)" --accept-routes="$(TS_ACCEPT_ROUTES)" $(if $(TS_HOSTNAME),--hostname="$(TS_HOSTNAME)") $(if $(filter true yes 1 on,$(TS_SSH)),--ssh) $(TS_EXTRA_ARGS); \
	else \
		sudo tailscale up --accept-dns="$(TS_ACCEPT_DNS)" --accept-routes="$(TS_ACCEPT_ROUTES)" $(if $(TS_HOSTNAME),--hostname="$(TS_HOSTNAME)") $(if $(filter true yes 1 on,$(TS_SSH)),--ssh) $(TS_EXTRA_ARGS); \
	fi

tailscale-up-key: install-tailscale
	@test -n "$(AUTH_KEY_FILE)" || { echo "ERROR: set AUTH_KEY_FILE=/path/to/tailscale.authkey"; exit 1; }
	@test -r "$(AUTH_KEY_FILE)" || { echo "ERROR: AUTH_KEY_FILE is not readable: $(AUTH_KEY_FILE)"; exit 1; }
	@if [[ "$$(id -u)" -eq 0 ]]; then \
		auth_key="$$(sed -n '1p' "$(AUTH_KEY_FILE)" | tr -d '\r\n')"; \
		tailscale up --auth-key="$$auth_key" --accept-dns="$(TS_ACCEPT_DNS)" --accept-routes="$(TS_ACCEPT_ROUTES)" $(if $(TS_HOSTNAME),--hostname="$(TS_HOSTNAME)") $(if $(filter true yes 1 on,$(TS_SSH)),--ssh) $(TS_EXTRA_ARGS); \
	else \
		auth_key="$$(sed -n '1p' "$(AUTH_KEY_FILE)" | tr -d '\r\n')"; \
		sudo tailscale up --auth-key="$$auth_key" --accept-dns="$(TS_ACCEPT_DNS)" --accept-routes="$(TS_ACCEPT_ROUTES)" $(if $(TS_HOSTNAME),--hostname="$(TS_HOSTNAME)") $(if $(filter true yes 1 on,$(TS_SSH)),--ssh) $(TS_EXTRA_ARGS); \
	fi

verify:
	@set -euo pipefail; \
	failed=0; \
	if command -v tailscale >/dev/null 2>&1; then echo "PRESENT: tailscale"; else echo "MISSING: tailscale"; failed=1; fi; \
	if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet tailscaled.service; then echo "ACTIVE: tailscaled.service"; else echo "INACTIVE: tailscaled.service"; failed=1; fi; \
	ip=""; if command -v tailscale >/dev/null 2>&1; then ip="$$(tailscale ip -4 2>/dev/null | head -n 1 || true)"; fi; \
	if [[ -n "$$ip" ]]; then echo "CONNECTED: Tailscale ($$ip)"; else echo "NOT_CONNECTED: Tailscale"; failed=1; fi; \
	[[ "$$failed" -eq 0 ]] || exit 1; \
	echo "Proxmox host Tailscale verification passed."
