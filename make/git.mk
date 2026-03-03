# Global Git & GitHub Tools
# Included via all.mk

# --- Config (Dynamic) ---
GITHUB_USER   := $(shell git config --global user.name)
GITHUB_EMAIL  := $(shell git config --global user.email)
GEMINI_PROMPT := "Generate a concise, professional git commit message in English for these changes. Respond ONLY with the message text, no quotes or markdown."


# --- Validation ---
check-config:
	@if [ -z "$(GITHUB_USER)" ] || [ -z "$(GITHUB_EMAIL)" ]; then \
		echo -e "${C_RED}❌ Error: Git user.name or user.email is not set!${C_NC}"; \
		echo -e "${C_YELLOW}💡 Please configure your git identity or run 'make setup' in Configs/git.${C_NC}"; \
		exit 1; \
	fi

# --- Core Targets ---
.PHONY: git git-full git-init git-create check-config

git: check-config ## Git: Quick AI commit and push (Gemini)
	@echo -e "${C_BLUE}🔍 Git Status...${C_NC}"
	@git status -s
	@status=$$(git status --porcelain); \
	if [ -z "$$status" ]; then \
		echo -e "${C_YELLOW}ℹ️ No changes to process.${C_NC}"; \
	else \
		git add .; \
		echo -e "${C_BLUE}🤖 Generating message via Gemini...${C_NC}"; \
		message=$$(git diff --staged | gemini -p $(GEMINI_PROMPT) 2>/dev/null); \
		if [ -z "$$message" ]; then message="Update: automatic sync"; fi; \
		echo -e "${C_YELLOW}📝 Message:${C_NC} $$message"; \
		git commit -m "$$message" && git push && echo -e "${C_GREEN}✅ Pushed!${C_NC}"; \
	fi

git-full: check-config ## Git: Pull (rebase), AI commit and push
	@echo -e "${C_BLUE}🔄 Pulling latest changes...${C_NC}"
	@git pull --rebase origin main || true
	@$(MAKE) git

git-init: ## Git: Initialize local repo and initial commit
	@echo -e "${C_BLUE}🗂️ Initializing Git...${C_NC}"
	@git init -b main
	@git add .
	@git commit -m "Initial commit"
	@echo -e "${C_GREEN}✅ Ready.${C_NC}"

git-create: check-config ## Git: Create private repo on GitHub (requires gh auth)
	@project=$$(basename "$$PWD"); \
	echo -e "${C_BLUE}🌐 Creating GitHub repo: $$project...${C_NC}"; \
	gh repo create $$project --private --source=. --remote=origin && \
	git push -u origin main
