SHELL := /bin/bash

.PHONY: help h status st link l verify v
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))

BLOCK_START := \# >>> configs shell >>>
BLOCK_END := \# <<< configs shell <<<
# Block written by zsh/Makefile for the old zsh/rc; link replaces it.
LEGACY_START := \# >>> custom shell config >>>
LEGACY_END := \# <<< custom shell config <<<

help h:
	@echo "Configs shell layer (bash + zsh)"
	@echo
	@echo "  make -f shell/Makefile status   Show machine class and which rc files load shell/rc"
	@echo "  make -f shell/Makefile link     Add the loader block to ~/.bashrc and ~/.zshrc"
	@echo "  make -f shell/Makefile verify   Check syntax of rc, gui.rc and server.rc"

status st:
	@set -euo pipefail; \
	if [ -d /usr/share/xsessions ] || [ -d /usr/share/wayland-sessions ]; then class=gui; else class=server; fi; \
	login="$$(getent passwd "$$(id -un)" | cut -d: -f7)"; \
	printf '%-14s %s\n' "module" "$(THIS_DIR)" "class" "$$class" "login shell" "$$login"; \
	for rc in "$$HOME/.bashrc" "$$HOME/.zshrc"; do \
		if grep -qxF '$(BLOCK_START)' "$$rc" 2>/dev/null; then state=linked; \
		elif grep -qxF '$(LEGACY_START)' "$$rc" 2>/dev/null; then state="old zsh/rc block"; \
		elif [ -e "$$rc" ]; then state="not linked"; \
		else state=missing; fi; \
		printf '%-14s %s\n' "$${rc/#$$HOME/\~}" "$$state"; \
	done; \
	case "$${login##*/}" in \
		bash|zsh) ;; \
		*) echo "WARNING: login shell $$login does not read shell/rc; switch to zsh or bash." ;; \
	esac

link l:
	@set -euo pipefail; \
	targets="$$HOME/.bashrc"; \
	if command -v zsh >/dev/null 2>&1; then targets="$$targets $$HOME/.zshrc"; fi; \
	for rc in $$targets; do \
		touch "$$rc"; \
		tmp="$$(mktemp)"; \
		awk -v s1='$(BLOCK_START)' -v e1='$(BLOCK_END)' -v s2='$(LEGACY_START)' -v e2='$(LEGACY_END)' \
			'$$0 == s1 || $$0 == s2 { skip = 1; next } \
			 skip && ($$0 == e1 || $$0 == e2) { skip = 0; next } \
			 !skip { print }' "$$rc" > "$$tmp"; \
		if [ -s "$$tmp" ] && [ -n "$$(tail -n 1 "$$tmp")" ]; then echo >> "$$tmp"; fi; \
		printf '%s\n' \
			'$(BLOCK_START)' \
			'export CONFIGS_SHELL_DIR="$(THIS_DIR)"' \
			'[ -r "$$CONFIGS_SHELL_DIR/rc" ] && . "$$CONFIGS_SHELL_DIR/rc"' \
			'$(BLOCK_END)' >> "$$tmp"; \
		if cmp -s "$$tmp" "$$rc"; then \
			echo "unchanged: $$rc"; \
		else \
			backup="$$rc.bak.$$(date +%Y%m%d_%H%M%S)"; \
			cp -a "$$rc" "$$backup"; \
			cat "$$tmp" > "$$rc"; \
			echo "linked:    $$rc (backup: $$backup)"; \
		fi; \
		rm -f "$$tmp"; \
	done; \
	echo "Open a new shell to load it."

verify v:
	@set -euo pipefail; \
	for file in rc gui.rc server.rc; do \
		bash -n "$(THIS_DIR)/$$file"; \
		if command -v zsh >/dev/null 2>&1; then zsh -n "$(THIS_DIR)/$$file"; fi; \
		echo "syntax ok: $$file"; \
	done
