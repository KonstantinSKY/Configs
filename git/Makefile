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
	@message="$(wordlist 2, 999, $(MAKECMDGOALS))"; \
	if [ -z "$$message" ]; then message="no_message"; fi; \
	echo "-------------------------------------------------------------------"; \
	git status -s || true; \
	echo "-------------------------------------------------------------------"; \
	echo "➕ Adding all changes..."; \
	git add -A; \
	echo "-------------------------------------------------------------------"; \
	echo "🔄 Pulling latest changes with rebase..."; \
	git pull --rebase origin main || echo "⚠️ Pull failed — maybe repo is new"; \
	echo "📝 Committing with message: '$$message'"; \
	git commit -m "$$message" || echo "ℹ️ Nothing to commit"; \
	echo "🚀 Pushing to origin/main..."; \
	git push origin main || echo "⚠️ Push failed"; \
	git status -s || true; \
	echo "✅ Full commit cycle complete"; \
	echo "-------------------------------------------------------------------"

%:
	@:
