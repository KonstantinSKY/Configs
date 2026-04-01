.PHONY: xprofile xp mimeapps ma zsh

TARGET_XPROFILE_FILE = $(HOME)/.xprofile
XPROFILE_SOURCE_FILE = $(CONFIGS_DIR)/xprofile/.xprofile
TARGET_MIMEAPPS_FILE = $(HOME)/.config/mimeapps.list
MIMEAPPS_SOURCE_FILE = $(THIS_DIR)/mimeapps.list
ZSH_TARGET_RC = $(HOME)/.zshrc
ZSH_CUSTOM_RC = $(CONFIGS_DIR)/zsh/rc
ZSH_INCLUDE_START = \# >>> custom shell config >>>
ZSH_INCLUDE_END = \# <<< custom shell config <<<
ZSH_INCLUDE_LINE = [ -r "$(ZSH_CUSTOM_RC)" ] && source "$(ZSH_CUSTOM_RC)"

## ---------------------------
## 👤 User Session
## ---------------------------
xprofile xp: ## Link .xprofile via a direct symlink
	@$(call require_exists,$(XPROFILE_SOURCE_FILE),Source xprofile not found)
	@echo "📦 Preparing existing $(TARGET_XPROFILE_FILE)..."
	@if [ -L "$(TARGET_XPROFILE_FILE)" ]; then \
		CURRENT_LINK="$$(readlink -f "$(TARGET_XPROFILE_FILE)" 2>/dev/null || true)"; \
		DESIRED_LINK="$$(readlink -f "$(XPROFILE_SOURCE_FILE)" 2>/dev/null || true)"; \
		if [ "$$CURRENT_LINK" != "$$DESIRED_LINK" ]; then \
			BACKUP_PATH="$(TARGET_XPROFILE_FILE).bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up existing .xprofile symlink to $$BACKUP_PATH"; \
			mv "$(TARGET_XPROFILE_FILE)" "$$BACKUP_PATH"; \
		fi; \
	fi
	@$(call backup_if_needed,$(TARGET_XPROFILE_FILE))
	@echo "🔗 Linking $(TARGET_XPROFILE_FILE) → $(XPROFILE_SOURCE_FILE)..."
	@ln -sfn "$(XPROFILE_SOURCE_FILE)" "$(TARGET_XPROFILE_FILE)"
	@echo "✅ xprofile linked to $(TARGET_XPROFILE_FILE)"

mimeapps ma: ## Link managed XDG default applications file
	@$(call require_exists,$(MIMEAPPS_SOURCE_FILE),Source mimeapps file not found)
	@mkdir -p "$(dir $(TARGET_MIMEAPPS_FILE))"
	@echo "📦 Preparing existing $(TARGET_MIMEAPPS_FILE)..."
	@if [ -L "$(TARGET_MIMEAPPS_FILE)" ]; then \
		CURRENT_LINK="$$(readlink -f "$(TARGET_MIMEAPPS_FILE)" 2>/dev/null || true)"; \
		DESIRED_LINK="$$(readlink -f "$(MIMEAPPS_SOURCE_FILE)" 2>/dev/null || true)"; \
		if [ "$$CURRENT_LINK" != "$$DESIRED_LINK" ]; then \
			BACKUP_PATH="$(TARGET_MIMEAPPS_FILE).bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up existing mimeapps symlink to $$BACKUP_PATH"; \
			mv "$(TARGET_MIMEAPPS_FILE)" "$$BACKUP_PATH"; \
		fi; \
	fi
	@$(call backup_if_needed,$(TARGET_MIMEAPPS_FILE))
	@echo "🔗 Linking $(TARGET_MIMEAPPS_FILE) → $(MIMEAPPS_SOURCE_FILE)..."
	@ln -sfn "$(MIMEAPPS_SOURCE_FILE)" "$(TARGET_MIMEAPPS_FILE)"
	@echo "✅ mimeapps linked to $(TARGET_MIMEAPPS_FILE)"

zsh: ## Install zsh if needed and switch current user to it
	@if ! command -v yay >/dev/null 2>&1; then \
		echo "❌ yay is not installed. Run 'make -f $(THIS_MAKEFILE) setup' first."; \
		exit 1; \
	fi
	@echo "🔍 Checking zsh installation..."
	@if command -v zsh >/dev/null 2>&1; then \
		ZSH_PATH="$$(command -v zsh)"; \
		echo "✅ zsh is installed: $$ZSH_PATH"; \
	else \
		echo "📦 Installing zsh..."; \
		yay -S --needed --noconfirm zsh; \
		ZSH_PATH="$$(command -v zsh)"; \
	fi; \
	CURRENT_SHELL="$$(getent passwd "$$USER" | cut -d: -f7)"; \
	echo "👤 Current login shell: $$CURRENT_SHELL"; \
	if [ "$$CURRENT_SHELL" = "$$ZSH_PATH" ]; then \
		echo "✅ Login shell is already set to $$ZSH_PATH"; \
	else \
		echo "🔄 Switching login shell to $$ZSH_PATH"; \
		chsh -s "$$ZSH_PATH"; \
		echo "✅ Login shell updated. Open a new session to use zsh by default."; \
	fi
	@$(call require_exists,$(ZSH_CUSTOM_RC),Custom zsh rc not found)
	@echo "🧩 Ensuring $(ZSH_TARGET_RC) loads $(ZSH_CUSTOM_RC)..."
	@if [ ! -e "$(ZSH_TARGET_RC)" ]; then \
		echo "📄 Creating new $(ZSH_TARGET_RC)"; \
		{ \
			printf '%s\n' '$(ZSH_INCLUDE_START)'; \
			printf '%s\n' '$(ZSH_INCLUDE_LINE)'; \
			printf '%s\n' '$(ZSH_INCLUDE_END)'; \
		} > "$(ZSH_TARGET_RC)"; \
	elif grep -Fqx '$(ZSH_INCLUDE_LINE)' "$(ZSH_TARGET_RC)"; then \
		echo "✅ Custom zsh include already present in $(ZSH_TARGET_RC)"; \
	else \
		printf '\n%s\n%s\n%s\n' '$(ZSH_INCLUDE_START)' '$(ZSH_INCLUDE_LINE)' '$(ZSH_INCLUDE_END)' >> "$(ZSH_TARGET_RC)"; \
		echo "✅ Added custom zsh include to $(ZSH_TARGET_RC)"; \
	fi
