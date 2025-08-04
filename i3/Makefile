setup:
	@echo "🔍 Detecting i3 version..."
	@if command -v i3 >/dev/null 2>&1; then \
		i3 --version; \
	else \
		echo "❌ i3 is not installed. Aborting."; \
		exit 1; \
	fi
	@echo "------------------------------------------------------------"

	@echo "🔍 Validating source config file..."
	@echo "📄 Role   : Main i3 config"
	@echo "📄 Source : $(I3_SOURCE_CONFIG)"
	@if [ ! -f "$(I3_SOURCE_CONFIG)" ]; then \
		echo "❌ Main config file not found: $(I3_SOURCE_CONFIG)"; \
		exit 1; \
	fi

	@echo "+ i3 -C -c $(I3_SOURCE_CONFIG)"
	@if ! i3 -C -c "$(I3_SOURCE_CONFIG)" >/dev/null 2>&1; then \
		echo "❌ Main config is invalid! Please fix errors before continuing."; \
		i3 -C -c "$(I3_SOURCE_CONFIG)"; \
		exit 1; \
	else \
		echo "✅ Main config is valid: $(I3_SOURCE_CONFIG)"; \
	fi
	@echo "------------------------------------------------------------"

	@echo "📁 Creating config and monitor directories..."
	@mkdir -p "$(I3_CONF_DIR)" "$(I3_MONITOR_DIR)"
	@echo "------------------------------------------------------------"

	@echo "🔗 Linking main config:"
	@echo "→ Target : $(I3_TARGET_CONFIG)"
	@echo "→ Source : $(I3_SOURCE_CONFIG)"
	@ln -sf "$(I3_SOURCE_CONFIG)" "$(I3_TARGET_CONFIG)"
	@echo "------------------------------------------------------------"

	@echo "💻 Detecting system type and linking monitor config..."
	@sh -c '\
		if command -v upower >/dev/null && upower -e | grep -q BAT; then \
			echo "🖥️  Laptop detected."; \
			MONITOR_CONF="$(I3_SOURCE_MONITOR_LAPTOP)"; \
		else \
			echo "🖥️  Desktop detected."; \
			MONITOR_CONF="$(I3_SOURCE_MONITOR_DESKTOP)"; \
		fi; \
		echo "------------------------------------------------------------"; \
		echo "🔗 Linking monitor config:"; \
		echo "→ Target : $(I3_TARGET_MONITOR_CONF)"; \
		echo "→ Source : $$MONITOR_CONF"; \
		ln -sf "$$MONITOR_CONF" "$(I3_TARGET_MONITOR_CONF)"; \
	'
	@echo "------------------------------------------------------------"

	@echo "🔍 Final validation of full i3 config..."
	@if ! i3 -C -c "$(I3_TARGET_CONFIG)" >/dev/null 2>&1; then \
		echo "❌ Final config is invalid! Rolling back symlinks."; \
		rm -f "$(I3_TARGET_CONFIG)" "$(I3_TARGET_MONITOR_CONF)"; \
		exit 1; \
	else \
		echo "✅ Final config is valid and active."; \
		echo "🧹 Removing legacy directory: $(OLD_I3_DIR)"; \
		rm -rf "$(OLD_I3_DIR)"; \
	fi
