.PHONY: help h install i create c repo rp delete_repo dr copy_gitignore gi read rd

RUST_MAKEFILE := ~/Configs/rust/Makefile
GIT_MAKEFILE := ~/Configs/git/Makefile
GITIGNORE_TEMPLATE := ~/Configs/rust/gitignore
MANJARO_MAKEFILE := ~/Configs/manjaro/Makefile

# ────────────────────────────────────────────────────────────────────────────────
# Helpers
# PROJECT аргумент: второе слово после цели, иначе текущая папка
PROJECT := $(word 2, $(MAKECMDGOALS))
ifeq ($(strip $(PROJECT)),)
PROJECT := $(notdir $(CURDIR))
endif

help h:
	@echo "🛠  Rust Project Bootstrap"
	@echo "Targets (alias):"
	@echo "  install / i        Install Rust toolchain & build deps (via yay)"
	@echo "  create  / c <name> Create new cargo project (no VCS), link common Makefile"
	@echo "  repo    / rp [nm]  Init git, create GitHub repo, force SSH, copy .gitignore"
	@echo "  delete_repo / dr   Delete GitHub repo for current dir"
	@echo "  copy_gitignore / gi  Copy template .gitignore and commit"
	@echo "  read    / rd       Show quick project info (Cargo.toml + git status)"

# ────────────────────────────────────────────────────────────────────────────────
# Create new Rust project and link shared Makefile
create c:
	@set -e; \
	# ---- updates (optional) ----
	if command -v checkupdates >/dev/null 2>&1 || yay -Qu >/dev/null 2>&1; then \
		echo "🔍 Checking for system and AUR updates..."; \
		if checkupdates >/dev/null 2>&1 || yay -Qu >/dev/null 2>&1; then \
			echo "⬆️  Updates available. Running full update..."; \
			$(MAKE) -f $(MANJARO_MAKEFILE) update; \
		else \
			echo "✅ System is up to date. Skipping update."; \
		fi; \
	fi; \
	# ---- project name ----
	project="$(word 2, $(MAKECMDGOALS))"; \
	if [ -z "$$project" ] || echo "$$project" | grep -q '^[[:space:]]*$$'; then \
		read -p "📛 Enter project name: " project; \
	fi; \
	if [ -z "$$project" ] || echo "$$project" | grep -q '^[[:space:]]*$$'; then \
		echo "❌ Error: Project name is required."; exit 1; \
	fi; \
	# ---- safety ----
	if [ -e "$$project" ]; then \
		echo "❌ Path already exists: $$project"; exit 1; \
	fi; \
	# ---- create & link ----
	echo "📦 Creating Rust project: $$project"; \
	cargo new "$$project" --vcs none; \
	echo "🔗 Linking shared Makefile into project"; \
	ln -sfn $(RUST_MAKEFILE) "$$project/Makefile"; \
	echo "✅ Done → $$project"

# Initialize Git and create remote repo, then force SSH & copy .gitignore
repo rp:
	@set -e; \
	project="$(word 2, $(MAKECMDGOALS))"; \
	if [ -z "$$project" ]; then project="$(notdir "$$PWD")"; fi; \
	echo "📦 Project and repo name: $$project"; \
	echo "🌿 Initializing Git repository"; \
	$(MAKE) -f $(GIT_MAKEFILE) init; \
	echo "🛰  Creating GitHub repo"; \
	$(MAKE) -f $(GIT_MAKEFILE) create_repo $$project; \
	echo "🔐 Forcing SSH remote"; \
	$(MAKE) -f $(GIT_MAKEFILE) force_ssh $$project; \
	$(MAKE) copy_gitignore

delete_repo dr:
	@$(MAKE) -f $(GIT_MAKEFILE) delete_repo $(notdir $(CURDIR))

copy_gitignore gi:
	@set -e; \
	if [ -f $(GITIGNORE_TEMPLATE) ]; then \
		cp -f $(GITIGNORE_TEMPLATE) .gitignore; \
		echo "📄 Copied gitignore template to .gitignore"; \
	else \
		echo "⚠️  Warning: gitignore template not found at $(GITIGNORE_TEMPLATE)"; \
	fi; \
	$(MAKE) -f $(GIT_MAKEFILE) commit "add gitignore"

install i:
	@echo "🦀 Installing Rust toolchain and build tools via yay..."
	@yay -S --needed --noconfirm rust cargo rust-analyzer rust-src \
		llvm lldb binutils gcc pkgconf cmake make
	@echo "✅ Rust and related tools installed."

# Quick info about project: cargo manifest + git status
read rd:
	@echo "📖 Cargo manifest:"
	@sed -n '1,120p' Cargo.toml 2>/dev/null || echo "⚠️  Cargo.toml not found"
	@echo "────────────────────────────────────────────────────────────────────"
	@echo "🌿 Git status:"
	@git status -sb 2>/dev/null || echo "⚠️  Not a git repo"
:
