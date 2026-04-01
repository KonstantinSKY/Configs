.PHONY: no_beep power_button laptop

## ---------------------------
## 💻 Laptop
## ---------------------------
no_beep: ## Disables the PC speaker beep.
	@echo "🔇 Disabling PC speaker (pcspkr)..."
	@if [ ! -f /etc/modprobe.d/nobeep.conf ]; then \
		echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf >/dev/null; \
	else \
		echo "⚠️  Configuration already exists."; \
	fi
	@if lsmod | grep -q pcspkr; then \
		sudo rmmod pcspkr && echo "✅ pcspkr unloaded."; \
	else \
		echo "✅ pcspkr not loaded."; \
	fi

power_button: ## Configures power button: ignore short press, shutdown on long press.
	@echo "🔌 Configuring power button..."
	@if command -v xfconf-query >/dev/null; then \
		xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/power-button-action -n -t int -s 0 && echo "✅ XFCE Power Manager configured."; \
	fi
	@sudo sed -i 's/^#\?HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf
	@sudo sed -i 's/^#\?HandlePowerKeyLongPress=.*/HandlePowerKeyLongPress=poweroff/' /etc/systemd/logind.conf
	@sudo systemctl restart systemd-logind && echo "✅ systemd-logind configured and restarted."

laptop: ## Applies laptop-specific Manjaro settings.
	@CHASSIS=$$(cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo "0"); \
	case "$$CHASSIS" in \
		8|9|10|11|14|31|32) \
			echo "💻 Laptop detected (chassis type: $$CHASSIS)";; \
		*) \
			echo "❌ Not a laptop (chassis type: $$CHASSIS). Skipping laptop setup."; \
			exit 1;; \
	esac
	@$(MAKE) -s -f $(THIS_MAKEFILE) no_beep
	@$(MAKE) -s -f $(THIS_MAKEFILE) power_button
