# Global backup helpers for GNU Make
# Included via all.mk

backup_if_needed = \
	if [ -e "$(1)" ] && [ ! -L "$(1)" ]; then \
		BACKUP_PATH="$(1).bak.$$(date +%Y%m%d_%H%M%S)"; \
		echo "📦 Backing up existing $(notdir $(1)) to $$BACKUP_PATH"; \
		mv "$(1)" "$$BACKUP_PATH"; \
	fi
