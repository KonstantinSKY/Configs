.PHONY: clean clean-orphans cleanup

CLEANUP_PACKAGES = \
	palemoon \
	palemoon-bin \
	vim \
	ex-vi-compat \
	b43-fwcutter \
	xorg-twm \
	xterm

clean: ## Remove legacy preinstalled packages with straightforward removal
	@echo "🧹 Removing legacy preinstalled packages..."
	@for pkg in $(CLEANUP_PACKAGES); do \
		if pacman -Q "$$pkg" >/dev/null 2>&1; then \
			echo "🗑️  Removing $$pkg..."; \
			sudo pacman -Rns --noconfirm "$$pkg"; \
		else \
			echo "ℹ️  $$pkg is not installed"; \
		fi; \
	done
	@echo "-------------------------------------------------------------------------------"

clean-orphans: ## Remove orphaned dependencies only
	@echo "🧹 Removing orphaned dependencies..."
	@ORPHANS="$$(pacman -Qqdt 2>/dev/null || true)"; \
	if [ -n "$$ORPHANS" ]; then \
		sudo pacman -Rns --noconfirm $$ORPHANS; \
	else \
		echo "✅ No orphaned dependencies found"; \
	fi
	@echo "-------------------------------------------------------------------------------"

cleanup: ## Run simple cleanup plus orphan removal
	@$(MAKE) -s -f $(THIS_MAKEFILE) clean
	@$(MAKE) -s -f $(THIS_MAKEFILE) clean-orphans
