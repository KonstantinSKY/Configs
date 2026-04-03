.PHONY: help create dry-run
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/../..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

CREATE_SCRIPT := $(THIS_DIR)/create.sh

VM_NAME    ?= manjaro-rehearsal
ISO        ?=
RAM_MB     ?= 8192
VCPUS      ?= 2
DISK_GB    ?= 30

dry-run: ## Validate VM creation and print generated XML without creating anything
	@ISO_PATH="$(ISO)" \
	VM_NAME="$(VM_NAME)" \
	MEMORY_MB="$(RAM_MB)" \
	VCPUS="$(VCPUS)" \
	DISK_GB="$(DISK_GB)" \
	CONFIG_ROOT="$(THIS_DIR)" \
	DRY_RUN=1 \
	"$(CREATE_SCRIPT)"

create: ## Create and start the Manjaro rehearsal VM
	@ISO_PATH="$(ISO)" \
	VM_NAME="$(VM_NAME)" \
	MEMORY_MB="$(RAM_MB)" \
	VCPUS="$(VCPUS)" \
	DISK_GB="$(DISK_GB)" \
	CONFIG_ROOT="$(THIS_DIR)" \
	DRY_RUN=0 \
	"$(CREATE_SCRIPT)"
