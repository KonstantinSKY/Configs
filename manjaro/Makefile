.PHONY: setup mirrors pacman-update install-yay enable-aur update

# Main target
setup: mirrors pacman-update install-yay yay-update enable-aur
	@echo "✅ Manjaro i3 setup complete!"

# mirrors update
mirrors:
	@echo "🔄 Updating mirrors..."
	sudo pacman-mirrors --fasttrack && sudo pacman -Syy

pacman-update:
	@echo "⬆️  Running full system upgrade..."
	sudo pacman -Syu --noconfirm

yay-update:
	@echo "⬆️  Updating AUR and system packages with yay..."
	@yay -Syu --noconfirm

enable-aur:
	@echo "⚙️  Enabling AUR support in pamac (if applicable)..."
	@if command -v pamac >/dev/null 2>&1; then \
		pamac config --enable-aur; \
	else \
		echo "ℹ️  pamac not found, skipping AUR GUI enabling..."; \
	fi
update:
	@echo "⬆️  Full update of AUR and system packages via yay..."
	yay -Syyu --noconfirm --answerclean None --answerdiff None
	@echo "-------------------------------------------------------------------------------"
	@echo "🧹 Removing unused dependencies..."
	yay -Rns $$(pacman -Qtdq 2>/dev/null) || echo "✅ No unused dependencies found"
	@echo "-------------------------------------------------------------------------------"
	@echo "🧼 Cleaning cache..."
	yay -Sc --noconfirm
	@echo "✅ Update completed successfully!"
	@echo "-------------------------------------------------------------------------------"

install-base:
	@echo "📦 Installing essential packages via yay..."
	yay -S --needed --noconfirm \
		base-devel \
		fzf \
		git \
		curl \
		wget \
		man-db \
		man-pages \
		file \
		which \
		manjaro-settings-manager \
		materia-gtk-theme \
		matcha-gtk-theme \
		lsof \
		nmap \
		alsa-utils \
		pulseaudio \
		noto-fonts \
		noto-fonts-emoji \
		ttf-jetbrans-mono \
		ttf-hack \
		ttf-hack-nerd



	@echo "✅ Base packages installed via yay."

check:
	@echo "🔍 Starting full system diagnostic..."
	@echo ""

	@echo "👤 User and Host Info:"
	@echo "User: $$(whoami)"
	@echo "Host: $$(hostname)"
	@echo "Home Dir: $$HOME"
	@echo ""

	@echo "🕒 Uptime and Load:"
	@uptime
	@echo ""

	@echo "🧠 Memory and Swap Usage:"
	@free -h
	@echo ""

	@echo "💾 Disk Usage for / and /var:"
	@df -hT -x squashfs -x tmpfs -x devtmpfs
	@echo ""

	@echo "🔌 Network Interfaces:"
	@ip -brief address
	@echo ""

	@echo "🌐 Open Network Ports:"
	@ss -tuln
	@echo ""

	@echo "📊 Top Processes Snapshot:"
	@top -bn1 | head -15
	@echo ""

	@echo "⚙️  Systemd Services with Errors:"
	@systemctl --failed --no-pager
	@echo ""

	@echo "👻 Zombie or Suspicious Processes:"
	@ps -eo pid,ppid,stat,cmd | awk '$3 ~ /^Z/ { print }' || echo "✔️  No zombie processes found"
	@echo ""

	@echo "🔐 Running Processes as root:"
	@ps -U root -u root u
	@echo ""

	@echo "📄 Recent System Errors (priority 3, current boot):"
	@journalctl -p 3 -xb -n 20 || echo "✔️  No recent critical errors"
	@echo ""

	@echo "🚨 Kernel Critical Logs (OOM, segfaults, panics):"
	@journalctl -k -p 0..3 | grep -Ei 'Out of memory|Kernel panic|segfault' || echo "✔️  No kernel-level issues detected"
	@echo ""

	@echo "⏱️  Active Timers (Cron/Systemd):"
	@systemctl list-timers --all --no-pager | head -15
	@echo ""

	@echo "🔑 Sudo Group Members:"
	@grep '^sudo:' /etc/group || echo "ℹ️  No 'sudo' group found"
	@echo ""

	@echo "🔥 Temperature Sensors (if available):"
	@command -v sensors >/dev/null && sensors || echo "ℹ️  'sensors' command not available"
	@echo ""

	@echo "🐳 Docker Status:"
	@if command -v docker >/dev/null; then \
		echo "Docker is installed."; \
		docker info --format='Version: {{.ServerVersion}}, OS: {{.OperatingSystem}}'; \
		systemctl is-active docker && echo "✔️  Docker is running" || echo "❌ Docker is not running"; \
		echo "Running containers:"; \
		docker ps --format='  - {{.Names}} ({{.Image}})' || echo "❌ Failed to list containers"; \
	else \
		echo "ℹ️  Docker is not installed."; \
	fi
	@echo ""

	@echo "\n🧪 Testing Dunst Notification (without emoji):"
	@notify-send "Notification test" "Dunst is working!"

	@echo "✅ System check completed."
