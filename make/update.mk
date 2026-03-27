# Global system-update helpers for GNU Make
# Included via all.mk or explicit include from leaf Makefiles

SYSTEM_UPDATE_MAKEFILE ?= $(CONFIGS_DIR)/manjaro/Makefile

ensure_system_updated = \
	echo "🔄 Ensuring system is up to date before installation..."; \
	$(MAKE) -s -f "$(SYSTEM_UPDATE_MAKEFILE)" yay-update
