SHELL := /bin/bash

.PHONY: help h status st verify v tree t
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))

help h:
	@echo "Shell rc draft module"
	@echo
	@echo "  make status    Show configured draft files"
	@echo "  make verify    Check that all draft files exist"
	@echo "  make tree      Show proposed shell layout"
	@echo
	@echo "No install/link target exists yet."

status st:
	@printf '%-18s %s\n' "module" "$(THIS_DIR)"
	@printf '%-18s %s\n' "common rc" "$(THIS_DIR)/rc.common"
	@printf '%-18s %s\n' "interactive rc" "$(THIS_DIR)/rc.interactive"
	@printf '%-18s %s\n' "tmux rc" "$(THIS_DIR)/rc.tmux"
	@printf '%-18s %s\n' "bash wrapper" "$(THIS_DIR)/shells/bashrc"
	@printf '%-18s %s\n' "zsh wrapper" "$(THIS_DIR)/shells/zshrc"
	@printf '%-18s %s\n' "roles" "$(THIS_DIR)/roles"

verify v:
	@set -euo pipefail; \
	for path in \
		"$(THIS_DIR)/README.md" \
		"$(THIS_DIR)/rc.common" \
		"$(THIS_DIR)/rc.interactive" \
		"$(THIS_DIR)/rc.tmux" \
		"$(THIS_DIR)/shells/bashrc" \
		"$(THIS_DIR)/shells/zshrc" \
		"$(THIS_DIR)/roles/workstation.rc" \
		"$(THIS_DIR)/roles/proxmox.rc" \
		"$(THIS_DIR)/roles/dev.rc" \
		"$(THIS_DIR)/roles/prod.rc"; do \
		if [[ -r "$$path" ]]; then \
			echo "PRESENT: $$path"; \
		else \
			echo "MISSING: $$path"; \
			exit 1; \
		fi; \
	done; \
	echo "Shell draft verification passed."

tree t:
	@find "$(THIS_DIR)" -maxdepth 3 -type f | sort | sed "s#$(THIS_DIR)#Configs/shell#"
