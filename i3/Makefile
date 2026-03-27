.PHONY: setup check

MAKEFLAGS += --no-print-directory

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))

I3_PROFILE ?= auto

I3_CONF_DIR := $(HOME)/.i3
I3_SOURCE_DIR := $(THIS_DIR)
I3_SOURCE_CONFIG := $(I3_SOURCE_DIR)/config
I3_SOURCE_MONITOR_LAPTOP := $(I3_SOURCE_DIR)/laptop
I3_SOURCE_MONITOR_DESKTOP := $(I3_SOURCE_DIR)/desktop

I3_TARGET_CONFIG := $(I3_CONF_DIR)/config
I3_TARGET_MONITOR := $(I3_CONF_DIR)/host
I3_MONITOR_CONFIG_NAME := monitor.conf
I3_STATUS_CONFIG_NAME := i3status.conf
I3_TARGET_INCLUDE_LINE := include ~/.i3/host/$(I3_MONITOR_CONFIG_NAME)

define resolve_i3_profile
	case "$(I3_PROFILE)" in \
		auto) \
			if command -v upower >/dev/null 2>&1 && upower -e 2>/dev/null | grep -q BAT; then \
				profile="laptop"; \
				monitor_dir="$(I3_SOURCE_MONITOR_LAPTOP)"; \
			else \
				profile="desktop"; \
				monitor_dir="$(I3_SOURCE_MONITOR_DESKTOP)"; \
			fi; \
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
			echo "   Use one of: auto, laptop, desktop"; \
			exit 1; \
			;; \
	esac
endef

check:
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
	$(call require_exists,$(I3_SOURCE_CONFIG),Main config file not found); \
	$(call require_exists,$$monitor_dir/$(I3_MONITOR_CONFIG_NAME),Monitor config file not found); \
	$(call require_exists,$$monitor_dir/$(I3_STATUS_CONFIG_NAME),i3status config file not found); \
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

setup:
	@$(MAKE) -f "$(THIS_MAKEFILE)" check I3_PROFILE="$(I3_PROFILE)"
	@set -euo pipefail; \
	$(resolve_i3_profile); \
	config_backup=""; \
	monitor_backup=""; \
	config_linked=0; \
	monitor_linked=0; \
	desired_config="$$(readlink -f "$(I3_SOURCE_CONFIG)")"; \
	desired_monitor="$$(readlink -f "$$monitor_dir")"; \
	current_config=""; \
	current_monitor=""; \
	if [ -L "$(I3_TARGET_CONFIG)" ]; then \
		current_config="$$(readlink -f "$(I3_TARGET_CONFIG)" 2>/dev/null || true)"; \
	fi; \
	if [ -L "$(I3_TARGET_MONITOR)" ]; then \
		current_monitor="$$(readlink -f "$(I3_TARGET_MONITOR)" 2>/dev/null || true)"; \
	fi; \
	restore_previous() { \
		if [ "$$config_linked" -eq 1 ]; then \
			rm -f "$(I3_TARGET_CONFIG)"; \
			if [ -n "$$config_backup" ] && { [ -e "$$config_backup" ] || [ -L "$$config_backup" ]; }; then \
				mv "$$config_backup" "$(I3_TARGET_CONFIG)"; \
			fi; \
		fi; \
		if [ "$$monitor_linked" -eq 1 ]; then \
			rm -f "$(I3_TARGET_MONITOR)"; \
			if [ -n "$$monitor_backup" ] && { [ -e "$$monitor_backup" ] || [ -L "$$monitor_backup" ]; }; then \
				mv "$$monitor_backup" "$(I3_TARGET_MONITOR)"; \
			fi; \
		fi; \
	}; \
	echo "------------------------------------------------------------"; \
	echo "📁 Creating config directory..."; \
	mkdir -p "$(I3_CONF_DIR)"; \
	echo "------------------------------------------------------------"; \
	if [ "$$current_config" = "$$desired_config" ]; then \
		echo "✅ Main config already linked: $(I3_TARGET_CONFIG)"; \
	else \
		echo "🔗 Linking main config:"; \
		echo "→ Target : $(I3_TARGET_CONFIG)"; \
		echo "→ Source : $(I3_SOURCE_CONFIG)"; \
		BACKUP_PATH=""; \
		$(call prepare_stow_target,$(I3_TARGET_CONFIG),$(I3_SOURCE_CONFIG)); \
		config_backup="$$BACKUP_PATH"; \
		ln -s "$(I3_SOURCE_CONFIG)" "$(I3_TARGET_CONFIG)"; \
		config_linked=1; \
	fi; \
	echo "------------------------------------------------------------"; \
	if [ "$$current_monitor" = "$$desired_monitor" ]; then \
		echo "✅ Monitor profile already linked: $$profile"; \
	else \
		echo "🔗 Linking monitor profile:"; \
		echo "→ Profile: $$profile"; \
		echo "→ Target : $(I3_TARGET_MONITOR)"; \
		echo "→ Source : $$monitor_dir"; \
		BACKUP_PATH=""; \
		$(call prepare_stow_target,$(I3_TARGET_MONITOR),$$monitor_dir); \
		monitor_backup="$$BACKUP_PATH"; \
		ln -s "$$monitor_dir" "$(I3_TARGET_MONITOR)"; \
		monitor_linked=1; \
	fi; \
	echo "------------------------------------------------------------"; \
	echo "🔍 Final validation of installed i3 config..."; \
	if ! i3 -C -c "$(I3_TARGET_CONFIG)" >/dev/null 2>&1; then \
		echo "❌ Installed config is invalid. Restoring previous state."; \
		i3 -C -c "$(I3_TARGET_CONFIG)" || true; \
		restore_previous; \
		exit 1; \
	fi; \
	echo "✅ Final config is valid and active."; \
	if [ -n "$$config_backup" ]; then \
		echo "🗄️  Previous config kept at $$config_backup"; \
	fi; \
	if [ -n "$$monitor_backup" ]; then \
		echo "🗄️  Previous monitor setup kept at $$monitor_backup"; \
	fi; \
	echo "✅ Setup complete!"
