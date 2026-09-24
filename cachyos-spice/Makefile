.PHONY: help install check link-script link-menu verify
.DEFAULT_GOAL := help

THIS_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SCRIPT_SOURCE := $(THIS_DIR)/open-cachyos
DESKTOP_SOURCE := $(THIS_DIR)/cachyos.desktop
SCRIPT_LINK := /usr/local/bin/open-cachyos
MENU_DIR := $(HOME)/.local/share/applications
MENU_LINK := $(MENU_DIR)/cachyos.desktop

help:
	@echo "CachyOS SPICE launcher"
	@echo
	@echo "  make install  create local links and verify the installation"
	@echo "  make verify   check links and required programs"

install: check link-script link-menu verify

check:
	@for command_name in curl jq remote-viewer; do \
		command -v "$$command_name" >/dev/null 2>&1 || { \
			echo "Missing required command: $$command_name"; \
			exit 1; \
		}; \
	done

link-script:
	@chmod 755 "$(SCRIPT_SOURCE)"
	@sudo ln -sfn "$(SCRIPT_SOURCE)" "$(SCRIPT_LINK)"

link-menu:
	@mkdir -p "$(MENU_DIR)"
	@ln -sfn "$(DESKTOP_SOURCE)" "$(MENU_LINK)"
	@chmod 755 "$(DESKTOP_SOURCE)"

verify:
	@test -x "$(SCRIPT_SOURCE)"
	@test -L "$(SCRIPT_LINK)"
	@test -L "$(MENU_LINK)"
	@echo "CachyOS launcher is installed."
