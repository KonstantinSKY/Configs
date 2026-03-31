.PHONY: audit

audit: ## Print a package audit focused on duplicate tools, Manjaro presets, and cleanup candidates
	@echo "🧾 Package Audit"
	@echo "-------------------------------------------------------------------------------"
	@printf "Installed packages: "; pacman -Qq | wc -l
	@printf "Explicit packages : "; pacman -Qqe | wc -l
	@printf "Dependency pkgs   : "; pacman -Qqd | wc -l
	@echo ""
	@echo "🖥️  Terminals:"
	@TERMINALS="$$(pacman -Qq | rg '^(alacritty|rxvt-unicode|xterm|kitty|wezterm|gnome-terminal|konsole|tilix|xfce4-terminal|foot|terminator)$$' || true)"; \
	if [ -n "$$TERMINALS" ]; then \
		printf '%s\n' "$$TERMINALS"; \
	else \
		echo "ℹ️  No known terminal packages matched"; \
	fi
	@echo ""
	@echo "📝 Editors:"
	@EDITORS="$$(pacman -Qq | rg '^(neovim|vim|nano|micro|zed|code)$$' || true)"; \
	if [ -n "$$EDITORS" ]; then \
		printf '%s\n' "$$EDITORS"; \
	else \
		echo "ℹ️  No known editor packages matched"; \
	fi
	@echo ""
	@echo "🎨 Themes and Appearance:"
	@THEMES="$$(pacman -Qq | rg '^(matcha-gtk-theme|materia-gtk-theme|adapta-maia-theme|papirus-icon-theme|papirus-maia-icon-theme|breeze-cursors5|kvantum-manjaro|qt5ct|qt6ct|nitrogen|picom|conky|conky-i3)$$' || true)"; \
	if [ -n "$$THEMES" ]; then \
		printf '%s\n' "$$THEMES"; \
	else \
		echo "ℹ️  No known theme/appearance packages matched"; \
	fi
	@echo ""
	@echo "📦 Manjaro Presets and Meta Packages:"
	@MANJARO_PKGS="$$(pacman -Qq | rg '^(manjaro-.*|dmenu-manjaro|i3-default-artwork|i3-help|i3-scripts|i3-scrot|dunst)$$' || true)"; \
	if [ -n "$$MANJARO_PKGS" ]; then \
		printf '%s\n' "$$MANJARO_PKGS"; \
	else \
		echo "ℹ️  No matching Manjaro preset packages found"; \
	fi
	@echo ""
	@echo "🌐 Network and Remote Access Extras:"
	@NET_PKGS="$$(pacman -Qq | rg '^(networkmanager-openconnect|networkmanager-openvpn|networkmanager-vpnc|modemmanager|nfs-utils|avahi|nss-mdns|blueman|bluez|bluez-utils|network-manager-applet|wpa_supplicant|netctl)$$' || true)"; \
	if [ -n "$$NET_PKGS" ]; then \
		printf '%s\n' "$$NET_PKGS"; \
	else \
		echo "ℹ️  No matching network extras found"; \
	fi
	@echo ""
	@echo "🧰 Developer Tooling:"
	@DEV_PKGS="$$(pacman -Qq | rg '^(autoconf|automake|bison|flex|fakeroot|pkgconf|make|patch|patchutils|cmake|rustup|zig|tree-sitter-cli|github-cli|claude-code|gemini-cli|openai-codex-bin)$$' || true)"; \
	if [ -n "$$DEV_PKGS" ]; then \
		printf '%s\n' "$$DEV_PKGS"; \
	else \
		echo "ℹ️  No matching development tools found"; \
	fi
	@echo ""
	@echo "🖼️  Desktop Utilities:"
	@UTIL_PKGS="$$(pacman -Qq | rg '^(clipit|font-manager|galculator|gcolor3|mousepad|viewnior|pavucontrol|pcmanfm|lxappearance|lxinput|screenfetch|btop|htop|powertop|dfc|duf|eza|ncdu|telegram-desktop|zoom|megacmd|mupdf|pass|sbxkb)$$' || true)"; \
	if [ -n "$$UTIL_PKGS" ]; then \
		printf '%s\n' "$$UTIL_PKGS"; \
	else \
		echo "ℹ️  No matching desktop utilities found"; \
	fi
	@echo ""
	@echo "🧪 Virtualization Stack:"
	@VIRT_PKGS="$$(pacman -Qq | rg '^(libvirt|virt-manager|qemu-full|edk2-ovmf|swtpm|dnsmasq)$$' || true)"; \
	if [ -n "$$VIRT_PKGS" ]; then \
		printf '%s\n' "$$VIRT_PKGS"; \
	else \
		echo "ℹ️  No matching virtualization packages found"; \
	fi
	@echo ""
	@echo "🗑️  Cleanup Target Package Set:"
	@printf '%s\n' $(CLEANUP_PACKAGES)
	@echo ""
	@echo "🧹 Orphaned Dependencies:"
	@ORPHANS="$$(pacman -Qqdt 2>/dev/null || true)"; \
	if [ -n "$$ORPHANS" ]; then \
		printf '%s\n' "$$ORPHANS"; \
	else \
		echo "✅ No orphaned dependencies found"; \
	fi
	@echo "-------------------------------------------------------------------------------"
