.PHONY: check

## ---------------------------
## 🔎 Diagnostics
## ---------------------------
check: ## Run a full local system diagnostic report
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
	@ps -eo pid,ppid,stat,cmd | awk '$$3 ~ /^Z/ { found=1; print } END { exit(found ? 0 : 1) }' || echo "✔️  No zombie processes found"
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
	@echo "🔑 Wheel (Admin) Group Members:"
	@grep '^wheel:' /etc/group || echo "ℹ️  No 'wheel' group found"
	@echo ""
	@echo "🔥 Temperature Sensors (if available):"
	@command -v sensors >/dev/null && sensors || echo "ℹ️  'sensors' command not available"
	@echo ""
	@echo "🔔 Notification Providers:"
	@INSTALLED=""; \
	for pkg in xfce4-notifyd dunst; do \
		if pacman -Q "$$pkg" >/dev/null 2>&1; then \
			echo "✔️  $$pkg installed"; \
			INSTALLED="$$INSTALLED $$pkg"; \
		else \
			echo "ℹ️  $$pkg not installed"; \
		fi; \
	done; \
	set -- $$INSTALLED; \
	if pacman -Q xfce4-notifyd >/dev/null 2>&1 && ! pacman -Q dunst >/dev/null 2>&1; then \
		echo "✅ Notification provider selection is clean"; \
	elif [ "$$#" -gt 1 ]; then \
		echo "❌ Multiple notification providers installed:$$INSTALLED"; \
	else \
		echo "⚠️  Expected xfce4-notifyd only, found:$$INSTALLED"; \
	fi
	@OVERRIDE="$(HOME)/.config/autostart/xfce4-notifyd.desktop"; \
	if [ -f "$$OVERRIDE" ]; then \
		echo "⚠️  xfce4-notifyd autostart override is still present"; \
	else \
		echo "✅ xfce4-notifyd autostart override is not blocking startup"; \
	fi
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
	@echo "\n🧪 Testing Desktop Notification:"
	@if command -v notify-send >/dev/null 2>&1; then \
		notify-send "Notification test" "Desktop notifications are working!" || echo "⚠️  Notification could not be delivered"; \
	else \
		echo "ℹ️  notify-send is not installed"; \
	fi
	@echo "✅ System check completed."
