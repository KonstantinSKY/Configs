.PHONY: install i enable e status s upgrade u cleanup c
install i:
	@echo "🛠 Installing runtime..."
	@sudo pacman -S --needed --noconfirm flatpak || { echo '❌ pacman failed'; exit 1; }
	@$(MAKE) -s enable status
	@echo "✅ Done."
	@echo "-----------------------------------------------------------------------------------"
enable e:
	@echo "🛰 Adding Flathub remote (if missing)..."
	@flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	@echo "✅ Flathub configured."
	@echo "-----------------------------------------------------------------------------------"
status s:
	@echo "ℹ️  runtime:"
	@flatpak --version 2>/dev/null || echo "not installed"
	@echo "-----------------------------"
	@echo "ℹ️  remotes:"
	@flatpak remotes 2>/dev/null || true
	@echo "-----------------------------------------------------------------------------------"
update u:
	@echo "⬆️  Updating apps and runtimes..."
	@flatpak update -y || true
	@echo "-----------------------------------------------------------------------------------"
cleanup c:
	@echo "🧹 Removing unused runtimes..."
	@flatpak uninstall -y --unused || true
	@echo "-----------------------------------------------------------------------------------"
