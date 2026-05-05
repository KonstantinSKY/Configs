.PHONY: help link l verify v
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif
ifeq ($(filter $(CONFIGS_DIR)/make/link.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/link.mk
endif

SOURCE_DIR := $(THIS_DIR)
TARGET_DIR := $(HOME)/.config/rofi

link l: ## Link ~/.config/rofi → Configs/rofi (backs up existing dir)
	@$(call link,$(SOURCE_DIR),$(TARGET_DIR))

verify v: ## Verify ~/.config/rofi symlink
	@$(call verify_link,$(TARGET_DIR))
