# Daily `make user-update` through a systemd user timer.
# The units stay in this directory; ~/.config/systemd/user only links to them.

SHELL := /bin/bash

.PHONY: help status st install i remove run r
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/all.mk,$(abspath $(MAKEFILE_LIST))),)
include $(CONFIGS_DIR)/make/all.mk
endif

UNIT_DIR := $(HOME)/.config/systemd/user
SERVICE := configs-update.service
TIMER := configs-update.timer

install i: ## Link the units and enable the timer
	@if [ "$$(id -u)" = 0 ]; then echo "❌ Run as the normal user, not root."; exit 1; fi
	@$(call link,$(THIS_DIR)/$(SERVICE),$(UNIT_DIR)/$(SERVICE))
	@$(call link,$(THIS_DIR)/$(TIMER),$(UNIT_DIR)/$(TIMER))
	@systemctl --user daemon-reload
	@systemctl --user enable --now $(TIMER)
	@echo "✅ $(TIMER) enabled"
	@$(MAKE) --no-print-directory -f "$(THIS_MAKEFILE)" status

remove: ## Disable the timer and remove the unit links
	@systemctl --user disable --now $(TIMER) 2>/dev/null || true
	@for unit in $(SERVICE) $(TIMER); do \
		if [ -L "$(UNIT_DIR)/$$unit" ]; then rm "$(UNIT_DIR)/$$unit"; echo "🗑️  $(UNIT_DIR)/$$unit"; fi; \
	done
	@systemctl --user daemon-reload
	@echo "✅ $(TIMER) removed"

run r: ## Run the update now and show its log
	@systemctl --user start $(SERVICE) || true
	@journalctl --user -u $(SERVICE) --since "-15min" --no-pager -o cat | tail -40
	@systemctl --user show $(SERVICE) -p Result --value | sed 's/^/Result: /'

status st: ## Show links, timer schedule, last result, and linger (read-only)
	@$(call verify_link,$(UNIT_DIR)/$(SERVICE))
	@$(call verify_link,$(UNIT_DIR)/$(TIMER))
	@echo "enabled: $$(systemctl --user is-enabled $(TIMER) 2>/dev/null || true)"
	@if [ "$$(systemctl --user show $(TIMER) -p NeedDaemonReload --value 2>/dev/null)" = yes ]; then \
		echo "⚠️  unit files changed; run: systemctl --user daemon-reload"; \
	fi
	@systemctl --user list-timers $(TIMER) --all --no-pager 2>/dev/null | head -2
	@result="$$(systemctl --user show $(SERVICE) -p Result --value 2>/dev/null)"; \
	last="$$(systemctl --user show $(SERVICE) -p ExecMainExitTimestamp --value 2>/dev/null)"; \
	if [ -z "$$last" ]; then echo "last run: never"; \
	elif [ "$$result" = success ]; then echo "✅ last run: $$last"; \
	else echo "❌ last run: $$last ($$result); see journalctl --user -u $(SERVICE)"; fi
	@if [ "$$(loginctl show-user "$$USER" -p Linger --value 2>/dev/null)" = yes ]; then \
		echo "✅ linger: on (runs without a login)"; \
	else \
		echo "⚠️  linger: off; the timer runs only while $$USER is logged in"; \
		echo "   enable once: sudo loginctl enable-linger $$USER"; \
	fi
