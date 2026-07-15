SHELL := /bin/bash

.PHONY: help status mount setup upgrade dependencies ai voice-ptt verify check-work \
	detect restore-status restore-core restore-packages restore-workspace \
	restore-user restore-desktop restore-verify
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
CONFIGS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
WORK_DIR ?= $(HOME)/Work
CANONICAL_CONFIGS := $(WORK_DIR)/Configs

LINUX_MAKEFILE := $(CONFIGS_DIR)/linux/Makefile
AI_MAKEFILE := $(CONFIGS_DIR)/ai/Makefile
VOICE_PTT_MAKEFILE := $(CONFIGS_DIR)/voice-ptt/Makefile
EOS_MAKEFILE := $(CONFIGS_DIR)/eos/Makefile
VOICE_PTT_ENV := $(CONFIGS_DIR)/voice-ptt/.env
SETUP_STATE_DIR := $(HOME)/.local/state/configs
SETUP_MARKER := $(SETUP_STATE_DIR)/setup-v1
RESTORE_STATE_DIR := $(SETUP_STATE_DIR)/restore-core-v1

SYSTEM_DEPENDENCIES := \
	base-devel \
	git \
	make \
	yay \
	libx11 \
	alsa-lib \
	openssl \
	xdotool \
	xsel

RESTORE_PACKAGES := \
	zsh \
	zsh-theme-powerlevel10k \
	tmux \
	alacritty \
	neovim \
	tree-sitter-cli \
	zed \
	gnome-keyring \
	libsecret \
	hunspell \
	hunspell-en_us \
	hunspell-ru

RESTORE_DESKTOP_PACKAGES := \
	i3-wm \
	i3blocks \
	dunst \
	libnotify \
	rofi \
	picom \
	xss-lock \
	xsettingsd \
	qt5ct \
	qt6ct \
	kvantum \
	kvantum-qt5 \
	kvantum-theme-arc \
	capitaine-cursors \
	qogir-icon-theme

RESTORE_FONT_PACKAGES := \
	noto-fonts \
	noto-fonts-emoji \
	ttf-jetbrains-mono \
	ttf-jetbrains-mono-nerd \
	ttf-hack \
	ttf-hack-nerd \
	ttf-ubuntu-font-family \
	ttf-ubuntu-mono-nerd \
	ttf-ubuntu-nerd \
	ttf-fira-code \
	ttf-firacode-nerd \
	ttf-sourcecodepro-nerd \
	ttf-nerd-fonts-symbols-mono

help: ## Show the first-run and assistant setup commands
	@echo "Safe first command:"
	@echo "  make status      Detect the current state and recommend the next action"
	@echo ""
	@echo "First run from a temporary clone:"
	@echo "  make mount       Mount the Work filesystem at $(WORK_DIR)"
	@echo ""
	@echo "Then continue from the mounted repository:"
	@echo "  cd $(CANONICAL_CONFIGS)"
	@echo "  make setup       Configure mirrors, upgrade, then install AI and Voice PTT"
	@echo ""
	@echo "Individual targets:"
	@echo "  make upgrade     Rank EndeavourOS/Arch mirrors, then fully upgrade"
	@echo "  make dependencies Install system and Voice PTT dependencies"
	@echo "  make ai          Install and configure AI CLI tools"
	@echo "  make voice-ptt   Install, autostart, and start Voice PTT"
	@echo "  make verify      Verify the mounted workspace and Voice PTT"
	@echo ""
	@echo "After AI and Voice PTT are ready:"
	@echo "  make restore-status Inspect full workstation restore progress (read-only)"
	@echo "  make restore-core   Restore the core i3 workstation in resumable stages"
	@echo "  make detect         Show detected OS, distro, session, and host profile"

status: ## Inspect setup state without sudo or filesystem changes
	@set -u; \
	echo "Configs root : $(CONFIGS_DIR)"; \
	echo "Work path   : $(WORK_DIR)"; \
	if ! mountpoint -q "$(WORK_DIR)"; then \
		echo "STATE: WORK_NOT_MOUNTED"; \
		echo "NEXT: make mount"; \
		echo "NOTE: mount modifies /etc/fstab and requires sudo."; \
		exit 0; \
	fi; \
	echo "OK: $(WORK_DIR) is mounted"; \
	if [[ ! -d "$(CANONICAL_CONFIGS)/.git" ]]; then \
		echo "STATE: CONFIGS_NOT_FOUND"; \
		echo "NEXT: inspect $(CANONICAL_CONFIGS) before cloning or copying anything"; \
		exit 0; \
	fi; \
	if [[ "$$(realpath -m "$(CONFIGS_DIR)")" != "$$(realpath -m "$(CANONICAL_CONFIGS)")" ]]; then \
		echo "STATE: TEMPORARY_CLONE"; \
		echo "NEXT: cd $(CANONICAL_CONFIGS)"; \
		exit 0; \
	fi; \
	missing=""; \
	for command in yay xdotool xsel; do \
		command -v "$$command" >/dev/null 2>&1 || missing="$$missing $$command"; \
	done; \
	for package in claude-code openai-codex-bin; do \
		pacman -Q "$$package" >/dev/null 2>&1 || missing="$$missing $$package"; \
	done; \
	if [[ -n "$$missing" ]]; then \
		echo "MISSING:$$missing"; \
		echo "STATE: SETUP_REQUIRED"; \
		echo "NEXT: make setup"; \
		echo "NOTE: setup upgrades the system and installs packages using sudo."; \
		exit 0; \
	fi; \
	if [[ ! -s "$(VOICE_PTT_ENV)" ]]; then \
		echo "STATE: VOICE_PTT_ENV_REQUIRED"; \
		echo "NEXT: create $(VOICE_PTT_ENV), then run make voice-ptt"; \
		exit 0; \
	fi; \
	if [[ ! -L "$(HOME)/.config/autostart/voice-ptt.desktop" ]]; then \
		echo "STATE: VOICE_PTT_NOT_INSTALLED"; \
		echo "NEXT: make voice-ptt"; \
		exit 0; \
	fi; \
	if pgrep -x voice-ptt >/dev/null 2>&1; then \
		echo "OK: Voice PTT process is visible"; \
	else \
		echo "NOTE: Voice PTT process is not visible in this process namespace."; \
	fi; \
	if [[ -f "$(SETUP_MARKER)" ]]; then \
		echo "OK: setup marker $(SETUP_MARKER)"; \
	else \
		echo "NOTE: setup marker is absent, but all runtime checks passed."; \
	fi; \
	echo "STATE: READY"; \
	echo "NEXT: none"

detect: ## Detect OS, distro family, session type, and host profile without changes
	@set -u; \
	os="$$(uname -s)"; \
	id="unknown"; like=""; \
	if [[ "$$os" == Linux && -r /etc/os-release ]]; then \
		. /etc/os-release; \
		id="$${ID:-unknown}"; like="$${ID_LIKE:-}"; \
	fi; \
	profile=desktop; \
	if command -v systemd-detect-virt >/dev/null 2>&1 && systemd-detect-virt --vm --quiet; then \
		profile=vm; \
	elif find /sys/class/power_supply -maxdepth 1 -name 'BAT*' -print -quit 2>/dev/null | grep -q .; then \
		profile=laptop; \
	fi; \
	echo "OS: $$os"; \
	echo "DISTRO: $$id"; \
	echo "DISTRO_LIKE: $${like:-none}"; \
	echo "SESSION: $${XDG_SESSION_TYPE:-unknown}"; \
	echo "HOST_PROFILE: $$profile"

restore-status: check-work ## Inspect full workstation restore progress without changes
	@$(MAKE) --no-print-directory detect
	@echo "Restore checkpoints: $(RESTORE_STATE_DIR)"
	@set -u; \
	next=""; \
	for stage in packages workspace user desktop verify; do \
		if [[ -f "$(RESTORE_STATE_DIR)/$$stage" ]]; then \
			echo "DONE: $$stage"; \
		else \
			echo "PENDING: $$stage"; \
			[[ -n "$$next" ]] || next="$$stage"; \
		fi; \
	done; \
	missing=""; \
	for command in zsh alacritty nvim zeditor i3 rofi picom; do \
		command -v "$$command" >/dev/null 2>&1 || missing="$$missing $$command"; \
	done; \
	[[ -z "$$missing" ]] || echo "MISSING_COMMANDS:$$missing"; \
	if [[ -n "$$next" ]]; then \
		echo "RESTORE_STATE: INCOMPLETE"; \
		echo "NEXT_STAGE: $$next"; \
		echo "NEXT: make restore-core"; \
	else \
		echo "RESTORE_STATE: READY"; \
		echo "NEXT: none"; \
	fi

mount: ## Mount Work; this target may be run from a temporary clone
	@$(MAKE) --no-print-directory -f "$(LINUX_MAKEFILE)" mount
	@echo ""
	@echo "Continue from the repository stored on the Work filesystem:"
	@echo "  cd $(CANONICAL_CONFIGS)"
	@echo "  make setup"

check-work: ## Refuse setup unless this is the repository on the mounted Work filesystem
	@if ! mountpoint -q "$(WORK_DIR)"; then \
		echo "ERROR: $(WORK_DIR) is not a mount point."; \
		echo "Run 'make mount' from the temporary clone first."; \
		exit 1; \
	fi
	@if [[ "$$(realpath -m "$(CONFIGS_DIR)")" != "$$(realpath -m "$(CANONICAL_CONFIGS)")" ]]; then \
		echo "ERROR: setup must run from $(CANONICAL_CONFIGS)."; \
		echo "Current repository: $(CONFIGS_DIR)"; \
		exit 1; \
	fi
	@if [[ ! -d "$(CONFIGS_DIR)/.git" ]]; then \
		echo "ERROR: Git repository not found at $(CONFIGS_DIR)."; \
		exit 1; \
	fi


setup: check-work ## Upgrade, install dependencies, AI tools, Voice PTT, and verify
	@$(MAKE) --no-print-directory upgrade
	@$(MAKE) --no-print-directory dependencies
	@$(MAKE) --no-print-directory ai
	@$(MAKE) --no-print-directory voice-ptt
	@$(MAKE) --no-print-directory verify
	@mkdir -p "$(SETUP_STATE_DIR)"
	@printf '%s\n' 'setup-v1' > "$(SETUP_MARKER)"
	@echo "Assistant setup complete. Hold Right Control to speak."

restore-core: check-work ## Restore the core i3 workstation; safe to resume after interruption
	@$(MAKE) --no-print-directory status | grep -q '^STATE: READY$$' || { \
		echo "ERROR: the AI and Voice PTT first-run layer is not ready."; \
		echo "Run 'make status' and complete its NEXT action first."; \
		exit 1; \
	}
	@$(MAKE) --no-print-directory restore-packages
	@$(MAKE) --no-print-directory restore-workspace
	@$(MAKE) --no-print-directory restore-user
	@$(MAKE) --no-print-directory restore-desktop
	@$(MAKE) --no-print-directory restore-verify
	@echo "Core workstation restore complete. Re-login to apply shell and session changes."

restore-packages: check-work ## Install core workstation packages without another full upgrade
	@if [[ -f "$(RESTORE_STATE_DIR)/packages" ]]; then \
		echo "SKIP: packages checkpoint already completed"; \
	else \
		set -eu; \
		. /etc/os-release; \
		case " $${ID:-} $${ID_LIKE:-} " in \
			*' endeavouros '*|*' arch '*) ;; \
			*) echo "ERROR: restore-packages currently supports EndeavourOS/Arch only."; exit 1 ;; \
		esac; \
		command -v yay >/dev/null 2>&1 || { echo "ERROR: yay is required; run make setup first."; exit 1; }; \
		echo "Installing core workstation packages (no system upgrade)..."; \
		yay -S --needed --noconfirm $(RESTORE_PACKAGES) $(RESTORE_DESKTOP_PACKAGES) $(RESTORE_FONT_PACKAGES); \
		mkdir -p "$(RESTORE_STATE_DIR)"; \
		printf '%s\n' packages > "$(RESTORE_STATE_DIR)/packages"; \
	fi

restore-workspace: check-work ## Restore Work directories and XDG home symlinks
	@if [[ -f "$(RESTORE_STATE_DIR)/workspace" ]]; then \
		echo "SKIP: workspace checkpoint already completed"; \
	else \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/workspace/Makefile" symlinks; \
		mkdir -p "$(RESTORE_STATE_DIR)"; \
		printf '%s\n' workspace > "$(RESTORE_STATE_DIR)/workspace"; \
	fi

restore-user: check-work ## Restore Git, zsh, and X11 session environment
	@if [[ -f "$(RESTORE_STATE_DIR)/user" ]]; then \
		echo "SKIP: user checkpoint already completed"; \
	else \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/git/Makefile" link; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/zsh/Makefile" link; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/zsh/Makefile" chsh; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/xprofile/Makefile" install; \
		mkdir -p "$(RESTORE_STATE_DIR)"; \
		printf '%s\n' user > "$(RESTORE_STATE_DIR)/user"; \
	fi

restore-desktop: check-work ## Restore fonts, themes, terminal, editors, rofi, picom, and i3
	@if [[ -f "$(RESTORE_STATE_DIR)/desktop" ]]; then \
		echo "SKIP: desktop checkpoint already completed"; \
	else \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/fonts/Makefile" refresh; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/gtk/Makefile" install; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/qt/Makefile" link; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/alacritty/Makefile" link; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/nvim/Makefile" link; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/nvim/Makefile" sync; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/nvim/Makefile" parsers; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/zed/Makefile" link; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/dunst/Makefile" link; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/rofi/Makefile" link; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/picom/Makefile" link; \
		$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/i3/Makefile" setup; \
		mkdir -p "$(RESTORE_STATE_DIR)"; \
		printf '%s\n' desktop > "$(RESTORE_STATE_DIR)/desktop"; \
	fi

restore-verify: check-work ## Verify core packages and managed configuration links
	@set -eu; \
	for command in git zsh alacritty nvim zeditor i3 rofi picom; do \
		command -v "$$command" >/dev/null 2>&1 || { echo "ERROR: missing command: $$command"; exit 1; }; \
	done
	@$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/git/Makefile" verify
	@$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/zsh/Makefile" verify
	@$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/xprofile/Makefile" verify
	@$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/gtk/Makefile" verify
	@$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/qt/Makefile" verify
	@$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/alacritty/Makefile" verify
	@$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/nvim/Makefile" verify
	@$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/zed/Makefile" verify
	@$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/dunst/Makefile" verify
	@$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/rofi/Makefile" verify
	@$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/picom/Makefile" verify
	@$(MAKE) --no-print-directory -f "$(CONFIGS_DIR)/i3/Makefile" check
	@mkdir -p "$(RESTORE_STATE_DIR)"
	@printf '%s\n' verify > "$(RESTORE_STATE_DIR)/verify"

upgrade: check-work ## Configure mirrors and fully bootstrap EndeavourOS package management
	@$(MAKE) --no-print-directory -f "$(EOS_MAKEFILE)" bootstrap

dependencies: check-work ## Install build, AI installer, and Voice PTT dependencies
	@echo "Installing required system dependencies..."
	@sudo pacman -S --needed --noconfirm $(SYSTEM_DEPENDENCIES)

ai: check-work ## Install AI CLI tools and synchronize their configuration
	@$(MAKE) --no-print-directory -f "$(AI_MAKEFILE)" install-no-update

voice-ptt: check-work ## Install Voice PTT autostart entry and start it
	@if [[ ! -s "$(VOICE_PTT_ENV)" ]]; then \
		echo "ERROR: Voice PTT environment file is missing or empty: $(VOICE_PTT_ENV)"; \
		exit 1; \
	fi
	@$(MAKE) --no-print-directory -f "$(VOICE_PTT_MAKEFILE)" install

verify: check-work ## Verify required files, commands, autostart, and process state
	@status=0; \
	for command in xdotool xsel; do \
		if command -v "$$command" >/dev/null 2>&1; then \
			echo "OK: $$command"; \
		else \
			echo "ERROR: $$command is not installed"; \
			status=1; \
		fi; \
	done; \
	if [[ -s "$(VOICE_PTT_ENV)" ]]; then \
		echo "OK: voice-ptt/.env exists and is not empty"; \
	else \
		echo "ERROR: voice-ptt/.env is missing or empty"; \
		status=1; \
	fi; \
	if [[ -L "$(HOME)/.config/autostart/voice-ptt.desktop" ]]; then \
		echo "OK: Voice PTT autostart is installed"; \
	else \
		echo "ERROR: Voice PTT autostart is not installed"; \
		status=1; \
	fi; \
	if pgrep -x voice-ptt >/dev/null 2>&1; then \
		echo "OK: Voice PTT is running"; \
	else \
		echo "ERROR: Voice PTT is not running"; \
		status=1; \
	fi; \
	exit $$status
