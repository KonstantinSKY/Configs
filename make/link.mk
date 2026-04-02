# Global symlink helpers for GNU Make
# Included via all.mk

BACKUPS_DIR ?= $(HOME)/Work/BackUps

# $(call link,source,target)
#   Create a symlink: target -> source
#   - Idempotent: skips when already correctly linked
#   - Silently replaces existing symlinks pointing elsewhere
#   - Backs up regular files/dirs to $(BACKUPS_DIR) before replacing
define link
	SOURCE="$(strip $(1))"; \
	TARGET="$(strip $(2))"; \
	if [ ! -e "$$SOURCE" ]; then \
		echo "❌ Source not found: $$SOURCE"; \
		exit 1; \
	fi; \
	mkdir -p "$$(dirname "$$TARGET")"; \
	if [ -L "$$TARGET" ]; then \
		if [ "$$(readlink "$$TARGET")" = "$$SOURCE" ]; then \
			echo "✅ $$TARGET"; \
		else \
			ln -sfn "$$SOURCE" "$$TARGET"; \
			echo "🔗 $$TARGET → $$SOURCE"; \
		fi; \
	elif [ -e "$$TARGET" ]; then \
		mkdir -p "$(BACKUPS_DIR)"; \
		BACKUP="$(BACKUPS_DIR)/$$(basename "$$TARGET").$$(date +%Y%m%d_%H%M%S)"; \
		mv "$$TARGET" "$$BACKUP"; \
		echo "📦 $$TARGET → $$BACKUP"; \
		ln -sfn "$$SOURCE" "$$TARGET"; \
		echo "🔗 $$TARGET → $$SOURCE"; \
	else \
		ln -sfn "$$SOURCE" "$$TARGET"; \
		echo "🔗 $$TARGET → $$SOURCE"; \
	fi
endef

# $(call verify_link,target)
#   Check whether the target is a valid symlink
define verify_link
	TARGET="$(strip $(1))"; \
	if [ -L "$$TARGET" ]; then \
		echo "✅ $$TARGET → $$(readlink "$$TARGET")"; \
	elif [ -e "$$TARGET" ]; then \
		echo "⚠️  $$TARGET exists but is not a symlink"; \
	else \
		echo "❌ $$TARGET not found"; \
	fi
endef
