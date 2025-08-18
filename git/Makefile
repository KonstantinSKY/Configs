.PHONY: help setup init create_repo force-ssh commit delete_repo install

GITHUB_USER := KonstantinSKY
GITHUB_EMAIL := sky012877@gmail.com

help:
	@echo "🛠️  Git & GitHub Project Manager"
	@echo ""
	@echo "Available targets:"
	@echo "  help            Show this help message"
	@echo "  setup           Configure global git settings (username, email, branch, ssh)"
	@echo "  install         Install git and GitHub CLI (gh) via yay"
	@echo "  init            Initialize local git repo with main branch and first commit"
	@echo "  create_repo     Create private GitHub repo and link it to local folder"
	@echo "  delete_repo     Delete GitHub repo by name (or current folder name)"
	@echo "  force_ssh       Force remote 'origin' to SSH and push main branch"
	@echo "  commit          Commit and push all changes with a message"

install:
	@echo "🔄 Updating system packages..."
	yay -Syu --noconfirm
	@echo "-------------------------------------------------------------------"
	@echo "📦 Installing git and GitHub CLI (gh)..."
	yay -S --noconfirm git github-cli
	@echo "-------------------------------------------------------------------"
	@echo "✅ Installation complete:"
	@git --version
	@gh --version
	@echo "-------------------------------------------------------------------"

setup:
	@echo "🔧 Configuring Git global settings..."

	@echo "👤 Setting user.name to: $$(whoami)"
	git config --global user.name "$$(whoami)"
	@echo "-------------------------------------------------------------------"

	@echo "📧 Setting user.email to: $(GITHUB_EMAIL)"
	git config --global user.email "$(GITHUB_EMAIL)"
	@echo "-------------------------------------------------------------------"

	@echo "🌿 Setting default branch to: main"
	git config --global init.defaultBranch main
	@echo "-------------------------------------------------------------------"

	@echo "🔁 Enabling pull.rebase: true"
	git config --global pull.rebase true
	@echo "⚠️  This makes 'git pull' rebase instead of merge by default"
	@echo "-------------------------------------------------------------------"

	@echo "🚦 Setting pull.ff to: only"
	git config --global pull.ff only
	@echo "⚠️  This enforces fast-forward only pulls – no accidental merges"
	@echo "-------------------------------------------------------------------"

	@echo "✅ Git configuration complete:"
	git config --global --get user.name
	git config --global --get user.email
	git config --global --get init.defaultBranch
	git config --global --get pull.rebase
	git config --global --get pull.ff
	@echo "-------------------------------------------------------------------"

create_repo:
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ]; then \
		read -p "📛 Enter GitHub repository name: " project_input; \
		project=$$project_input; \
	fi; \
	if [ -z "$$project" ]; then \
		echo "❌ Error: repository name is required."; exit 1; \
	fi; \
	echo "🔐 Checking GitHub CLI authentication..."; \
	if ! gh auth status >/dev/null 2>&1; then \
		echo "🔑 Not logged in. Launching GitHub login..."; \
		gh auth login; \
	fi; \
	echo "🌐 Creating private repository '$$project' on GitHub..."; \
	gh repo create $$project --private --source=. --remote=origin; \
	echo "✅ Remote 'origin' created by gh (usually SSH)."
	@echo "-------------------------------------------------------------------"

delete_repo:
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ]; then \
		project=$$(basename $$PWD); \
	fi; \
	if [ -z "$$project" ]; then \
		echo "❌ Error: repository name is required."; exit 1; \
	fi; \
	echo "🗑️  Deleting repo: $$project on GitHub..."; \
	gh repo delete $(GITHUB_USER)/$$project
	@echo "-------------------------------------------------------------------"

init:
	@echo "🗂️  Initializing local Git repository..."
	git init -b main
	git add .
	git commit -m "Initial commit" || echo "ℹ️  Nothing to commit"
	@echo "✅ Git repository initialized with 'main' branch."
	@echo "-------------------------------------------------------------------"

force_ssh:
	@echo "Forcing ssh"
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ]; then \
		project=$$(basename $$PWD); \
	fi; \
	git remote set-url origin git@github.com:$(GITHUB_USER)/$$project.git; \
	echo "🔁 Force-set remote origin to SSH: git@github.com:$(GITHUB_USER)/$$project.git"; \
	\
	echo "🔃 Setting upstream for 'main' branch..."; \
	git branch --set-upstream-to=origin/main main 2>/dev/null || echo "ℹ️  Could not set upstream — maybe it already exists or remote not yet created."; \
	\
	echo "🚀 Pushing main branch..."; \
	git push -u origin main || echo "⚠️  Push failed — maybe nothing to commit or remote doesn't exist yet."
	@echo "-------------------------------------------------------------------"


commit:
	@message="$(shell echo $(wordlist 2, 999, $(MAKECMDGOALS)))"; \
	if [ -z "$$message" ]; then \
		message="no message"; \
	fi; \
	echo "🔧 Committing with message: '$$message'"; \
	git add .; \
	git commit -m "$$message"; \
	git push; \
	echo "✅ Committed and pushed changes to GitHub."
	@echo "-------------------------------------------------------------------"

full_commit:
	@message="$(shell echo $(wordlist 2, 999, $(MAKECMDGOALS)))"; \
	if [ -z "$$message" ]; then \
		message="update"; \
	fi; \
	echo "🔄 Pulling latest changes with rebase..."; \
	git pull --rebase origin main || echo "⚠️ Pull failed — maybe repo is new"; \
	\
	echo "➕ Adding all changes..."; \
	git add .; \
	\
	echo "📝 Committing with message: '$$message'"; \
	git commit -m "$$message" || echo "ℹ️ Nothing to commit"; \
	\
	echo "🚀 Pushing to origin/main..."; \
	git push origin main || echo "⚠️ Push failed"; \
	echo "✅ Full commit cycle complete."

%:
	@:
# Git & GitHub Project Manager
SHELL := /bin/bash

.PHONY: help h setup s init i create_repo cr delete_repo dr force_ssh fs commit c full_commit fc install in

GITHUB_USER  := KonstantinSKY
GITHUB_EMAIL := sky012877@gmail.com

help h:
	@echo "🛠️  Git & GitHub Project Manager"
	@echo ""
	@echo "Targets:"
	@echo "  help | h            Show this help message"
	@echo "  install | in        Install git and GitHub CLI (gh) via yay"
	@echo "  setup | s           Configure global git settings (username, email, branch, ssh)"
	@echo "  init | i            Initialize local git repo with main branch and first commit"
	@echo "  create_repo | cr    Create private GitHub repo and link it to local folder"
	@echo "  delete_repo | dr    Delete GitHub repo by name (or current folder name)"
	@echo "  force_ssh | fs      Force remote 'origin' to SSH and push main branch"
	@echo "  commit | c          Commit and push all changes with a message"
	@echo "  full_commit | fc    Pull (rebase), commit and push changes"
	@echo "-------------------------------------------------------------------"

install in:
	@echo "🔄 Updating system packages..."
	yay -Syu --noconfirm
	@echo "📦 Installing git and GitHub CLI (gh)..."
	yay -S --noconfirm git github-cli
	@echo "✅ Installation complete:"
	@git --version
	@gh --version
	@echo "-------------------------------------------------------------------"

setup s:
	@echo "🔧 Configuring Git global settings..."
	@git config --global user.name "$$(whoami)"
	@git config --global user.email "$(GITHUB_EMAIL)"
	@git config --global init.defaultBranch main
	@git config --global pull.rebase true
	@git config --global pull.ff only
	@echo "✅ Git configuration complete:"
	@git config --global --get user.name
	@git config --global --get user.email
	@git config --global --get init.defaultBranch
	@git config --global --get pull.rebase
	@git config --global --get pull.ff
	@echo "-------------------------------------------------------------------"

init i:
	@echo "🗂️  Initializing local Git repository..."
	git init -b main
	git add .
	git commit -m "Initial commit" || echo "ℹ️ Nothing to commit"
	@echo "✅ Git repository initialized with 'main' branch."
	@echo "-------------------------------------------------------------------"

create_repo cr:
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ]; then \
		read -p "📛 Enter GitHub repository name: " project_input; \
		project=$$project_input; \
	fi; \
	if [ -z "$$project" ]; then echo "❌ Error: repository name is required."; exit 1; fi; \
	echo "🔐 Checking GitHub CLI authentication..."; \
	if ! gh auth status >/dev/null 2>&1; then \
		echo "🔑 Not logged in. Launching GitHub login..."; \
		gh auth login; \
	fi; \
	echo "🌐 Creating private repository '$$project' on GitHub..."; \
	gh repo create $$project --private --source=. --remote=origin; \
	echo "✅ Remote 'origin' created."
	@echo "-------------------------------------------------------------------"

delete_repo dr:
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ]; then project=$$(basename $$PWD); fi; \
	if [ -z "$$project" ]; then echo "❌ Error: repository name is required."; exit 1; fi; \
	echo "🗑️  Deleting repo: $$project on GitHub..."; \
	gh repo delete $(GITHUB_USER)/$$project
	@echo "-------------------------------------------------------------------"

force_ssh fs:
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ]; then project=$$(basename $$PWD); fi; \
	git remote set-url origin git@github.com:$(GITHUB_USER)/$$project.git; \
	echo "🔁 Remote origin → SSH: git@github.com:$(GITHUB_USER)/$$project.git"; \
	git branch --set-upstream-to=origin/main main 2>/dev/null || echo "ℹ️ Could not set upstream"; \
	git push -u origin main || echo "⚠️ Push failed"
	@echo "-------------------------------------------------------------------"

commit c:
	@message="$(shell echo $(wordlist 2, 999, $(MAKECMDGOALS)))"; \
	if [ -z "$$message" ]; then message="no message"; fi; \
	echo "🔧 Committing with message: '$$message'"; \
	git add .; \
	git commit -m "$$message" || echo "ℹ️ Nothing to commit"; \
	git push || echo "⚠️ Push failed"; \
	echo "✅ Commit + push complete"
	@echo "-------------------------------------------------------------------"

full_commit fc:
	@message="$(shell echo $(wordlist 2, 999, $(MAKECMDGOALS)))"; \
	if [ -z "$$message" ]; then message="update"; fi; \
	echo "🔄 Pulling latest changes with rebase..."; \
	git pull --rebase origin main || echo "⚠️ Pull failed — maybe repo is new"; \
	echo "➕ Adding all changes..."; \
	git add .; \
	echo "📝 Committing with message: '$$message'"; \
	git commit -m "$$message" || echo "ℹ️ Nothing to commit"; \
	echo "🚀 Pushing to origin/main..."; \
	git push origin main || echo "⚠️ Push failed"; \
	echo "✅ Full commit cycle complete"
	@echo "-------------------------------------------------------------------"

%:
	@:
