# KVM Infrastructure Management

KVM_ROOT    := $(HOME)/Work/KVMs
CONFIG_ROOT := $(HOME)/Work/Configs/kvm
XML_DIR     := $(CONFIG_ROOT)/xmls
REMOTE      := gdrive:KVM_Backups

.PHONY: backup install check-running

# По умолчанию запускаем бекап всего
backup: check-running
	@echo "=== STARTING FULL KVM BACKUP ==="
	
	@echo "--> [1/4] Syncing ISOs..."
	@rclone copy "$(KVM_ROOT)/isos" "$(REMOTE)/isos" -P

	@echo "--> [2/4] Saving XML Configs..."
	@mkdir -p $(XML_DIR)
	@for domain in $$(virsh list --all --name); do \
		if [ ! -z "$$domain" ]; then \
			virsh dumpxml "$$domain" > "$(XML_DIR)/$$domain.xml"; \
			echo "   Saved: $$domain"; \
		fi \
	done
	@echo "   Uploading XMLs to Cloud..."
	@rclone copy "$(XML_DIR)" "$(REMOTE)/xmls" -P

	@echo "--> [3/4] Backing up NVRAM (BIOS)..."
	@rclone copy "$(KVM_ROOT)/nvram" "$(REMOTE)/nvram" -P

	@echo "--> [4/4] Backing up Disks..."
	@rclone copy "$(KVM_ROOT)/disks" "$(REMOTE)/disks" -P
	
	@echo "=== BACKUP COMPLETED ==="

check-running:
	@if [ -n "$$(virsh list --name --state-running)" ]; then \
		echo "❌ ERROR: The following VMs are currently RUNNING:"; \
		virsh list --state-running; \
		echo "⚠️  Please shutdown ALL VMs before backup to prevent corruption."; \
		exit 1; \
	else \
		echo "✅ All VMs are offline. Proceeding..."; \
	fi

install:
	@echo "--> Defining VMs from local XMLs..."
	@for xml in $(XML_DIR)/*.xml; do \
		[ -f "$$xml" ] || continue; \
		virsh define "$$xml"; \
	done