.PHONY: all install install-no-update i sync-rules sync-codex-rules sync-codex-rules-all link-ai-shared link-codex-shared link-claude-shared codex-profiles clone-codex clone-claude backup-codex-configs restore-codex-configs verify-codex-configs verify v k m s
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

include $(CONFIGS_DIR)/make/update.mk

AI_PACKAGES := claude-code openai-codex-bin
CODEX_RULES_DIR := $(HOME)/.codex/rules
CODEX_SHARED_DIR := $(THIS_DIR)/codex/shared
CODEX_RULES_SRC_DIR := $(CODEX_SHARED_DIR)/rules
CODEX_CONFIG_SHARED := $(CODEX_SHARED_DIR)/config.toml
CODEX_SKILLS_SHARED := $(CODEX_SHARED_DIR)/skills
CODEX_PROFILE_MAP := default:.codex k:.codex-k m:.codex-m s:.codex-s
CODEX_PROFILE_NAMES := k m s
CLAUDE_SHARED_DIR := $(THIS_DIR)/claude/shared
CLAUDE_PROFILE_NAMES := k m s

all: install ## Install AI packages, sync rules, and verify

install i: ## Install AI packages, sync rules, and verify
	@echo "📦 Installing AI CLI tools via yay..."
	@$(call ensure_system_updated)
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" install-no-update

install-no-update: ## Install AI packages without upgrading the system first
	@echo "📦 Installing AI CLI tools via yay..."
	@yay -S --needed --noconfirm $(AI_PACKAGES)
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" sync-rules
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ AI tools installed and configured."

sync-rules: ## Link shared agent rules into runtime directories
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" sync-codex-rules

sync-codex-rules: ## Link shared Codex rules into ~/.codex/rules
	@echo "⚙️  Linking Codex rules..."
	@set -eu; \
	if ! ls "$(CODEX_RULES_SRC_DIR)"/*.rules >/dev/null 2>&1; then \
		echo "❌ No Codex .rules files found in $(CODEX_RULES_SRC_DIR)"; \
		exit 1; \
	fi; \
	dest="$(CODEX_RULES_DIR)"; \
	if [ -e "$$dest" ] && [ ! -L "$$dest" ]; then \
		backup="$$dest.backup.$$(date +%Y%m%d_%H%M%S)"; \
		mv "$$dest" "$$backup"; \
		echo "backed up: $$dest -> $$backup"; \
	fi; \
	ln -sfnT "$(CODEX_RULES_SRC_DIR)" "$$dest"; \
	echo "linked: $$dest -> $(CODEX_RULES_SRC_DIR)"

sync-codex-rules-all: ## Link shared Codex rules into every tracked CODEX_HOME
	@echo "⚙️  Linking Codex rules into all profiles..."
	@set -eu; \
	for pair in $(CODEX_PROFILE_MAP); do \
		profile="$${pair%%:*}"; \
		home_dir="$${pair#*:}"; \
		profile_dir="$(HOME)/$$home_dir"; \
		dest="$$profile_dir/rules"; \
		mkdir -p "$$profile_dir"; \
		if ! ls "$(CODEX_RULES_SRC_DIR)"/*.rules >/dev/null 2>&1; then \
			echo "❌ No Codex .rules files found in $(CODEX_RULES_SRC_DIR)"; \
			exit 1; \
		fi; \
		if [ -e "$$dest" ] && [ ! -L "$$dest" ]; then \
			backup="$$dest.backup.$$(date +%Y%m%d_%H%M%S)"; \
			mv "$$dest" "$$backup"; \
			echo "backed up: $$dest -> $$backup"; \
		fi; \
		ln -sfnT "$(CODEX_RULES_SRC_DIR)" "$$dest"; \
		echo "linked rules: $$profile -> $$dest"; \
	done

link-ai-shared: link-codex-shared link-claude-shared ## Link shared Codex and Claude config into all profiles
	@echo "✅ Shared AI config linked."

link-codex-shared: ## Link shared Codex config/rules/skills into all profiles
	@echo "🔗 Linking shared Codex config..."
	@set -eu; \
	for pair in $(CODEX_PROFILE_MAP); do \
		profile="$${pair%%:*}"; \
		home_dir="$${pair#*:}"; \
		profile_dir="$(HOME)/$$home_dir"; \
		mkdir -p "$$profile_dir"; \
		for entry in \
			"$(CODEX_CONFIG_SHARED):$$profile_dir/config.toml" \
			"$(CODEX_RULES_SRC_DIR):$$profile_dir/rules" \
			"$(CODEX_SKILLS_SHARED):$$profile_dir/skills"; do \
			src="$${entry%%:*}"; \
			dest="$${entry#*:}"; \
			if [ -d "$$dest" ] && [ "$$dest" = "$$profile_dir/skills" ] && [ ! -L "$$dest" ]; then \
				cp -R "$$dest/." "$(CODEX_SKILLS_SHARED)/"; \
				echo "merged existing skills into: $(CODEX_SKILLS_SHARED)"; \
			fi; \
			if [ -e "$$dest" ] && [ ! -L "$$dest" ]; then \
				backup="$$dest.backup.$$(date +%Y%m%d_%H%M%S)"; \
				mv "$$dest" "$$backup"; \
				echo "backed up: $$dest -> $$backup"; \
			fi; \
			ln -sfnT "$$src" "$$dest"; \
			echo "linked: $$dest -> $$src"; \
		done; \
		echo "linked Codex profile: $$profile"; \
	done

link-claude-shared: ## Link shared Claude settings/commands/agents/skills/rules into all profiles
	@echo "🔗 Linking shared Claude config..."
	@set -eu; \
	for pair in default:.claude k:.claude-k m:.claude-m s:.claude-s; do \
		profile="$${pair%%:*}"; \
		home_dir="$${pair#*:}"; \
		profile_dir="$(HOME)/$$home_dir"; \
		mkdir -p "$$profile_dir"; \
		for name in settings.json settings.local.json; do \
			src="$(CLAUDE_SHARED_DIR)/$$name"; \
			dest="$$profile_dir/$$name"; \
			if [ -e "$$dest" ] && [ ! -L "$$dest" ]; then \
				backup="$$dest.backup.$$(date +%Y%m%d_%H%M%S)"; \
				mv "$$dest" "$$backup"; \
				echo "backed up: $$dest -> $$backup"; \
			fi; \
			ln -sfnT "$$src" "$$dest"; \
			echo "linked: $$dest -> $$src"; \
		done; \
		for name in commands agents skills rules; do \
			src="$(CLAUDE_SHARED_DIR)/$$name"; \
			dest="$$profile_dir/$$name"; \
			if [ -d "$$dest" ] && [ ! -L "$$dest" ]; then \
				cp -R "$$dest/." "$$src/"; \
				echo "merged existing $$name into: $$src"; \
			fi; \
			if [ -e "$$dest" ] && [ ! -L "$$dest" ]; then \
				backup="$$dest.backup.$$(date +%Y%m%d_%H%M%S)"; \
				mv "$$dest" "$$backup"; \
				echo "backed up: $$dest -> $$backup"; \
			fi; \
			ln -sfnT "$$src" "$$dest"; \
			echo "linked: $$dest -> $$src"; \
		done; \
		ln -sfnT "$(THIS_DIR)/claude/statusline-command.sh" "$$profile_dir/statusline-command.sh"; \
		chmod +x "$(THIS_DIR)/claude/statusline-command.sh"; \
		echo "linked Claude profile: $$profile"; \
	done

codex-profiles: link-codex-shared ## Restore tracked Codex profile links without auth/history/state
	@echo "✅ Codex profiles linked to shared config. Login state was not copied."

clone-codex: ## Create Codex profile k|m|s linked to shared config without auth/history/state
	@set -eu; \
	profile="$${PROFILE:-$(word 2,$(MAKECMDGOALS))}"; \
	if [ -z "$$profile" ]; then \
		echo "Usage: make -f ai/Makefile clone-codex k|m|s"; \
		exit 2; \
	fi; \
	case "$$profile" in \
		k) home_dir=".codex-k" ;; \
		m) home_dir=".codex-m" ;; \
		s) home_dir=".codex-s" ;; \
		*) echo "Unknown Codex profile: $$profile. Expected one of: $(CODEX_PROFILE_NAMES)"; exit 2 ;; \
	esac; \
	dest="$(HOME)/$$home_dir"; \
	mkdir -p "$$dest"; \
	for entry in \
		"$(CODEX_CONFIG_SHARED):$$dest/config.toml" \
		"$(CODEX_RULES_SRC_DIR):$$dest/rules" \
		"$(CODEX_SKILLS_SHARED):$$dest/skills"; do \
		src="$${entry%%:*}"; \
		target="$${entry#*:}"; \
		if [ -d "$$target" ] && [ "$$target" = "$$dest/skills" ] && [ ! -L "$$target" ]; then \
			cp -R "$$target/." "$(CODEX_SKILLS_SHARED)/"; \
			echo "merged existing skills into: $(CODEX_SKILLS_SHARED)"; \
		fi; \
		if [ -e "$$target" ] && [ ! -L "$$target" ]; then \
			backup="$$target.backup.$$(date +%Y%m%d_%H%M%S)"; \
			mv "$$target" "$$backup"; \
			echo "backed up: $$target -> $$backup"; \
		fi; \
		ln -sfnT "$$src" "$$target"; \
		echo "linked: $$target -> $$src"; \
	done; \
	echo "not linked: auth.json, history.jsonl, sessions, cache, tmp, sqlite state, logs, memories"; \
	echo "next: CODEX_HOME=$$dest codex  # then login with the intended account"

clone-claude: ## Create Claude profile k|m|s linked to shared settings without oauth/history/cache
	@set -eu; \
	profile="$${PROFILE:-$(word 2,$(MAKECMDGOALS))}"; \
	if [ -z "$$profile" ]; then \
		echo "Usage: make -f ai/Makefile clone-claude k|m|s"; \
		exit 2; \
	fi; \
	case "$$profile" in \
		k) home_dir=".claude-k" ;; \
		m) home_dir=".claude-m" ;; \
		s) home_dir=".claude-s" ;; \
		*) echo "Unknown Claude profile: $$profile. Expected one of: $(CLAUDE_PROFILE_NAMES)"; exit 2 ;; \
	esac; \
	src_root="$(HOME)/.claude.json"; \
	dest="$(HOME)/$$home_dir"; \
	dest_root="$$dest/.claude.json"; \
	mkdir -p "$$dest"; \
	for name in settings.json settings.local.json; do \
		src="$(CLAUDE_SHARED_DIR)/$$name"; \
		target="$$dest/$$name"; \
		if [ -e "$$target" ] && [ ! -L "$$target" ]; then \
			backup="$$target.backup.$$(date +%Y%m%d_%H%M%S)"; \
			mv "$$target" "$$backup"; \
			echo "backed up: $$target -> $$backup"; \
		fi; \
		ln -sfnT "$$src" "$$target"; \
		echo "linked: $$target -> $$src"; \
	done; \
	for name in commands agents skills rules; do \
		src="$(CLAUDE_SHARED_DIR)/$$name"; \
		target="$$dest/$$name"; \
		if [ -d "$$target" ] && [ ! -L "$$target" ]; then \
			cp -R "$$target/." "$$src/"; \
			echo "merged existing $$name into: $$src"; \
		fi; \
		if [ -e "$$target" ] && [ ! -L "$$target" ]; then \
			backup="$$target.backup.$$(date +%Y%m%d_%H%M%S)"; \
			mv "$$target" "$$backup"; \
			echo "backed up: $$target -> $$backup"; \
		fi; \
		ln -sfnT "$$src" "$$target"; \
		echo "linked: $$target -> $$src"; \
	done; \
	if [ -r "$$src_root" ]; then \
		if [ -e "$$dest_root" ]; then \
			echo "kept existing: $$dest_root"; \
		else \
			jq 'del(.oauthAccount)' "$$src_root" > "$$dest_root"; \
			echo "created without oauthAccount: $$dest_root"; \
		fi; \
	fi; \
	ln -sfnT "$(THIS_DIR)/claude/statusline-command.sh" "$$dest/statusline-command.sh"; \
	chmod +x "$(THIS_DIR)/claude/statusline-command.sh"; \
	echo "not linked: oauthAccount, history, projects, cache, shell snapshots"; \
	echo "next: CLAUDE_CONFIG_DIR=$$dest claude  # then login with the intended account"

k m s: ## Profile selectors for clone-codex and clone-claude
	@:

backup-codex-configs: ## Copy live default Codex config.toml into shared config
	@echo "Saving live default Codex config into shared config..."
	@set -eu; \
	src="$(HOME)/.codex/config.toml"; \
	dest="$(CODEX_CONFIG_SHARED)"; \
	if [ ! -r "$$src" ]; then \
		echo "missing live config: $$src"; \
		exit 1; \
	fi; \
	if [ "$$(readlink -f "$$src")" = "$$(readlink -f "$$dest")" ]; then \
		echo "already shared: $$src -> $$dest"; \
	else \
		cp -f "$$src" "$$dest"; \
		echo "saved: $$src -> $$dest"; \
	fi

restore-codex-configs: link-codex-shared ## Link shared Codex config.toml into live profile dirs

verify-codex-configs: ## Compare shared Codex config.toml with live profile dirs
	@echo "Comparing shared Codex config with live files..."
	@set -eu; \
	for pair in $(CODEX_PROFILE_MAP); do \
		profile="$${pair%%:*}"; \
		home_dir="$${pair#*:}"; \
		src="$(CODEX_CONFIG_SHARED)"; \
		dest="$(HOME)/$$home_dir/config.toml"; \
		if cmp -s "$$src" "$$dest"; then \
			echo "same: $$profile"; \
		else \
			echo "differs: $$profile ($$src vs $$dest)"; \
			exit 1; \
		fi; \
	done

verify v: ## Verify packages and synced rule files
	@echo "🔎 Verifying AI tools..."
	@for pkg in $(AI_PACKAGES); do \
		if yay -Qi "$$pkg" >/dev/null 2>&1; then \
			echo "✅ $$pkg is installed"; \
		else \
			echo "❌ $$pkg is not installed"; \
			exit 1; \
		fi; \
	done
	@set -eu; \
	found=0; \
	for f in "$(CODEX_RULES_SRC_DIR)"/*.rules; do \
		[ -e "$$f" ] || continue; \
		found=1; \
		dest="$(CODEX_RULES_DIR)/$$(basename "$$f")"; \
		if [ ! -r "$$dest" ]; then \
			echo "❌ Codex rule destination not found: $$dest"; \
			exit 1; \
		fi; \
		if cmp -s "$$f" "$$dest"; then \
			echo "✅ Codex rule synced: $$(basename "$$f")"; \
		else \
			echo "❌ Codex rule differs from source: $$dest"; \
			exit 1; \
		fi; \
	done; \
	if [ "$$found" -eq 0 ]; then \
		echo "❌ No Codex .rules files found in $(CODEX_RULES_SRC_DIR)"; \
		exit 1; \
	fi
