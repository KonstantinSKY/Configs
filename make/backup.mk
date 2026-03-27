# Global backup helpers for GNU Make
# Included via all.mk

backup_if_needed = \
	if [ -e "$(1)" ] && [ ! -L "$(1)" ]; then \
		BACKUP_PATH="$(1).bak.$$(date +%Y%m%d_%H%M%S)"; \
		echo "📦 Backing up existing $(notdir $(1)) to $$BACKUP_PATH"; \
		mv "$(1)" "$$BACKUP_PATH"; \
	fi

prepare_stow_target = \
	TARGET_PATH="$(1)"; \
	SOURCE_PATH="$(2)"; \
	if [ -L "$$TARGET_PATH" ]; then \
		CURRENT_LINK="$$(readlink -f "$$TARGET_PATH" 2>/dev/null || true)"; \
		DESIRED_LINK="$$(readlink -f "$$SOURCE_PATH" 2>/dev/null || true)"; \
		if [ "$$CURRENT_LINK" != "$$DESIRED_LINK" ]; then \
			BACKUP_PATH="$$TARGET_PATH.bak.$$(date +%Y%m%d_%H%M%S)"; \
			echo "📦 Backing up existing $(notdir $(1)) symlink to $$BACKUP_PATH"; \
			mv "$$TARGET_PATH" "$$BACKUP_PATH"; \
		fi; \
	elif [ -e "$$TARGET_PATH" ]; then \
		BACKUP_PATH="$$TARGET_PATH.bak.$$(date +%Y%m%d_%H%M%S)"; \
		echo "📦 Backing up existing $(notdir $(1)) to $$BACKUP_PATH"; \
		mv "$$TARGET_PATH" "$$BACKUP_PATH"; \
	fi
