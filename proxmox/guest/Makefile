SHELL := /bin/bash

.PHONY: help status install install-base install-tailscale tailscale-up verify
.DEFAULT_GOAL := help

THIS_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
CONFIGS_DIR := $(abspath $(THIS_DIR)/../..)
PACKAGES_MAKEFILE := $(CONFIGS_DIR)/packages/Makefile

help:
	@echo "Proxmox Linux guest"
	@echo
	@echo "  make status"
	@echo "  make install"
	@echo "  make install-base"
	@echo "  make install-tailscale"
	@echo "  make tailscale-up"
	@echo "  make verify"

status:
	@set -euo pipefail; \
	. /etc/os-release; \
	printf 'OS                 %s\n' "$${PRETTY_NAME:-$${ID:-unknown}}"; \
	systemd_available=false; \
	if command -v systemctl >/dev/null 2>&1 && systemctl show --property=Version --value >/dev/null 2>&1; then systemd_available=true; fi; \
	for row in "QEMU Guest Agent:qemu-ga:qemu-guest-agent.service" "SSH:sshd:$$(systemctl list-unit-files ssh.service --no-legend 2>/dev/null | grep -q '^ssh.service' && echo ssh.service || echo sshd.service)" "Tailscale:tailscale:tailscaled.service"; do \
		label="$${row%%:*}"; rest="$${row#*:}"; command_name="$${rest%%:*}"; service_name="$${rest#*:}"; \
		if ! command -v "$$command_name" >/dev/null 2>&1 && [[ ! -x "/usr/sbin/$$command_name" && ! -x "/sbin/$$command_name" ]]; then \
			printf '%-18s missing\n' "$$label"; \
		elif [[ "$$systemd_available" == true ]] && systemctl is-active --quiet "$$service_name"; then \
			printf '%-18s active\n' "$$label"; \
		elif [[ "$$systemd_available" != true ]]; then \
			printf '%-18s installed, service unknown\n' "$$label"; \
		else \
			printf '%-18s installed, inactive\n' "$$label"; \
		fi; \
	done; \
	if [[ -e /dev/virtio-ports/org.qemu.guest_agent.0 ]]; then printf '%-18s present\n' "QEMU agent channel"; else printf '%-18s missing (enable Agent in Proxmox, then reboot)\n' "QEMU agent channel"; fi; \
	ip=""; if command -v tailscale >/dev/null 2>&1; then ip="$$(tailscale ip -4 2>/dev/null | head -n 1 || true)"; fi; \
	if [[ -n "$$ip" ]]; then printf '%-18s %s\n' "Tailscale IPv4" "$$ip"; else printf '%-18s not authenticated\n' "Tailscale login"; fi

install: install-base install-tailscale status
	@echo "NEXT: run 'make tailscale-up', then 'make verify'."

install-base:
	@if [[ "$$(id -u)" -ne 0 ]]; then \
		sudo $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install-base; \
	elif command -v apt-get >/dev/null 2>&1; then \
		$(MAKE) --no-print-directory -f "$(PACKAGES_MAKEFILE)" install-base; \
		DEBIAN_FRONTEND=noninteractive apt-get install -y qemu-guest-agent; \
		systemctl start qemu-guest-agent.service || { echo "NOTE: QEMU Guest Agent is installed but could not start."; echo "Enable the Agent option for this VM in Proxmox and reboot it."; }; \
	elif command -v pacman >/dev/null 2>&1; then \
		$(MAKE) --no-print-directory -f "$(PACKAGES_MAKEFILE)" install-base; \
		pacman -S --needed --noconfirm qemu-guest-agent; \
		systemctl start qemu-guest-agent.service || { echo "NOTE: QEMU Guest Agent is installed but could not start."; echo "Enable the Agent option for this VM in Proxmox and reboot it."; }; \
	else \
		echo "ERROR: supported package manager not found (apt-get or pacman)" >&2; exit 1; \
	fi

install-tailscale:
	@$(MAKE) --no-print-directory -f "$(PACKAGES_MAKEFILE)" install-tailscale

tailscale-up:
	@sudo tailscale up

verify:
	@set -euo pipefail; \
	failed=0; \
	systemd_available=false; \
	if command -v systemctl >/dev/null 2>&1 && systemctl show --property=Version --value >/dev/null 2>&1; then systemd_available=true; fi; \
	ssh_service="$$(systemctl list-unit-files ssh.service --no-legend 2>/dev/null | grep -q '^ssh.service' && echo ssh.service || echo sshd.service)"; \
	for command_name in qemu-ga sshd tailscale; do \
		if command -v "$$command_name" >/dev/null 2>&1 || [[ -x "/usr/sbin/$$command_name" || -x "/sbin/$$command_name" ]]; then :; else echo "MISSING_COMMAND: $$command_name"; failed=1; fi; \
	done; \
	for service_name in qemu-guest-agent.service "$$ssh_service" tailscaled.service; do \
		if [[ "$$systemd_available" != true ]]; then echo "UNKNOWN: $$service_name"; elif systemctl is-active --quiet "$$service_name"; then echo "ACTIVE: $$service_name"; else echo "INACTIVE: $$service_name"; failed=1; fi; \
	done; \
	if [[ -e /dev/virtio-ports/org.qemu.guest_agent.0 ]]; then echo "PRESENT: QEMU agent channel"; else echo "MISSING: QEMU agent channel"; failed=1; fi; \
	if command -v tailscale >/dev/null 2>&1; then \
		ip_output="$$(tailscale ip -4 2>&1)" && { echo "CONNECTED: Tailscale ($$ip_output)"; [[ "$$failed" -eq 0 ]] || exit "$$failed"; echo "Guest bootstrap verification passed."; exit 0; }; \
		case "$$ip_output" in \
			*"operation not permitted"*|*"permission denied"*|*"Access denied"*|*"Failed to connect to local Tailscale daemon"*) echo "UNKNOWN: Tailscale local API unavailable" ;; \
			*) echo "NOT_CONNECTED: Tailscale (run 'make tailscale-up')"; failed=1 ;; \
		esac; \
	else \
		echo "MISSING_COMMAND: tailscale"; \
		failed=1; \
	fi; \
	[[ "$$failed" -eq 0 ]] || exit 1; \
	echo "Guest bootstrap verification passed."
