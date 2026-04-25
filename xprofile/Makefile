# IMPORTANT:
# Humans and AI agents must not modify this file without explicit user confirmation.
#
# X11 session environment for Qt/GTK/browser. Distro-agnostic.

.PHONY: help all install i link l verify v
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/all.mk,$(abspath $(MAKEFILE_LIST))),)
include $(CONFIGS_DIR)/make/all.mk
endif

XPROFILE_SOURCE := $(THIS_DIR)/.xprofile
XPROFILE_TARGET := $(HOME)/.xprofile

all: install

install i link l: ## Link .xprofile into $$HOME
	@$(call link,$(XPROFILE_SOURCE),$(XPROFILE_TARGET))

verify v: ## Show current ~/.xprofile state
	@$(call verify_link,$(XPROFILE_TARGET))
