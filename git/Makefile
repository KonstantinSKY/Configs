# Git & GitHub Project Manager (Local aliases)
SHELL := /bin/bash
# --- Local Aliases for this repo ---
.PHONY: help c i s dr fc cr git
.DEFAULT_GOAL := help
c: git
i: git-init
fc: git-full
cr: git-create
setup s: ## Git: Global git identity bootstrap moved to Security/git
	@echo -e "${C_YELLOW}⚠️  Git global setup moved to Security/git.${C_NC}"
	@echo -e "${C_BLUE}💡 Run: make -f $$HOME/Work/Security/git/Makefile setup${C_NC}"
delete_repo dr: check-config ## Git: Delete repo on GitHub
	@project=$$(basename $$PWD); \
	user=$$(gh api user --jq '.login'); \
	echo -e "${C_RED}🗑️  Deleting repo: $$project on GitHub...${C_NC}"; \
	gh repo delete $$user/$$project
%:
	@:
