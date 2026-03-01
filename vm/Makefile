# VirtualBox host setup (Manjaro) — uses external Manjaro Makefile for installs

MANJARO_MAKEFILE ?= $(HOME)/Configs/manjaro/Makefile

# ===== Vars =====
VM_HOSTONLY_ENABLE ?= 1
HOSTONLY_NAME      ?= vboxnet0
HOSTONLY_IP        ?= 192.168.56.1
HOSTONLY_MASK      ?= 255.255.255.0
DHCP_LOWER         ?= 192.168.56.100
DHCP_UPPER         ?= 192.168.56.200
VBOXMANAGE         ?= VBoxManage

# auto-pick linuxXX-headers for running kernel (e.g. 6.12 → linux612-headers)
KSHORT      := $(shell uname -r | cut -d. -f1,2 | tr -d .)
HEADERS_PKG := linux$(KSHORT)-headers

.PHONY: help h update up headers kh install i extpack ex check_headers ch dkms_build db modules mod group u hostonly hn verify v reboot_hint rh all a

help h:
	@echo "Targets:"
	@echo "  headers       / kh     - Install $$(printf '%s' $(HEADERS_PKG))"
	@echo "  install       / i      - Install virtualbox + virtualbox-host-dkms"
	@echo "  extpack       / ex     - Install virtualbox-ext-oracle"
	@echo "  check_headers / ch     - Verify kernel headers for $$(uname -r)"
	@echo "  dkms_build    / db     - Force DKMS autoinstall for current kernel"
	@echo "  modules       / mod    - Load vbox* and enable autoload"
	@echo "  group         / u      - Add current user to vboxusers"
	@echo "  hostonly      / hn     - Ensure $(HOSTONLY_NAME) + DHCP"
	@echo "  verify        / v      - Show VBox version/modules/hostonly"
	@echo "  reboot_hint   / rh     - Print relogin/reboot hint"
	@echo "  all           / a      - headers → install → extpack → check_headers → dkms_build → modules → group → (hostonly) → verify → rh"

# ---- Package ops via your Manjaro Makefile ----

headers kh:
	@make -f $(MANJARO_MAKEFILE) install $(HEADERS_PKG)

install i:
	# yay -Rns --noconfirm linux510-virtualbox-host-modules
	@make -f $(MANJARO_MAKEFILE) install dkms virtualbox-host-dkms virtualbox

extpack ex:
	@make -f $(MANJARO_MAKEFILE) install virtualbox-ext-oracle

# ---- Sanity checks / DKMS build ----
check_headers ch:
	@echo "🔎 Checking headers for $$(uname -r)"
	@pkg=$(HEADERS_PKG); \
	if ! (pacman -Q $$pkg >/dev/null 2>&1 || yay -Q $$pkg >/dev/null 2>&1); then \
		echo "❌ Kernel headers not installed: $$pkg"; \
		echo "➡️  Run: make kh   (or: make -f $(MANJARO_MAKEFILE) install $$pkg)"; \
		exit 1; \
	else \
		echo "✅ Headers present: $$pkg"; \
	fi

dkms_build db:
	@echo "🔧 DKMS autoinstall for kernel $$(uname -r)"
	@sudo dkms autoinstall || { echo "❌ DKMS build failed. Check /var/lib/dkms/ logs and ensure headers."; exit 1; }
	@echo "🔎 DKMS status (vboxhost):"
	- @dkms status | grep -i vboxhost || true

# ---- System tweaks ----
modules mod:
	@echo "🧩 Loading VBox kernel modules…"
	@sudo modprobe vboxdrv     || { echo "❌ vboxdrv missing. Did dkms_build succeed?"; exit 1; }
	@sudo modprobe vboxnetflt  || { echo "❌ vboxnetflt missing."; exit 1; }
	@sudo modprobe vboxnetadp  || { echo "❌ vboxnetadp missing."; exit 1; }
	@sudo modprobe vboxpci     || true
	@echo "🧩 Enabling autoload at boot"
	@printf "vboxdrv\nvboxnetflt\nvboxnetadp\nvboxpci\n" | sudo tee /etc/modules-load.d/virtualbox.conf >/dev/null

group u:
	@echo "👥 Adding '$$USER' to vboxusers"
	- @sudo usermod -aG vboxusers "$$USER"
	@id "$$USER"

hostonly hn:
	@echo "🌐 Ensuring host-only: $(HOSTONLY_NAME)"
	@if ! $(VBOXMANAGE) list hostonlyifs | grep -q "^Name:.*$(HOSTONLY_NAME)$$"; then \
		$(VBOXMANAGE) hostonlyif create; \
	fi
	@sudo $(VBOXMANAGE) hostonlyif ipconfig $(HOSTONLY_NAME) --ip $(HOSTONLY_IP) --netmask $(HOSTONLY_MASK)
	@if ! $(VBOXMANAGE) list dhcpservers | grep -q "$(HOSTONLY_NAME)"; then \
		$(VBOXMANAGE) dhcpserver add --ifname $(HOSTONLY_NAME) --ip $(HOSTONLY_IP) --netmask $(HOSTONLY_MASK) --lowerip $(DHCP_LOWER) --upperip $(DHCP_UPPER) --enable; \
	else \
		$(VBOXMANAGE) dhcpserver modify --ifname $(HOSTONLY_NAME) --enable --lowerip $(DHCP_LOWER) --upperip $(DHCP_UPPER); \
	fi

verify v:
	@echo "🔎 VBox version:"
	- $(VBOXMANAGE) --version
	@echo "🔎 Loaded modules:"
	- lsmod | egrep 'vboxdrv|vboxnetflt|vboxnetadp|vboxpci' || true
	@echo "🔎 Host-only interfaces:"
	- $(VBOXMANAGE) list hostonlyifs | sed -n '1,120p' || true

reboot_hint rh:
	@echo "➡️  Re-login (or 'newgrp vboxusers') to apply groups; reboot is recommended."

# Полный сценарий под ядро 6.12 (не меняем ядро)
all a: headers install extpack check_headers dkms_build modules group \
	$(if $(VM_HOSTONLY_ENABLE),hostonly,) verify reboot_hint
