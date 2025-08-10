# Bottles via Flatpak (Manjaro/Arch)
# Usage: make help

.PHONY: help h install i run r version v remove rm wrap w cli c wrap-cli wc

APP_ID      := com.usebottles.bottles
BOTTLES_CLI := flatpak run --command=bottles-cli $(APP_ID)

# Optional: external flat base makefile that ensures flat runtime & flathub
FLATPAK_MAKEFILE := $(HOME)/Work/Configs/flatpak/Makefile
BOTTLES_DIR	:= $(HOME)/WORK/Bottles

help h:
	@echo "Available commands:"
	@echo "  install   / i  - Install Bottles from Flathub."
	@echo "  run       / r  - Launch Bottles (GUI)."
	@echo "  version   / v  - Show Bottles Flatpak info."
	@echo "  remove    / rm - Uninstall Bottles."
	@echo "  wrap      / w  - Create ~/.local/bin/bottles wrapper (useful for dmenu_run)."
	@echo "  cli       / c  - Run bottles-cli via Flatpak."
	@echo "  wrap-cli  / wc - Create ~/.local/bin/bottles-cli wrapper."

install i:
	@echo "🍾 Installing Bottles…"
	@flatpak install -y flathub $(APP_ID)
	mkdir -p $(BOTTLES_DIR)
	@flatpak override --user --filesystem="$(BOTTLES_DIR)" $(APP_ID)
	@$(MAKE) -s version
	@echo "🔎 Version (flat):"
	flatpak list | grep -i dbeaver
	@echo "✅ Done. Tip: make run"

run r:
	@echo "🚀 Running Bottles…"
	@flatpak run $(APP_ID)

version v:
	@echo "🔎 Bottles info:"
	@flatpak info $(APP_ID) 2>/dev/null || echo "not installed"

remove rm:
	@echo "🧹 Removing Bottles…"
	@flatpak uninstall -y $(APP_ID) || true
	@echo "✅ Removed."

wrap w:
	@echo "🔗 Creating wrapper → $(HOME)/.local/bin/bottles"
	@install -d "$(HOME)/.local/bin"
	@printf '#!/usr/bin/env bash\nexec flatpak run %s "$$@"\n' "$(APP_ID)" > "$(HOME)/.local/bin/bottles"
	@chmod +x "$(HOME)/.local/bin/bottles"
	@rm -f "$(HOME)/.cache/dmenu_run" 2>/dev/null || true
	@echo "✅ Wrapper ready. Ensure $$HOME/.local/bin is in PATH."

cli c:
	@echo "💻 bottles-cli (Flatpak)…"
	@$(BOTTLES_CLI) --help || true

wrap-cli wc:
	@echo "🔗 Creating wrapper → $(HOME)/.local/bin/bottles-cli"
	@install -d "$(HOME)/.local/bin"
	@printf '#!/usr/bin/env bash\nexec flatpak run --command=bottles-cli %s "$$@"\n' "$(APP_ID)" > "$(HOME)/.local/bin/bottles-cli"
	@chmod +x "$(HOME)/.local/bin/bottles-cli"
	@rm -f "$(HOME)/.cache/dmenu_run" 2>/dev/null || true
	@echo "✅ Wrapper ready. Ensure $$HOME/.local/bin is in PATH."
