# System-level KVM bootstrap. Run once per machine.
# Per-VM management lives in ~/Work/KVMs/.

.DEFAULT_GOAL := help

THIS_DIR     := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
LIBVIRT_URI  := qemu:///system
NETWORK_NAME := default
NETWORK_XML  := $(THIS_DIR)/default-network.xml
USER_NAME    := $(shell id -un)
USER_GROUP   := $(shell id -gn)
SEP          := ---------------------------------------------------------------------

KVM_PACKAGES := \
	libvirt \
	qemu-full \
	virt-manager \
	edk2-ovmf \
	dnsmasq \
	swtpm

.PHONY: help setup install-kvm enable-libvirt configure-firewalld \
        configure-network configure-user configure-qemu-user status

help:
	@echo "System KVM bootstrap (run once per machine)."
	@echo
	@echo "  make setup                run everything in order"
	@echo "  make install-kvm          install pacman packages"
	@echo "  make enable-libvirt       enable modular libvirt daemons"
	@echo "  make configure-firewalld  reload firewalld so 'libvirt' zone appears"
	@echo "  make configure-network    define + start the 'default' NAT network"
	@echo "  make configure-user       add $(USER_NAME) to 'libvirt' group"
	@echo "  make configure-qemu-user  run QEMU as $(USER_NAME):$(USER_GROUP)"
	@echo "  make status               health check"
	@echo
	@echo "Per-VM management is separate: cd ~/Work/KVMs/<vm> && make ..."

setup: install-kvm enable-libvirt configure-user configure-qemu-user configure-firewalld configure-network status
	@echo "$(SEP)"
	@echo "KVM platform setup complete."

install-kvm:
	@echo "Installing KVM packages..."
	sudo pacman -S --needed --noconfirm $(KVM_PACKAGES)
	@echo "$(SEP)"

enable-libvirt:
	@echo "Enabling modular libvirt daemons (virtqemud + virtnetworkd)..."
	@echo "(Disabling legacy monolithic libvirtd if it's enabled.)"
	sudo systemctl disable --now libvirtd.socket libvirtd.service 2>/dev/null || true
	sudo systemctl enable --now virtqemud.socket virtnetworkd.socket
	@echo "$(SEP)"

configure-firewalld:
	@echo "Checking firewalld 'libvirt' zone..."
	@if command -v firewall-cmd >/dev/null 2>&1 && systemctl is-active --quiet firewalld.service; then \
	  if ! sudo firewall-cmd --get-zones | tr ' ' '\n' | grep -qx libvirt; then \
	    echo "  reloading firewalld..."; \
	    sudo firewall-cmd --reload; \
	  fi; \
	  if sudo firewall-cmd --get-zones | tr ' ' '\n' | grep -qx libvirt; then \
	    echo "  zone 'libvirt' is available."; \
	  else \
	    echo "  zone 'libvirt' is still missing. Check libvirt/firewalld packages."; \
	    exit 1; \
	  fi; \
	else \
	  echo "  firewalld is not active; skipping."; \
	fi
	@echo "$(SEP)"

configure-network:
	@echo "Configuring '$(NETWORK_NAME)' network..."
	@if ! virsh -c $(LIBVIRT_URI) net-info $(NETWORK_NAME) >/dev/null 2>&1; then \
	  echo "  defining from $(NETWORK_XML)"; \
	  sudo virsh -c $(LIBVIRT_URI) net-define "$(NETWORK_XML)"; \
	fi
	@virsh -c $(LIBVIRT_URI) net-info $(NETWORK_NAME) | grep -q 'Active:.*yes' || \
	  virsh -c $(LIBVIRT_URI) net-start $(NETWORK_NAME)
	@virsh -c $(LIBVIRT_URI) net-info $(NETWORK_NAME) | grep -q 'Autostart:.*yes' || \
	  virsh -c $(LIBVIRT_URI) net-autostart $(NETWORK_NAME)
	@echo "  '$(NETWORK_NAME)' is active and autostarts."
	@echo "$(SEP)"

configure-user:
	@if id -nG "$(USER_NAME)" | grep -qw libvirt; then \
	  echo "User $(USER_NAME) is already in 'libvirt' group."; \
	else \
	  echo "Adding $(USER_NAME) to 'libvirt' group..."; \
	  sudo usermod -aG libvirt $(USER_NAME); \
	  echo "  Run 'newgrp libvirt' or re-login to apply."; \
	fi
	@echo "$(SEP)"

configure-qemu-user:
	@echo "Configuring QEMU to run as '$(USER_NAME):$(USER_GROUP)'..."
	@current_user=$$(sudo grep -E '^\s*user\s*=' /etc/libvirt/qemu.conf | tail -n1 | sed 's/.*"\(.*\)".*/\1/'); \
	current_group=$$(sudo grep -E '^\s*group\s*=' /etc/libvirt/qemu.conf | tail -n1 | sed 's/.*"\(.*\)".*/\1/'); \
	if [ "$$current_user" = "$(USER_NAME)" ] && [ "$$current_group" = "$(USER_GROUP)" ]; then \
	  echo "  Already configured."; \
	else \
	  sudo sed -i 's/^#\?user\s*=.*/user = "$(USER_NAME)"/' /etc/libvirt/qemu.conf; \
	  sudo sed -i 's/^#\?group\s*=.*/group = "$(USER_GROUP)"/' /etc/libvirt/qemu.conf; \
	  sudo systemctl restart virtqemud.service 2>/dev/null || sudo systemctl restart libvirtd.service; \
	  echo "  Updated and virtqemud restarted."; \
	fi
	@echo "$(SEP)"

status:
	@echo "KVM Status"
	@echo "$(SEP)"
	@echo "Daemons:"
	@for unit in virtqemud.socket virtnetworkd.socket; do \
	  state=$$(systemctl is-active $$unit 2>/dev/null); \
	  printf "  %-22s %s\n" "$$unit" "$$state"; \
	done
	@echo "$(SEP)"
	@echo "Group membership:"
	@if id -nG "$(USER_NAME)" | grep -qw libvirt; then \
	  echo "  $(USER_NAME) is in 'libvirt' group."; \
	elif getent group libvirt | cut -d: -f4 | tr ',' '\n' | grep -qx "$(USER_NAME)"; then \
	  echo "  $(USER_NAME) is listed in 'libvirt' but this shell hasn't picked it up. Re-login."; \
	else \
	  echo "  $(USER_NAME) is NOT in 'libvirt' group. Run: make configure-user"; \
	fi
	@echo "$(SEP)"
	@echo "Network '$(NETWORK_NAME)':"
	@virsh -c $(LIBVIRT_URI) net-info $(NETWORK_NAME) 2>/dev/null | sed 's/^/  /' || echo "  not defined"
	@echo "$(SEP)"
	@echo "Domains:"
	@virsh -c $(LIBVIRT_URI) list --all
