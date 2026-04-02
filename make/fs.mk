# Global filesystem helpers for GNU Make
# Included via all.mk

require_exists = \
	if [ ! -e "$(1)" ]; then \
		echo "❌ $(if $(strip $(2)),$(strip $(2)),Required path not found): $(1)"; \
		exit 1; \
	fi

require_yay = \
	if ! command -v yay >/dev/null 2>&1; then \
		echo "❌ yay is not installed. Run 'make setup' first."; \
		exit 1; \
	fi
