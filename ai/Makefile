.PHONY: all install i link l verify v

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

include $(CONFIGS_DIR)/make/update.mk

AI_PACKAGES := gemini-cli claude-code openai-codex-bin
GEMINI_POLICY_DIR := $(HOME)/.gemini/policies
GEMINI_POLICY_SRC := $(THIS_DIR)/gemini/shell-rules.toml
GEMINI_POLICY_DEST := $(GEMINI_POLICY_DIR)/shell-rules.toml

define replace_with_symlink
	TARGET_PATH="$(1)"; \
	SOURCE_PATH="$(2)"; \
	DESIRED_LINK="$$(readlink -f "$$SOURCE_PATH")"; \
	CURRENT_LINK=""; \
	if [ -L "$$TARGET_PATH" ]; then \
		CURRENT_LINK="$$(readlink -f "$$TARGET_PATH" 2>/dev/null || true)"; \
	fi; \
	if [ "$$CURRENT_LINK" = "$$DESIRED_LINK" ]; then \
		echo "✅ Gemini policy already linked: $$TARGET_PATH"; \
	else \
		if [ -L "$$TARGET_PATH" ]; then \
			echo "🔁 Replacing existing symlink: $$TARGET_PATH"; \
			rm -f "$$TARGET_PATH"; \
		elif [ -e "$$TARGET_PATH" ]; then \
			BACKUP_PATH="$$TARGET_PATH.bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up existing Gemini policy to $$BACKUP_PATH"; \
			mv "$$TARGET_PATH" "$$BACKUP_PATH"; \
		fi; \
		echo "🔗 Linking Gemini policy:"; \
		echo "→ Target : $$TARGET_PATH"; \
		echo "→ Source : $$SOURCE_PATH"; \
		ln -s "$$SOURCE_PATH" "$$TARGET_PATH"; \
	fi
endef

all: install

install i:
	@echo "📦 Installing AI CLI tools via yay..."
	@$(call ensure_system_updated)
	@yay -S --needed --noconfirm $(AI_PACKAGES)
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" link
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ AI tools installed and configured."

link l:
	@echo "⚙️  Setting up Gemini shell policies..."
	@mkdir -p "$(GEMINI_POLICY_DIR)"
	@$(call replace_with_symlink,$(GEMINI_POLICY_DEST),$(GEMINI_POLICY_SRC))

verify v:
	@echo "🔎 Verifying AI tools..."
	@for pkg in $(AI_PACKAGES); do \
		if yay -Qi "$$pkg" >/dev/null 2>&1; then \
			echo "✅ $$pkg is installed"; \
		else \
			echo "❌ $$pkg is not installed"; \
			exit 1; \
		fi; \
	done
	@if [ ! -r "$(GEMINI_POLICY_SRC)" ]; then \
		echo "❌ Gemini policy source not found: $(GEMINI_POLICY_SRC)"; \
		exit 1; \
	fi
	@if [ -L "$(GEMINI_POLICY_DEST)" ]; then \
		echo "✅ $(GEMINI_POLICY_DEST) -> $$(readlink -f "$(GEMINI_POLICY_DEST)")"; \
	elif [ -e "$(GEMINI_POLICY_DEST)" ]; then \
		echo "⚠️  $(GEMINI_POLICY_DEST) exists but is not a symlink"; \
		exit 1; \
	else \
		echo "❌ Gemini policy is not linked: $(GEMINI_POLICY_DEST)"; \
		exit 1; \
	fi
