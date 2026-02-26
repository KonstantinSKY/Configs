# Git & GitHub Project Manager
SHELL := /bin/bash

# --- Colors ---
BLUE         := [0;34m
GREEN        := [0;32m
RED          := [0;31m
YELLOW       := [1;33m
VIOLET       := [0;35m
NC           := [0m

# --- Config ---
GITHUB_USER  := KonstantinSKY
GITHUB_EMAIL := sky012877@gmail.com
GEMINI_PROMPT := "Generate a concise, professional git commit message in English for these changes. Respond ONLY with the message text, no quotes or markdown."
LINE          := "-------------------------------------------------------------------"

.PHONY: help h setup s init i create_repo cr delete_repo dr force_ssh fs commit c full_commit fc install in git

# --- Main Targets ---

help h:
	@echo -e "${BLUE}🛠️  Git & GitHub Project Manager${NC}"
	@echo ""
	@echo "Targets:"
	@echo "  help | h            Show this help message"
	@echo "  install | in        Install git and GitHub CLI (gh) via yay"
	@echo "  setup | s           Configure global git settings"
	@echo "  init | i            Initialize local git repo"
	@echo "  create_repo | cr    Create private GitHub repo"
	@echo "  delete_repo | dr    Delete GitHub repo"
	@echo "  force_ssh | fs      Force remote 'origin' to SSH"
	@echo "  commit | c [msg]    Commit and push (uses Gemini if msg is empty)"
	@echo "  full_commit | fc    Pull (rebase), commit and push"
	@echo "  git                 Auto-detect changes, Gemini message, commit & push"
	@echo -e "${VIOLET}$(LINE)${NC}"

install in:
	@echo -e "${BLUE}🔄 Updating system packages...${NC}"
	yay -Syu --noconfirm
	@echo -e "${BLUE}📦 Installing git and GitHub CLI (gh)...${NC}"
	yay -S --noconfirm git github-cli
	@echo -e "${GREEN}✅ Installation complete:${NC}"
	@git --version
	@gh --version
	@echo -e "${VIOLET}$(LINE)${NC}"

setup s:
	@echo -e "${BLUE}🔧 Configuring Git global settings...${NC}"
	@git config --global user.name "$$(whoami)"
	@git config --global user.email "$(GITHUB_EMAIL)"
	@git config --global init.defaultBranch main
	@git config --global pull.rebase true
	@git config --global pull.ff only
	@echo -e "${GREEN}✅ Git configuration complete:${NC}"
	@echo -e "${YELLOW}User:${NC} $$(git config --global --get user.name)"
	@echo -e "${YELLOW}Email:${NC} $$(git config --global --get user.email)"
	@echo -e "${VIOLET}$(LINE)${NC}"

init i:
	@echo -e "${BLUE}🗂️  Initializing local Git repository...${NC}"
	git init -b main
	git add .
	git commit -m "Initial commit" || echo "ℹ️ Nothing to commit"
	@echo -e "${GREEN}✅ Git repository initialized with 'main' branch.${NC}"
	@echo -e "${VIOLET}$(LINE)${NC}"

create_repo cr:
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ]; then \
		read -p "📛 Enter GitHub repository name: " project_input; \
		project=$$project_input; \
	fi; \
	project_name=$$(basename "$$project"); \
	if [ -z "$$project_name" ]; then echo -e "${RED}❌ Error: repository name is required.${NC}"; exit 1; fi; \
	echo -e "${BLUE}🔐 Checking GitHub CLI authentication...${NC}"; \
	if ! gh auth status >/dev/null 2>&1; then \
		echo -e "${YELLOW}🔑 Not logged in. Launching GitHub login...${NC}"; \
		gh auth login; \
	fi; \
	echo -e "${BLUE}🌐 Creating private repository '$$project_name' on GitHub...${NC}"; \
	gh repo create $$project_name --private --source=. --remote=origin; \
	echo -e "${GREEN}✅ Remote 'origin' created.${NC}"
	@echo -e "${VIOLET}$(LINE)${NC}"

delete_repo dr:
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ]; then project=$$(basename $$PWD); fi; \
	if [ -z "$$project" ]; then echo -e "${RED}❌ Error: repository name is required.${NC}"; exit 1; fi; \
	echo -e "${RED}🗑️  Deleting repo: $$project on GitHub...${NC}"; \
	gh repo delete $(GITHUB_USER)/$$project
	@echo -e "${VIOLET}$(LINE)${NC}"

force_ssh fs:
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ]; then project=$$(basename "$$PWD"); fi; \
	project_name=$$(basename "$$project"); \
	if [ -z "$$GITHUB_USER" ]; then \
		GITHUB_USER=$$(gh api user --jq '.login'); \
	fi; \
	echo -e "${BLUE}🔁 Remote origin → SSH: git@github.com:$$GITHUB_USER/$$project_name.git${NC}"; \
	git remote set-url origin git@github.com:$$GITHUB_USER/$$project_name.git; \
	git branch --set-upstream-to=origin/main main 2>/dev/null || echo "ℹ️ Could not set upstream"; \
	git push -u origin main || echo -e "${RED}⚠️ Push failed${NC}"
	@echo -e "${VIOLET}$(LINE)${NC}"

# --- Logic for commit with message or Gemini ---
commit c:
	@echo -e "${BLUE}🔍 Git Status Report:${NC}"
	@git status
	@status=$$(git status --porcelain); \
	if [ -z "$$status" ]; then \
		echo -e "${YELLOW}ℹ️ No changes to process.${NC}"; \
	else \
		echo -e "${BLUE}🚀 Staging changes...${NC}"; \
		git add .; \
		message="$(shell echo $(wordlist 2, 999, $(MAKECMDGOALS)))"; \
		if [ -z "$$message" ]; then \
			echo -e "${BLUE}🤖 Generating message via Gemini...${NC}"; \
			message=$$(git diff --staged | gemini -p $(GEMINI_PROMPT) 2>/dev/null); \
			if [ -z "$$message" ]; then message="Update: automatic sync (Gemini failed)"; fi; \
		fi; \
		echo -e "${YELLOW}📝 Message:${NC} $$message"; \
		git commit -m "$$message"; \
		git push && echo -e "${GREEN}✅ Successfully pushed!${NC}"; \
	fi
	@echo -e "${VIOLET}$(LINE)${NC}"

full_commit fc:
	@echo -e "${VIOLET}$(LINE)${NC}"
	@git status -s || true
	@echo -e "${BLUE}➕ Adding all changes...${NC}"
	@git add -A
	@echo -e "${BLUE}🔄 Pulling latest changes (rebase)...${NC}"
	@git pull --rebase origin main || echo -e "${YELLOW}⚠️ Pull failed${NC}"
	@$(MAKE) -f git/Makefile commit
	@echo -e "${GREEN}✅ Full commit cycle complete${NC}"
	@echo -e "${VIOLET}$(LINE)${NC}"
# Алиас для автоматического процесса
git: c

%:
	@:
