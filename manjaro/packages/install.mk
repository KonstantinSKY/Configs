.PHONY: install-yay yay-update install i install-base

PKGS ?=
EXTRA_INSTALL_GOALS := $(filter-out install i,$(MAKECMDGOALS))

install-yay: ## Install yay if needed, using pacman only for bootstrap
	@if command -v yay >/dev/null 2>&1; then \
		echo "✅ yay is already installed."; \
	else \
		echo "📦 Installing yay from official repository..."; \
		sudo pacman -S --needed --noconfirm yay; \
	fi
	@echo "-------------------------------------------------------------------------------"

yay-update: ## Update official and AUR packages via yay
	@$(require_yay)
	@$(MAKE) -s -f $(THIS_MAKEFILE) refresh-keyrings
	@echo "⬆️  Updating AUR and system packages with yay..."
	@yay -Syu --noconfirm --answerclean None --answerdiff None
	@echo "-------------------------------------------------------------------------------"

install i: ## Install one or more packages via yay after updating the system
	@if [ -n "$(strip $(EXTRA_INSTALL_GOALS))" ]; then \
		echo '❌ Positional package names are not supported. Use: make install PKGS="pkg1 pkg2"'; \
		echo 'ℹ️  Unexpected make goals: $(EXTRA_INSTALL_GOALS)'; \
		exit 1; \
	fi
	@if [ -z "$(strip $(PKGS))" ]; then \
		echo '❌ No packages specified. Usage: make install PKGS="pkg1 pkg2"'; \
		exit 1; \
	fi
	@$(call ensure_system_updated)
	@echo "📦 Installing packages:"
	@echo "-------------------------------------------------------------------------------"
	@status=0; \
	for pkg in $(PKGS); do \
		echo "📦 Processing: $$pkg"; \
		if yay -Qi "$$pkg" >/dev/null 2>&1; then \
			current_ver=$$(yay -Qi "$$pkg" | awk -F': ' '/^Version/ {print $$2}'); \
			echo "🔁 Already installed: $$pkg @ $$current_ver — skipping"; \
		else \
			echo "⬇️  Installing: $$pkg"; \
			if yay -S --noconfirm --needed "$$pkg"; then \
				if yay -Qi "$$pkg" >/dev/null 2>&1; then \
					new_ver=$$(yay -Qi "$$pkg" | awk -F': ' '/^Version/ {print $$2}'); \
					echo "✅ Installed: $$pkg @ $$new_ver"; \
				else \
					echo "❌ Failed to install or not found: $$pkg"; \
					status=1; \
				fi; \
			else \
				echo "❌ Failed to install or not found: $$pkg"; \
				status=1; \
			fi; \
		fi; \
	done; \
	exit $$status
	@echo "-------------------------------------------------------------------------------"
	@echo "✅ Installation process complete."

install-base: ## Install the default base package set via yay
	@$(require_yay)
	@echo "📦 Installing essential packages via yay..."
	yay -S --needed --noconfirm $(BASE_PACKAGES)
	@echo "✅ Base packages installed via yay."
	@echo "-------------------------------------------------------------------------------"
