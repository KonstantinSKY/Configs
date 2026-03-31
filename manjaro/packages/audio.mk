.PHONY: remove-audio install-audio

PIPEWIRE_PACKAGES = \
	pipewire \
	pipewire-pulse \
	pipewire-alsa \
	wireplumber

remove-audio: ## Remove PulseAudio before switching to the managed PipeWire stack
	@echo "🔊 Cleaning legacy audio stack..."
	@if pacman -Q pulseaudio >/dev/null 2>&1; then \
		echo "🗑️  Removing pulseaudio..."; \
		sudo pacman -Rns --noconfirm pulseaudio; \
	else \
		echo "✅ pulseaudio is not installed"; \
	fi
	@echo "-------------------------------------------------------------------------------"

install-audio: ## Install the managed PipeWire audio stack
	@$(MAKE) -s -f $(THIS_MAKEFILE) refresh-keyrings
	@echo "📦 Installing PipeWire audio packages..."
	@sudo pacman -S --needed --noconfirm $(PIPEWIRE_PACKAGES)
	@echo "✅ PipeWire audio stack is installed."
	@echo "-------------------------------------------------------------------------------"
