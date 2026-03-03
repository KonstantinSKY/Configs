.PHONY: setup clean
## ---------------------------
## 🧩 i3 configuration paths
## ---------------------------
I3_CONF_DIR        := $(HOME)/.config/i3
OLD_I3_DIR         := $(HOME)/.i3
SOURCE_I3_CONFIG   := $(HOME)/Work/Configs/i3
## ---------------------------
## 🧩 i3 main config files
## ---------------------------
I3_TARGET_CONFIG   := $(I3_CONF_DIR)/config
I3_SOURCE_CONFIG   := $(SOURCE_I3_CONFIG)/config
## ---------------------------
## 🧩 i3 monitor directory links
## ---------------------------
I3_TARGET_MONITOR_LINK     := $(I3_CONF_DIR)/monitor
I3_SOURCE_MONITOR_LAPTOP   := $(SOURCE_I3_CONFIG)/laptop
I3_SOURCE_MONITOR_DESKTOP  := $(SOURCE_I3_CONFIG)/desktop
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
	@echo "📦 Copying legacy config directory..."
	@if [ -d "$(OLD_I3_DIR)" ]; then \
		cp -r "$(OLD_I3_DIR)" "$(OLD_I3_DIR).back"; \
		echo "🗄️  Copied $(OLD_I3_DIR) → $(OLD_I3_DIR).back"; \
	else \
		echo "✅ No legacy config directory to back up."; \
	fi
	@echo "------------------------------------------------------------"
	@echo "📁 Creating config directory..."
	@mkdir -p "$(I3_CONF_DIR)"
	@echo "------------------------------------------------------------"
	@echo "🔗 Linking main config:"
	@echo "→ Target : $(I3_TARGET_CONFIG)"
	@echo "→ Source : $(I3_SOURCE_CONFIG)"
	@ln -sf "$(I3_SOURCE_CONFIG)" "$(I3_TARGET_CONFIG)"
	@echo "------------------------------------------------------------"
	@echo "💻 Detecting system type and linking monitor directory..."
	@sh -c '\
		if command -v upower >/dev/null && upower -e | grep -q BAT; then \
			echo "🖥️  Laptop detected."; \
			MONITOR_DIR="$(I3_SOURCE_MONITOR_LAPTOP)"; \
		else \
			echo "🖥️  Desktop detected."; \
			MONITOR_DIR="$(I3_SOURCE_MONITOR_DESKTOP)"; \
		fi; \
		echo "------------------------------------------------------------"; \
		echo "🔗 Linking monitor directory:"; \
		echo "→ Target : $(I3_TARGET_MONITOR_LINK)"; \
		echo "→ Source : $$MONITOR_DIR"; \
		ln -sfn "$$MONITOR_DIR" "$(I3_TARGET_MONITOR_LINK)"; \
	'
	@echo "------------------------------------------------------------"
	@echo "🔍 Final validation of full i3 config..."
	@if ! i3 -C -c "$(I3_TARGET_CONFIG)" 2>&1; then \
			echo "❌ Final config is invalid! Rolling back symlinks."; \
			rm -f "$(I3_TARGET_CONFIG)" "$(I3_TARGET_MONITOR_LINK)"; \
			exit 1; \
	else \
		echo "✅ Final config is valid and active."; \
	fi
	@echo "------------------------------------------------------------"
	@echo "🧹 Removing legacy directory (if exists): $(OLD_I3_DIR)"
	@rm -rf "$(OLD_I3_DIR)"
	@echo "✅ Setup complete!"
