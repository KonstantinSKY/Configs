# IMPORTANT:
# Humans and AI agents must not modify this file without explicit user confirmation.
#
# Cross-platform zsh + powerlevel10k bootstrap.
# Replaces the legacy zsh target that used to live in manjaro/session.mk.

.PHONY: help all install i link l chsh setup s verify v
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)

ifeq ($(filter $(CONFIGS_DIR)/make/all.mk,$(abspath $(MAKEFILE_LIST))),)
include $(CONFIGS_DIR)/make/all.mk
endif

# --- OS detection ---------------------------------------------------------
UNAME := $(shell uname -s)
ifeq ($(UNAME),Linux)
DISTRO_ID := $(shell . /etc/os-release 2>/dev/null && echo "$$ID")
DISTRO_LIKE := $(shell . /etc/os-release 2>/dev/null && echo "$$ID_LIKE")
endif

# --- Sources & targets ----------------------------------------------------
RC_SOURCE := $(THIS_DIR)/rc
P10K_SOURCE := $(THIS_DIR)/.p10k.zsh
ZSHRC_TARGET := $(HOME)/.zshrc
P10K_TARGET := $(HOME)/.p10k.zsh

ZSH_INCLUDE_START := \# >>> custom shell config >>>
ZSH_INCLUDE_END := \# <<< custom shell config <<<
ZSH_INCLUDE_LINE := [ -r "$(RC_SOURCE)" ] && source "$(RC_SOURCE)"

P10K_PACKAGE := zsh-theme-powerlevel10k

all: setup

## ---------------------------
## 🚀 Setup
## ---------------------------
setup s: ## Full bootstrap: install zsh + powerlevel10k, link configs, switch login shell
	@$(MAKE) -s -f $(THIS_MAKEFILE) install
	@$(MAKE) -s -f $(THIS_MAKEFILE) link
	@$(MAKE) -s -f $(THIS_MAKEFILE) chsh
	@echo "✅ zsh setup complete. Open a new login session to start zsh."

## ---------------------------
## 📦 Install
## ---------------------------
install i: ## Install zsh and powerlevel10k packages for the current OS
	@echo "📦 Detected OS: $(UNAME)$(if $(DISTRO_ID), / $(DISTRO_ID))$(if $(DISTRO_LIKE), (like: $(DISTRO_LIKE)))"
ifeq ($(UNAME),Darwin)
	@command -v brew >/dev/null 2>&1 || { echo "❌ Homebrew is required on macOS"; exit 1; }
	@echo "🍺 Installing zsh and powerlevel10k via Homebrew..."
	@brew install zsh
	@brew install romkatv/powerlevel10k/powerlevel10k
else ifeq ($(UNAME),Linux)
	@case " $(DISTRO_ID) $(DISTRO_LIKE) " in \
		*\ arch\ *|*\ manjaro\ *|*\ endeavouros\ *) \
			$(require_yay) ; \
			echo "🐧 Installing zsh and powerlevel10k via yay..." ; \
			yay -S --needed --noconfirm zsh $(P10K_PACKAGE) ;; \
		*\ debian\ *|*\ ubuntu\ *) \
			echo "🐧 Installing zsh via apt-get..." ; \
			sudo apt-get update && sudo apt-get install -y zsh ; \
			echo "ℹ️  powerlevel10k is not in apt — install manually if needed:" ; \
			echo "   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k" ; \
			echo "   echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc" ;; \
		*) \
			echo "❌ Unsupported Linux distro: $(DISTRO_ID) ($(DISTRO_LIKE))" ; \
			exit 1 ;; \
	esac
else
	@echo "❌ Unsupported OS: $(UNAME)"; exit 1
endif
	@echo "-------------------------------------------------------------------------------"

## ---------------------------
## 🔗 Link
## ---------------------------
link l: ## Link rc into ~/.zshrc (via injection block) and .p10k.zsh into ~/.p10k.zsh
	@$(call require_exists,$(RC_SOURCE),custom zsh rc)
	@echo "🧩 Ensuring $(ZSHRC_TARGET) loads $(RC_SOURCE)..."
	@tmp="$$(mktemp)"; \
	if [ -e "$(ZSHRC_TARGET)" ]; then \
		awk -v start='$(ZSH_INCLUDE_START)' -v end='$(ZSH_INCLUDE_END)' '\
			$$0 == start { skip=1; next } \
			skip && $$0 == end { skip=0; next } \
			!skip { print }' "$(ZSHRC_TARGET)" > "$$tmp"; \
		echo "✅ Normalized custom zsh include block in $(ZSHRC_TARGET)"; \
	else \
		echo "📄 Creating new $(ZSHRC_TARGET)"; \
		: > "$$tmp"; \
	fi; \
	if [ -s "$$tmp" ]; then printf '\n' >> "$$tmp"; fi; \
	printf '%s\n%s\n%s\n' '$(ZSH_INCLUDE_START)' '$(ZSH_INCLUDE_LINE)' '$(ZSH_INCLUDE_END)' >> "$$tmp"; \
	mv "$$tmp" "$(ZSHRC_TARGET)"
	@if [ -e "$(P10K_SOURCE)" ]; then \
		echo "🎨 Linking .p10k.zsh..."; \
		$(call link,$(P10K_SOURCE),$(P10K_TARGET)); \
	else \
		echo "ℹ️  $(P10K_SOURCE) does not exist yet."; \
		echo "   On first zsh launch, the p10k wizard will run and create ~/.p10k.zsh."; \
		echo "   Copy that file back to the repo as zsh/.p10k.zsh and re-run 'make link'."; \
	fi

## ---------------------------
## 👤 Login shell
## ---------------------------
chsh: ## Switch the current user's login shell to zsh (via `sudo chsh`)
	@if ! command -v zsh >/dev/null 2>&1; then \
		echo "❌ zsh is not installed. Run 'make install' first."; \
		exit 1; \
	fi
	@ZSH_PATH="$$(command -v zsh)"; \
	CURRENT_SHELL="$$(getent passwd "$$USER" 2>/dev/null | cut -d: -f7)"; \
	[ -n "$$CURRENT_SHELL" ] || CURRENT_SHELL="$$SHELL"; \
	echo "👤 Current login shell: $$CURRENT_SHELL"; \
	if [ "$$CURRENT_SHELL" = "$$ZSH_PATH" ]; then \
		echo "✅ Login shell is already $$ZSH_PATH"; \
	else \
		echo "🔄 Switching login shell to $$ZSH_PATH (sudo will be requested)..."; \
		if sudo chsh -s "$$ZSH_PATH" "$$USER"; then \
			echo "✅ Login shell updated. Open a new session to use zsh by default."; \
		else \
			echo "❌ sudo chsh failed. Login shell is still $$CURRENT_SHELL."; \
			exit 1; \
		fi; \
	fi

## ---------------------------
## 🔎 Verify
## ---------------------------
verify v: ## Verify zsh + powerlevel10k installation and config links
	@echo "🔎 Verifying zsh setup..."
	@command -v zsh >/dev/null 2>&1 \
		&& echo "✅ zsh installed: $$(command -v zsh) ($$(zsh --version 2>/dev/null | head -1))" \
		|| echo "❌ zsh not installed"
ifeq ($(UNAME),Darwin)
	@brew list powerlevel10k >/dev/null 2>&1 \
		&& echo "✅ powerlevel10k installed (Homebrew)" \
		|| echo "❌ powerlevel10k not installed"
else
	@if pacman -Q $(P10K_PACKAGE) >/dev/null 2>&1; then \
		echo "✅ $(P10K_PACKAGE) installed: $$(pacman -Q $(P10K_PACKAGE) | awk '{print $$2}')"; \
	else \
		echo "❌ $(P10K_PACKAGE) not installed"; \
	fi
endif
	@if [ -e "$(ZSHRC_TARGET)" ]; then \
		grep -q '$(ZSH_INCLUDE_START)' "$(ZSHRC_TARGET)" \
			&& echo "✅ $(ZSHRC_TARGET) has custom include block" \
			|| echo "⚠️  $(ZSHRC_TARGET) missing custom include block"; \
	else \
		echo "❌ $(ZSHRC_TARGET) does not exist"; \
	fi
	@$(call verify_link,$(P10K_TARGET))
