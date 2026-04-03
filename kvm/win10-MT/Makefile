.PHONY: help define
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/../..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

LIBVIRT_URI := qemu:///system
DOMAIN_XML  := $(THIS_DIR)/domain.xml

define: ## Define the Win10-MT domain from domain.xml
	@echo "🖥️  Defining win10-MT from $(DOMAIN_XML)..."
	@virsh --connect $(LIBVIRT_URI) define "$(DOMAIN_XML)"
	@echo "✅ Domain defined."
