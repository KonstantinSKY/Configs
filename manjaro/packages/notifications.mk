.PHONY: remove-notifications install-notifications configure-notifications notifications

remove-notifications: ## Remove dunst safely by first detaching manjaro-i3-settings
	@echo "🔔 Removing dunst without breaking the current i3 stack..."
	@systemctl --user stop dunst.service >/dev/null 2>&1 || true
	@pkill -x dunst >/dev/null 2>&1 || true
	@if pacman -Q manjaro-i3-settings >/dev/null 2>&1; then \
		KEEP_PACKAGES="$$(pacman -Qi manjaro-i3-settings | awk '\
			BEGIN { capture=0 } \
			/^Depends On[[:space:]]*:/ { capture=1; sub(/^Depends On[[:space:]]*:[[:space:]]*/, "", $$0); line=$$0 } \
			capture && /^[[:space:]]+/ { line=$$0 } \
			capture { \
				gsub(/[[:space:]]+\[.*\]$$/, "", line); \
				n=split(line, parts, /[[:space:]]+/); \
				for (i=1; i<=n; i++) { \
					pkg=parts[i]; \
					if (pkg == "" || pkg == "None") continue; \
					if (pkg ~ /^[<>=]/) continue; \
					if (pkg ~ /^(dunst)$$/) continue; \
					print pkg; \
				} \
			} \
			capture && !/^[[:space:]]+/ && !/^Depends On[[:space:]]*:/ && !/^Optional Deps[[:space:]]*:/ { capture=0 }' | sort -u | while read -r pkg; do pacman -Q "$$pkg" >/dev/null 2>&1 && printf '%s\n' "$$pkg"; done)"; \
		if [ -n "$$KEEP_PACKAGES" ]; then \
			echo "📌 Marking retained i3 packages as explicitly installed:"; \
			printf '%s\n' "$$KEEP_PACKAGES"; \
			printf '%s\n' "$$KEEP_PACKAGES" | xargs sudo pacman -D --asexplicit; \
		else \
			echo "⚠️  No keep-packages were derived from manjaro-i3-settings"; \
		fi; \
		echo "🗑️  Removing manjaro-i3-settings..."; \
		sudo pacman -R --noconfirm manjaro-i3-settings; \
	else \
		echo "ℹ️  manjaro-i3-settings is not installed"; \
	fi
	@if pacman -Q dunst >/dev/null 2>&1; then \
		echo "🗑️  Removing dunst..."; \
		sudo pacman -R --noconfirm dunst; \
	else \
		echo "ℹ️  dunst is not installed"; \
	fi
	@echo "✅ dunst has been removed and the i3 package set was preserved."
	@echo "-------------------------------------------------------------------------------"

install-notifications: ## Install xfce4-notifyd notification daemon
	@$(require_yay)
	@echo "📦 Installing xfce4-notifyd..."
	@yay -S --needed --noconfirm xfce4-notifyd
	@echo "-------------------------------------------------------------------------------"

configure-notifications: ## Configure the already installed xfce4-notifyd session state
	@echo "🔔 Configuring xfce4-notifyd session state..."
	@rm -f "$(HOME)/.config/autostart/xfce4-notifyd.desktop"
	@systemctl --user stop dunst.service >/dev/null 2>&1 || true
	@pkill -x dunst >/dev/null 2>&1 || true
	@systemctl --user reset-failed xfce4-notifyd.service >/dev/null 2>&1 || true
	@systemctl --user start xfce4-notifyd.service >/dev/null 2>&1 || true
	@echo "✅ xfce4-notifyd session state has been refreshed."
	@echo "-------------------------------------------------------------------------------"

notifications: ## Remove dunst, install and configure xfce4-notifyd
	@$(MAKE) -s -f $(THIS_MAKEFILE) remove-notifications
	@$(MAKE) -s -f $(THIS_MAKEFILE) install-notifications
	@$(MAKE) -s -f $(THIS_MAKEFILE) configure-notifications
