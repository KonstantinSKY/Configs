.PHONY: help setup check
.DEFAULT_GOAL := help

MAKEFLAGS += --no-print-directory

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

I3_PROFILE ?= auto

I3_CONF_DIR := $(HOME)/.i3
I3_SOURCE_DIR := $(THIS_DIR)
I3_SOURCE_CONFIG := $(I3_SOURCE_DIR)/config
I3_SOURCE_MONITOR_VM := $(I3_SOURCE_DIR)/vm
I3_SOURCE_MONITOR_LAPTOP := $(I3_SOURCE_DIR)/laptop
I3_SOURCE_MONITOR_DESKTOP := $(I3_SOURCE_DIR)/desktop

I3_TARGET_CONFIG := $(I3_CONF_DIR)/config
I3_TARGET_MONITOR := $(I3_CONF_DIR)/host
I3_MONITOR_CONFIG_NAME := monitor.conf
I3_STATUS_CONFIG_NAME := i3status.conf
I3_TARGET_INCLUDE_LINE := include ~/.i3/host/$(I3_MONITOR_CONFIG_NAME)

define require_path
	if [ ! -e "$(1)" ]; then \
		echo "❌ $(strip $(2)): $(1)"; \
		exit 1; \
	fi
endef

define resolve_i3_profile
	case "$(I3_PROFILE)" in \
		auto) \
			if command -v systemd-detect-virt >/dev/null 2>&1 && systemd-detect-virt --quiet; then \
				profile="vm"; \
				monitor_dir="$(I3_SOURCE_MONITOR_VM)"; \
			elif find /sys/class/power_supply -maxdepth 1 -name 'BAT*' -print -quit 2>/dev/null | grep -q .; then \
				profile="laptop"; \
				monitor_dir="$(I3_SOURCE_MONITOR_LAPTOP)"; \
			elif command -v upower >/dev/null 2>&1 && upower -e 2>/dev/null | grep -q BAT; then \
				profile="laptop"; \
				monitor_dir="$(I3_SOURCE_MONITOR_LAPTOP)"; \
			else \
				profile="desktop"; \
				monitor_dir="$(I3_SOURCE_MONITOR_DESKTOP)"; \
			fi; \
			;; \
		vm) \
			profile="vm"; \
			monitor_dir="$(I3_SOURCE_MONITOR_VM)"; \
			;; \
		laptop) \
			profile="laptop"; \
			monitor_dir="$(I3_SOURCE_MONITOR_LAPTOP)"; \
			;; \
		desktop) \
			profile="desktop"; \
			monitor_dir="$(I3_SOURCE_MONITOR_DESKTOP)"; \
			;; \
		*) \
			echo "❌ Unsupported I3_PROFILE: $(I3_PROFILE)"; \
			echo "   Use one of: auto, vm, laptop, desktop"; \
			exit 1; \
			;; \
	esac
endef

check: ## Validate i3 config and detect host profile (vm/laptop/desktop)
	@set -euo pipefail; \
	echo "🔍 Detecting i3 version..."; \
	if command -v i3 >/dev/null 2>&1; then \
		i3 --version; \
	else \
		echo "❌ i3 is not installed. Aborting."; \
		exit 1; \
	fi; \
	$(resolve_i3_profile); \
	echo "------------------------------------------------------------"; \
	echo "🔍 Validating source config..."; \
	echo "📄 Main    : $(I3_SOURCE_CONFIG)"; \
	echo "📁 Profile : $$profile"; \
	echo "📁 Monitor : $$monitor_dir"; \
	$(call require_path,$(I3_SOURCE_CONFIG),Main config file not found); \
	$(call require_path,$$monitor_dir/$(I3_MONITOR_CONFIG_NAME),Monitor config file not found); \
	$(call require_path,$$monitor_dir/$(I3_STATUS_CONFIG_NAME),i3status config file not found); \
	if ! grep -Fqx '$(I3_TARGET_INCLUDE_LINE)' "$(I3_SOURCE_CONFIG)"; then \
		echo "❌ Expected monitor include not found in $(I3_SOURCE_CONFIG)"; \
		exit 1; \
	fi; \
	tmp_config="$$(mktemp)"; \
	trap 'rm -f "$$tmp_config"' EXIT; \
	awk -v expected='$(I3_TARGET_INCLUDE_LINE)' -v replacement="include $$monitor_dir/$(I3_MONITOR_CONFIG_NAME)" '$$0 == expected { print replacement; next } { print }' "$(I3_SOURCE_CONFIG)" > "$$tmp_config"; \
	echo "+ i3 -C -c $$tmp_config"; \
	if ! i3 -C -c "$$tmp_config" >/dev/null 2>&1; then \
		echo "❌ i3 config is invalid for $$profile profile."; \
		i3 -C -c "$$tmp_config"; \
		exit 1; \
	fi; \
	echo "✅ i3 config is valid for $$profile profile."

setup: ## Link i3 config and host profile (auto-detects vm/laptop/desktop)
	@$(MAKE) -f "$(THIS_MAKEFILE)" check I3_PROFILE="$(I3_PROFILE)"
	@set -euo pipefail; \
	$(resolve_i3_profile); \
	echo "------------------------------------------------------------"; \
	echo "📁 Creating config directory..."; \
	mkdir -p "$(I3_CONF_DIR)"; \
	echo "------------------------------------------------------------"; \
	$(call link,$(I3_SOURCE_CONFIG),$(I3_TARGET_CONFIG)); \
	echo "------------------------------------------------------------"; \
	echo "🖥️  Selected profile: $$profile"; \
	$(call link,$$monitor_dir,$(I3_TARGET_MONITOR)); \
	echo "------------------------------------------------------------"; \
	echo "🔍 Final validation of installed i3 config..."; \
	if ! i3 -C -c "$(I3_TARGET_CONFIG)" >/dev/null 2>&1; then \
		echo "❌ Installed config is invalid."; \
		i3 -C -c "$(I3_TARGET_CONFIG)" || true; \
		exit 1; \
	fi; \
	echo "✅ Final config is valid and active."; \
	echo "✅ Setup complete!"
