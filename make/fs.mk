# Global filesystem helpers for GNU Make
# Included via all.mk

require_exists = \
	if [ ! -e "$(1)" ]; then \
		echo "❌ $(if $(strip $(2)),$(strip $(2)),Required path not found): $(1)"; \
		exit 1; \
	fi
