.PHONY: \
	help \
	h \
	setup \
	install-kvm \
	enable-libvirtd \
	configure-firewalld \
	configure-network \
	configure-user \
	configure-qemu-user \
	list-domain-xmls \
	define-repo-domains \
	define-kvm-domains \
	define-domains \
	import-domains \
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
DEFAULT_NETWORK_XML := $(THIS_DIR)/default-network.xml
REPO_DOMAIN_XMLS := $(wildcard $(THIS_DIR)/*/domain.xml)
CURRENT_USER := $(shell id -un)
CURRENT_GROUP := $(shell id -gn)

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

setup: ## Run install-kvm, enable-libvirtd, configure-user, configure-qemu-user, configure-network, then status
	@$(MAKE) -s -f $(THIS_MAKEFILE) install-kvm
	@$(MAKE) -s -f $(THIS_MAKEFILE) enable-libvirtd
	@$(MAKE) -s -f $(THIS_MAKEFILE) configure-user
	@$(MAKE) -s -f $(THIS_MAKEFILE) configure-qemu-user
	@$(MAKE) -s -f $(THIS_MAKEFILE) configure-network
	@$(MAKE) -s -f $(THIS_MAKEFILE) status
	@echo "✅ KVM platform setup complete."

install-kvm: ## Install KVM/QEMU/libvirt packages
	@echo "📦 Installing KVM packages..."
	@sudo pacman -S --needed --noconfirm $(KVM_PACKAGES)
	@echo "✅ KVM packages installed."
	@echo "$(SEPARATOR)"

enable-libvirtd: ## Enable and start libvirtd plus virtnetworkd services
	@echo "🔧 Enabling libvirtd..."
	@sudo systemctl enable --now libvirtd.service
	@sudo systemctl is-active libvirtd.service
	@echo "🔧 Enabling virtnetworkd (required for libvirt virtual networks in libvirt 12+)..."
	@sudo systemctl enable --now virtnetworkd.service
	@sudo systemctl is-active virtnetworkd.service
	@echo "$(SEPARATOR)"

configure-firewalld: ## Reload firewalld when needed so the packaged libvirt zone is available
	@echo "🔥 Checking firewalld libvirt zone..."
	@if command -v firewall-cmd >/dev/null 2>&1 && systemctl is-active --quiet firewalld.service; then \
		if ! sudo firewall-cmd --get-zones | tr ' ' '\n' | grep -qx libvirt; then \
			echo "ℹ️  Reloading firewalld so it picks up the packaged 'libvirt' zone..."; \
			sudo firewall-cmd --reload; \
		fi; \
		if sudo firewall-cmd --get-zones | tr ' ' '\n' | grep -qx libvirt; then \
			echo "✅ firewalld zone 'libvirt' is available."; \
		else \
			echo "❌ firewalld zone 'libvirt' is still missing."; \
			echo "ℹ️  Reinstall libvirt/firewalld packages or check /usr/lib/firewalld/zones/libvirt.xml."; \
			exit 1; \
		fi; \
	else \
		echo "ℹ️  firewalld is not active; skipping firewalld zone check."; \
	fi
	@echo "$(SEPARATOR)"

configure-network: configure-firewalld ## Ensure the default libvirt network is active and set to autostart
	@echo "🌐 Configuring default libvirt network..."
	@if ! sudo virsh --connect $(LIBVIRT_URI) net-info $(NETWORK_NAME) >/dev/null 2>&1; then \
		echo "ℹ️  Network '$(NETWORK_NAME)' not found. Defining it from $(DEFAULT_NETWORK_XML)..."; \
		sudo virsh --connect $(LIBVIRT_URI) net-define "$(DEFAULT_NETWORK_XML)"; \
	fi; \
	sudo virsh --connect $(LIBVIRT_URI) net-autostart $(NETWORK_NAME) 2>/dev/null || true; \
	if ! sudo virsh --connect $(LIBVIRT_URI) net-info $(NETWORK_NAME) 2>/dev/null | grep -q 'Active:.*yes'; then \
		sudo virsh --connect $(LIBVIRT_URI) net-start $(NETWORK_NAME); \
	fi
	@echo "✅ Network '$(NETWORK_NAME)' is active and set to autostart."
	@echo "$(SEPARATOR)"

configure-qemu-user: ## Set libvirt QEMU user and primary group in /etc/libvirt/qemu.conf
	@echo "⚙️  Configuring QEMU to run as '$(CURRENT_USER):$(CURRENT_GROUP)'..."
	@sudo sed -i 's/^#\?user\s*=.*/user = "$(CURRENT_USER)"/' /etc/libvirt/qemu.conf
	@sudo sed -i 's/^#\?group\s*=.*/group = "$(CURRENT_GROUP)"/' /etc/libvirt/qemu.conf
	@sudo systemctl restart libvirtd.service
	@echo "✅ QEMU will now run as '$(CURRENT_USER):$(CURRENT_GROUP)'. libvirtd restarted."
	@echo "$(SEPARATOR)"

configure-user: ## Add current user to libvirt group
	@echo "👤 Adding user '$(CURRENT_USER)' to 'libvirt' group..."
	@sudo usermod -aG libvirt $(CURRENT_USER)
	@echo "✅ User '$(CURRENT_USER)' added to libvirt group."
	@echo "⚠️  Run 'newgrp libvirt' or reboot to apply group changes."
	@echo "$(SEPARATOR)"

## ---------------------------
## 🖥️  Domain Registration
## ---------------------------

list-domain-xmls: ## List VM XML files that can be registered
	@echo "Domain XML files"
	@echo "$(SEPARATOR)"
	@echo "Config repo:"
	@if [ -n "$(REPO_DOMAIN_XMLS)" ]; then \
		for xml in $(REPO_DOMAIN_XMLS); do echo "  $$xml"; done; \
	else \
		echo "  (none found)"; \
	fi
	@echo "KVM root ($(KVM_ROOT)):"
	@if [ -d "$(KVM_ROOT)" ]; then \
		domain_xmls="$$(find "$(KVM_ROOT)" -maxdepth 2 -type f -name '*.xml' | sort)"; \
		if [ -n "$$domain_xmls" ]; then \
			printf '%s\n' "$$domain_xmls" | while IFS= read -r xml; do \
			echo "  $$xml"; \
			done; \
		else \
			echo "  (none found)"; \
		fi; \
	else \
		echo "  (directory not found)"; \
	fi

define-repo-domains: ## Register VM domains from this config repository
	@echo "🖥️  Registering repo domains in $(LIBVIRT_URI)..."
	@if [ -z "$(REPO_DOMAIN_XMLS)" ]; then \
		echo "  (no domain.xml files found under $(THIS_DIR))"; \
	else \
		for xml in $(REPO_DOMAIN_XMLS); do \
			name="$$(sed -n 's/.*<name>\(.*\)<\/name>.*/\1/p' "$$xml" | head -n 1)"; \
			if [ -n "$$name" ] && sudo virsh --connect $(LIBVIRT_URI) dominfo "$$name" >/dev/null 2>&1; then \
				echo "  skip $$xml ($$name already registered)"; \
			else \
				echo "  define $$xml"; \
				sudo virsh --connect $(LIBVIRT_URI) define "$$xml"; \
			fi; \
		done; \
	fi
	@echo "$(SEPARATOR)"

define-kvm-domains: ## Register VM domains from XML files under ~/Work/KVMs
	@echo "🖥️  Registering KVM root domains in $(LIBVIRT_URI)..."
	@if [ ! -d "$(KVM_ROOT)" ]; then \
		echo "  ❌ $(KVM_ROOT) does not exist"; \
		exit 1; \
	fi
	@domain_xmls="$$(find "$(KVM_ROOT)" -maxdepth 2 -type f -name '*.xml' | sort)"; \
	if [ -z "$$domain_xmls" ]; then \
		echo "  (no XML files found under $(KVM_ROOT))"; \
	else \
		printf '%s\n' "$$domain_xmls" | while IFS= read -r xml; do \
			name="$$(sed -n 's/.*<name>\(.*\)<\/name>.*/\1/p' "$$xml" | head -n 1)"; \
			if [ -n "$$name" ] && sudo virsh --connect $(LIBVIRT_URI) dominfo "$$name" >/dev/null 2>&1; then \
				echo "  skip $$xml ($$name already registered)"; \
			else \
				echo "  define $$xml"; \
				sudo virsh --connect $(LIBVIRT_URI) define "$$xml"; \
			fi; \
		done; \
	fi
	@echo "$(SEPARATOR)"

define-domains import-domains: define-kvm-domains define-repo-domains ## Register all known VM domain XML files, then show status
	@$(MAKE) -s -f $(THIS_MAKEFILE) status

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
	@if id -nG "$(CURRENT_USER)" | grep -qw libvirt; then \
		echo "  ✅ $(CURRENT_USER) is in the 'libvirt' group"; \
	else \
		if getent group libvirt | cut -d: -f4 | tr ',' '\n' | grep -qx "$(CURRENT_USER)"; then \
			echo "  ⚠️  $(CURRENT_USER) is listed in 'libvirt', but this shell has not picked it up yet"; \
			echo "  ℹ️  Run 'newgrp libvirt', log out/in, or reboot."; \
		else \
			echo "  ❌ $(CURRENT_USER) is NOT in the 'libvirt' group"; \
			echo "  ℹ️  Run 'make configure-user'."; \
		fi; \
	fi
	@echo "$(SEPARATOR)"
	@echo "🌐 Networks:"
	@if sudo virsh --connect $(LIBVIRT_URI) net-info $(NETWORK_NAME) >/dev/null 2>&1; then \
		sudo virsh --connect $(LIBVIRT_URI) net-info $(NETWORK_NAME) | sed 's/^/  /'; \
		if sudo virsh --connect $(LIBVIRT_URI) net-info $(NETWORK_NAME) | grep -q 'Active:.*yes'; then \
			echo "  ✅ Network '$(NETWORK_NAME)' is active"; \
		else \
			echo "  ❌ Network '$(NETWORK_NAME)' is defined but inactive"; \
			echo "  ℹ️  Run 'make configure-network'."; \
		fi; \
		if sudo virsh --connect $(LIBVIRT_URI) net-info $(NETWORK_NAME) | grep -q 'Autostart:.*yes'; then \
			echo "  ✅ Network '$(NETWORK_NAME)' autostart is enabled"; \
		else \
			echo "  ❌ Network '$(NETWORK_NAME)' autostart is disabled"; \
			echo "  ℹ️  Run 'make configure-network'."; \
		fi; \
	else \
		echo "  ❌ Network '$(NETWORK_NAME)' is not defined"; \
		echo "  ℹ️  Run 'make configure-network'."; \
	fi
	@sudo virsh --connect $(LIBVIRT_URI) net-list --all 2>/dev/null || true
	@echo "$(SEPARATOR)"
	@echo "🖥️  Domains:"
	@sudo virsh --connect $(LIBVIRT_URI) list --all 2>/dev/null || echo "  (virsh not available)"

## ---------------------------
## 💾 Backup
## ---------------------------

backup: check-running ## Run check-running, then back up ISOs, XMLs, NVRAM, and disks to cloud via rclone
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
