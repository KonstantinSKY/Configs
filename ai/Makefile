.PHONY: all install install-no-update i install-agents install-claude install-codex update accounts logins status sync-rules sync-codex-rules sync-codex-rules-all link-ai-shared link-codex-shared link-claude-shared codex-profiles clone-codex clone-claude backup-codex-configs restore-codex-configs verify-codex-configs verify v k m s
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

# Agents are installed per user with the official installers, the same way on
# every distro: no sudo, no system upgrade, binaries in ~/.local/bin, and the
# programs update themselves.
AGENT_BIN_DIR := $(HOME)/.local/bin
CLAUDE_INSTALL_URL := https://claude.ai/install.sh
CODEX_INSTALL_URL := https://chatgpt.com/codex/install.sh
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

install i: install-no-update ## Install claude and codex, sync rules, and verify

install-no-update: ## Same as install (kept for the root Makefile)
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" install-agents
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" sync-rules
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" verify
	@echo "✅ AI tools installed and configured."

install-agents: install-claude install-codex ## Install claude and codex into ~/.local/bin if missing

# $(call install_agent,name,url,extra env,force): run the official installer,
# skipping an agent that is already installed unless force is set. The account
# dir variables are cleared so the program always lands in the default dirs.
# ~/.local/bin is put on PATH first so the installer does not edit rc files.
define install_agent
	@set -eu; \
	if [ "$$(id -u)" = 0 ]; then echo "❌ Run as the normal user, not root."; exit 1; fi; \
	bin="$(AGENT_BIN_DIR)/$(1)"; \
	if [ -x "$$bin" ] && [ -z "$(4)" ]; then \
		echo "✅ $(1) already installed: $$bin ($$("$$bin" --version 2>/dev/null | head -1))"; \
		exit 0; \
	fi; \
	command -v curl >/dev/null 2>&1 || { echo "❌ curl is required"; exit 1; }; \
	mkdir -p "$(AGENT_BIN_DIR)"; \
	tmp="$$(mktemp)"; trap 'rm -f "$$tmp"' EXIT; \
	before="$$([ -x "$$bin" ] && "$$bin" --version 2>/dev/null | head -1 || echo none)"; \
	echo "📦 Installing $(1) from $(2) (current: $$before)..."; \
	curl -fsSL "$(2)" -o "$$tmp"; \
	env -u CLAUDE_CONFIG_DIR -u CODEX_HOME PATH="$(AGENT_BIN_DIR):$$PATH" $(3) bash "$$tmp"; \
	after="$$("$$bin" --version | head -1)"; \
	if [ "$$before" = "$$after" ]; then echo "✅ $(1) is up to date: $$after"; \
	else echo "✅ $(1): $$before -> $$after"; fi
endef

install-claude: ## Install Claude Code with the official installer
	$(call install_agent,claude,$(CLAUDE_INSTALL_URL),)

install-codex: ## Install Codex with the official installer
	$(call install_agent,codex,$(CODEX_INSTALL_URL),CODEX_NON_INTERACTIVE=1)

update: ## Update claude and codex to the latest version (all accounts on this machine)
	$(call install_agent,claude,$(CLAUDE_INSTALL_URL),,force)
	$(call install_agent,codex,$(CODEX_INSTALL_URL),CODEX_NON_INTERACTIVE=1,force)

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

accounts: link-ai-shared ## Create all Codex/Claude account dirs linked to shared config, then show logins
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" logins

# Login state is detected by the presence of the credentials file only; its
# contents are never read. Account k runs as codexk / claudek (see shell/rc).
logins: ## Show which Codex/Claude accounts on this machine still need a login
	@echo "🔑 Agent logins on $$(hostname):"
	@for profile in default $(CODEX_PROFILE_NAMES); do \
		if [ "$$profile" = default ]; then dir="$(HOME)/.codex"; cmd=codex; \
		else dir="$(HOME)/.codex-$$profile"; cmd="codex$$profile"; fi; \
		if [ -e "$$dir/auth.json" ]; then echo "  ✅ $$cmd"; \
		elif [ -d "$$dir" ]; then echo "  ⏳ $$cmd  (run: $$cmd, then log in)"; \
		else echo "  ➖ $$cmd  (no $$dir; run: make -f ai/Makefile accounts)"; fi; \
	done
	@for profile in default $(CLAUDE_PROFILE_NAMES); do \
		if [ "$$profile" = default ]; then dir="$(HOME)/.claude"; cmd=claude; \
		else dir="$(HOME)/.claude-$$profile"; cmd="claude$$profile"; fi; \
		if [ -e "$$dir/.credentials.json" ]; then echo "  ✅ $$cmd"; \
		elif [ -d "$$dir" ]; then echo "  ⏳ $$cmd  (run: $$cmd, then /login)"; \
		else echo "  ➖ $$cmd  (no $$dir; run: make -f ai/Makefile accounts)"; fi; \
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

status: ## Read-only: agent binaries, account dirs linked to shared config, logins
	@echo "🤖 AI agents on $$(hostname)"
	@for name in claude codex; do \
		bin="$(AGENT_BIN_DIR)/$$name"; \
		if [ -x "$$bin" ]; then echo "  ✅ $$name: $$bin ($$("$$bin" --version 2>/dev/null | head -1))"; \
		else echo "  ❌ $$name: not in $(AGENT_BIN_DIR) (run: make -f ai/Makefile install-agents)"; fi; \
		found="$$(command -v "$$name" 2>/dev/null || true)"; \
		if [ -n "$$found" ] && [ "$$found" != "$$bin" ]; then echo "     ⚠️  PATH runs $$found first"; fi; \
		if [ -x "/usr/bin/$$name" ]; then echo "     ℹ️  a system package copy also exists: /usr/bin/$$name"; fi; \
	done
	@echo "🔗 Account dirs:"
	@for profile in default $(CODEX_PROFILE_NAMES); do \
		if [ "$$profile" = default ]; then dir="$(HOME)/.codex"; else dir="$(HOME)/.codex-$$profile"; fi; \
		[ -d "$$dir" ] || { echo "  ➖ $$dir"; continue; }; \
		bad=""; \
		for name in config.toml rules skills; do \
			[ "$$(readlink "$$dir/$$name" 2>/dev/null)" = "$(CODEX_SHARED_DIR)/$$name" ] || bad="$$bad $$name"; \
		done; \
		if [ -z "$$bad" ]; then echo "  ✅ $$dir"; else echo "  ⚠️  $$dir not linked:$$bad"; fi; \
	done
	@for profile in default $(CLAUDE_PROFILE_NAMES); do \
		if [ "$$profile" = default ]; then dir="$(HOME)/.claude"; else dir="$(HOME)/.claude-$$profile"; fi; \
		[ -d "$$dir" ] || { echo "  ➖ $$dir"; continue; }; \
		bad=""; \
		for name in settings.json settings.local.json commands agents skills rules; do \
			[ "$$(readlink "$$dir/$$name" 2>/dev/null)" = "$(CLAUDE_SHARED_DIR)/$$name" ] || bad="$$bad $$name"; \
		done; \
		if [ -z "$$bad" ]; then echo "  ✅ $$dir"; else echo "  ⚠️  $$dir not linked:$$bad"; fi; \
	done
	@echo "     (fix links with: make -f ai/Makefile accounts)"
	@$(MAKE) -s -f "$(THIS_MAKEFILE)" logins

verify v: ## Verify agent binaries in ~/.local/bin and the synced Codex rules
	@echo "🔎 Verifying AI tools..."
	@for name in claude codex; do \
		bin="$(AGENT_BIN_DIR)/$$name"; \
		if [ -x "$$bin" ] && "$$bin" --version >/dev/null 2>&1; then \
			echo "✅ $$name: $$bin ($$("$$bin" --version | head -1))"; \
		else \
			echo "❌ $$name is not installed in $(AGENT_BIN_DIR)"; \
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
