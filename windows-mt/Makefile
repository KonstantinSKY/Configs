.PHONY: help install check link-token link-script link-menu verify
.DEFAULT_GOAL := help

THIS_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SCRIPT_SOURCE := $(THIS_DIR)/open-windows-mt
DESKTOP_SOURCE := $(THIS_DIR)/windows-mt.desktop
SCRIPT_LINK := /usr/local/bin/open-windows-mt
MENU_DIR := $(HOME)/.local/share/applications
MENU_LINK := $(MENU_DIR)/windows-mt.desktop
TOKEN_SOURCE ?=
TOKEN_DIR := $(HOME)/.config/winmt-spice
TOKEN_LINK := $(TOKEN_DIR)/token

help:
	@echo "Windows-MT SPICE launcher"
	@echo
	@echo "  make install  create local links and verify the installation"
	@echo "  make verify   check links, credentials, and required programs"

install: check link-token link-script link-menu verify

check:
	@for command_name in curl jq remote-viewer; do \
		command -v "$$command_name" >/dev/null 2>&1 || { \
			echo "Missing required command: $$command_name"; \
			exit 1; \
		}; \
	done

link-token:
	@mkdir -p "$(TOKEN_DIR)"
	@chmod 700 "$(TOKEN_DIR)"
	@if [ -n "$(TOKEN_SOURCE)" ]; then \
		test -r "$(TOKEN_SOURCE)" || { echo "Credential file is not readable."; exit 1; }; \
		ln -sfn "$(TOKEN_SOURCE)" "$(TOKEN_LINK)"; \
	elif [ ! -r "$(TOKEN_LINK)" ]; then \
		echo "Credentials are missing. Set TOKEN_SOURCE to a private file."; \
		exit 1; \
	fi

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
	@test -r "$(TOKEN_LINK)"
	@echo "Windows-MT launcher is installed."
