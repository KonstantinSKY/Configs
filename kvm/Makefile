# KVM Infrastructure Management
KVM_ROOT    := $(HOME)/Work/KVMs
CONFIG_ROOT := $(HOME)/Work/Configs/kvm
XML_DIR     := $(CONFIG_ROOT)/xmls
REMOTE      := gdrive:KVM_Backups
MANJARO_SCRIPT := $(CONFIG_ROOT)/create-manjaro-rehearsal.sh
MANJARO_VM_NAME ?= manjaro-rehearsal
MANJARO_ISO ?=
MANJARO_RAM_MB ?= 8192
MANJARO_VCPUS ?= 2
MANJARO_DISK_GB ?= 30
.PHONY: backup install check-running manjaro-dry-run manjaro-create
# По умолчанию запускаем бекап всего
backup: check-running ## Run full KVM backup (ISOs, XMLs, NVRAM, disks)
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
check-running: ## Ensure all VMs are stopped before backup
	@if [ -n "$$(virsh list --name --state-running)" ]; then \
		echo "❌ ERROR: The following VMs are currently RUNNING:"; \
		virsh list --state-running; \
		echo "⚠️  Please shutdown ALL VMs before backup to prevent corruption."; \
		exit 1; \
	else \
		echo "✅ All VMs are offline. Proceeding..."; \
	fi
install: ## Define VMs from local XML files
	@echo "--> Defining VMs from local XMLs..."
	@for xml in $(XML_DIR)/*.xml; do \
		[ -f "$$xml" ] || continue; \
		virsh define "$$xml"; \
	done

manjaro-dry-run: ## Validate Manjaro rehearsal VM creation and print generated XML
	@ISO_PATH="$(MANJARO_ISO)" \
	VM_NAME="$(MANJARO_VM_NAME)" \
	MEMORY_MB="$(MANJARO_RAM_MB)" \
	VCPUS="$(MANJARO_VCPUS)" \
	DISK_GB="$(MANJARO_DISK_GB)" \
	DRY_RUN=1 \
	"$(MANJARO_SCRIPT)"

manjaro-create: ## Create and start the Manjaro rehearsal VM
	@ISO_PATH="$(MANJARO_ISO)" \
	VM_NAME="$(MANJARO_VM_NAME)" \
	MEMORY_MB="$(MANJARO_RAM_MB)" \
	VCPUS="$(MANJARO_VCPUS)" \
	DISK_GB="$(MANJARO_DISK_GB)" \
	DRY_RUN=0 \
	"$(MANJARO_SCRIPT)"
