SHELL := /bin/bash

.PHONY: help status install verify uninstall
.DEFAULT_GOAL := help

THIS_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
NAME := thermalright-ssd-display
BIN := /usr/local/bin/$(NAME)
UNIT := /etc/systemd/system/$(NAME).service
DEFAULTS := /etc/default/$(NAME)

help:
	@echo "Thermalright SSD cooler display (USB 0416:8001) on the Proxmox host"
	@echo
	@echo "  make status      read-only: device, files, service state"
	@echo "  make install     install driver + systemd service (sudo); keeps existing $(DEFAULTS)"
	@echo "  make verify      check device, files and service"
	@echo "  make uninstall   stop service and remove installed files (sudo)"

status:
	@set -uo pipefail; \
	if lsusb -d 0416:8001 >/dev/null 2>&1; then echo "DEVICE:   0416:8001 present"; else echo "DEVICE:   0416:8001 not found"; fi; \
	for f in $(BIN) $(UNIT) $(DEFAULTS); do \
		if [[ -e "$$f" ]]; then \
			src="$(THIS_DIR)/$$(basename "$$f")"; [[ "$$f" == "$(DEFAULTS)" ]] && src="$(THIS_DIR)/$(NAME).default"; \
			if cmp -s "$$f" "$$src"; then echo "FILE:     $$f (same as repo)"; else echo "FILE:     $$f (differs from repo)"; fi; \
		else echo "FILE:     $$f missing"; fi; \
	done; \
	echo "SERVICE:  $$(systemctl is-enabled $(NAME).service 2>/dev/null || echo not-installed) / $$(systemctl is-active $(NAME).service 2>/dev/null)"; \
	grep -h '^TR_DISK=' $(DEFAULTS) 2>/dev/null | sed 's/^/CONFIG:   /' || true

install:
	@if [[ "$$(id -u)" -ne 0 ]]; then \
		sudo $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" install; \
	else \
		set -e; \
		install -m 0755 "$(THIS_DIR)/$(NAME)" $(BIN); \
		install -m 0644 "$(THIS_DIR)/$(NAME).service" $(UNIT); \
		if [[ ! -e $(DEFAULTS) ]]; then install -m 0644 "$(THIS_DIR)/$(NAME).default" $(DEFAULTS); else echo "Keeping existing $(DEFAULTS)"; fi; \
		systemctl daemon-reload; \
		systemctl enable $(NAME).service; \
		systemctl restart $(NAME).service; \
		echo "Installed and started $(NAME).service"; \
	fi

verify:
	@set -uo pipefail; failed=0; \
	lsusb -d 0416:8001 >/dev/null 2>&1 && echo "PRESENT: display 0416:8001" || { echo "MISSING: display 0416:8001"; failed=1; }; \
	for f in $(BIN) $(UNIT); do [[ -e "$$f" ]] && echo "PRESENT: $$f" || { echo "MISSING: $$f"; failed=1; }; done; \
	systemctl is-enabled --quiet $(NAME).service && echo "ENABLED: $(NAME).service" || { echo "DISABLED: $(NAME).service"; failed=1; }; \
	systemctl is-active --quiet $(NAME).service && echo "ACTIVE: $(NAME).service" || { echo "INACTIVE: $(NAME).service"; failed=1; }; \
	[[ "$$failed" -eq 0 ]] || exit 1; \
	echo "Thermalright SSD display verification passed."

uninstall:
	@if [[ "$$(id -u)" -ne 0 ]]; then \
		sudo $(MAKE) --no-print-directory -f "$(abspath $(lastword $(MAKEFILE_LIST)))" uninstall; \
	else \
		systemctl disable --now $(NAME).service 2>/dev/null || true; \
		rm -f $(BIN) $(UNIT); \
		systemctl daemon-reload; \
		echo "Removed $(NAME). $(DEFAULTS) left in place."; \
	fi
