.PHONY: \
	help \
	setup \
	install-kvm \
	enable-libvirtd \
	configure-network \
	configure-user \
	status s \
	backup \
	check-running

.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

SEPARATOR := ---------------------------------------------------------------------

KVM_ROOT     := $(HOME)/Work/KVMs
REMOTE       := gdrive:KVM_Backups
LIBVIRT_URI  := qemu:///system
NETWORK_NAME := default

KVM_PACKAGES = \
	libvirt \
	qemu-full \
	virt-manager \
	edk2-ovmf \
	dnsmasq \
	swtpm

## ---------------------------
## 🧩 KVM Platform Setup
## ---------------------------

setup: ## Install KVM packages, enable libvirtd, configure network and user group
	@$(MAKE) -s -f $(THIS_MAKEFILE) install-kvm
	@$(MAKE) -s -f $(THIS_MAKEFILE) enable-libvirtd
	@$(MAKE) -s -f $(THIS_MAKEFILE) configure-network
	@$(MAKE) -s -f $(THIS_MAKEFILE) configure-user
	@echo "$(SEPARATOR)"
	@$(MAKE) -s -f $(THIS_MAKEFILE) status
	@echo "✅ KVM platform setup complete."

install-kvm: ## Install KVM/QEMU/libvirt packages
	@echo "📦 Installing KVM packages..."
	@sudo pacman -S --needed --noconfirm $(KVM_PACKAGES)
	@echo "✅ KVM packages installed."
	@echo "$(SEPARATOR)"

enable-libvirtd: ## Enable and start libvirtd and virtnetworkd services
	@echo "🔧 Enabling libvirtd..."
	@sudo systemctl enable --now libvirtd.service
	@sudo systemctl is-active libvirtd.service
	@echo "🔧 Enabling virtnetworkd (required for bridge networking in libvirt 12+)..."
	@sudo systemctl enable --now virtnetworkd.service
	@sudo systemctl is-active virtnetworkd.service
	@echo "🔧 Loading bridge kernel module..."
	@sudo modprobe bridge
	@echo "$(SEPARATOR)"

configure-network: ## Ensure the default libvirt network is active and set to autostart
	@echo "🌐 Configuring default libvirt network..."
	@if virsh --connect $(LIBVIRT_URI) net-info $(NETWORK_NAME) >/dev/null 2>&1; then \
		virsh --connect $(LIBVIRT_URI) net-autostart $(NETWORK_NAME) 2>/dev/null || true; \
		if ! virsh --connect $(LIBVIRT_URI) net-info $(NETWORK_NAME) 2>/dev/null | grep -q 'Active:.*yes'; then \
			virsh --connect $(LIBVIRT_URI) net-start $(NETWORK_NAME); \
		fi; \
		echo "✅ Network '$(NETWORK_NAME)' is active and set to autostart."; \
	else \
		echo "❌ Network '$(NETWORK_NAME)' not found. Define it first via virt-manager or virsh."; \
		exit 1; \
	fi
	@echo "$(SEPARATOR)"

configure-user: ## Add current user to libvirt group
	@echo "👤 Adding user '$(USER)' to 'libvirt' group..."
	@sudo usermod -aG libvirt $(USER)
	@echo "✅ User '$(USER)' added to libvirt group."
	@echo "⚠️  Run 'newgrp libvirt' or reboot to apply group changes."
	@echo "$(SEPARATOR)"

## ---------------------------
## 📊 Status
## ---------------------------

status s: ## Show KVM/libvirt status overview
	@echo "KVM Status"
	@echo "$(SEPARATOR)"
	@echo "🔍 libvirtd service:"
	@systemctl is-enabled libvirtd.service 2>/dev/null || true
	@systemctl is-active libvirtd.service 2>/dev/null || true
	@echo "$(SEPARATOR)"
	@echo "👤 Group membership:"
	@if id -nG "$(USER)" | grep -qw libvirt; then \
		echo "  ✅ $(USER) is in the 'libvirt' group"; \
	else \
		echo "  ❌ $(USER) is NOT in the 'libvirt' group"; \
	fi
	@echo "$(SEPARATOR)"
	@echo "🌐 Networks:"
	@virsh --connect $(LIBVIRT_URI) net-list --all 2>/dev/null || echo "  (virsh not available)"
	@echo "$(SEPARATOR)"
	@echo "🖥️  Domains:"
	@virsh --connect $(LIBVIRT_URI) list --all 2>/dev/null || echo "  (virsh not available)"

## ---------------------------
## 💾 Backup
## ---------------------------

backup: check-running ## Back up all KVM data (ISOs, XMLs, NVRAM, disks) to cloud via rclone
	@echo "=== STARTING FULL KVM BACKUP ==="
	@echo "--> [1/4] Syncing ISOs..."
	@rclone copy "$(KVM_ROOT)/isos" "$(REMOTE)/isos" -P
	@echo "--> [2/4] Saving and uploading XML configs..."
	@mkdir -p "$(THIS_DIR)/.backup-xmls"
	@for domain in $$(virsh --connect $(LIBVIRT_URI) list --all --name); do \
		if [ -n "$$domain" ]; then \
			virsh --connect $(LIBVIRT_URI) dumpxml --inactive "$$domain" > "$(THIS_DIR)/.backup-xmls/$$domain.xml"; \
			echo "   Saved: $$domain"; \
		fi \
	done
	@rclone copy "$(THIS_DIR)/.backup-xmls" "$(REMOTE)/xmls" -P
	@rm -rf "$(THIS_DIR)/.backup-xmls"
	@echo "--> [3/4] Backing up NVRAM..."
	@rclone copy "$(KVM_ROOT)/nvram" "$(REMOTE)/nvram" -P
	@echo "--> [4/4] Backing up disks..."
	@rclone copy "$(KVM_ROOT)/disks" "$(REMOTE)/disks" -P
	@echo "=== BACKUP COMPLETED ==="

check-running: ## Ensure all VMs are stopped before backup
	@if [ -n "$$(virsh --connect $(LIBVIRT_URI) list --name --state-running 2>/dev/null)" ]; then \
		echo "❌ ERROR: The following VMs are currently RUNNING:"; \
		virsh --connect $(LIBVIRT_URI) list --state-running; \
		echo "⚠️  Please shutdown ALL VMs before backup to prevent corruption."; \
		exit 1; \
	else \
		echo "✅ All VMs are offline. Proceeding..."; \
	fi
