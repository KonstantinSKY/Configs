# Git & GitHub Project Manager (Local aliases)
SHELL := /bin/bash
# --- Local Aliases for this repo ---
.PHONY: c i s dr fc cr git
c: git
i: git-init
fc: git-full
cr: git-create
setup s: ## Git: Interactive global setup
	@echo -e "${C_BLUE}🔧 Configuring Git global settings...${C_NC}"
	@read -p "Enter GitHub User Name: " user; \
	read -p "Enter GitHub Email: " email; \
	git config --global user.name "$$user"; \
	git config --global user.email "$$email"; \
	git config --global init.defaultBranch main; \
	echo -e "${C_GREEN}✅ Configured successfully.${C_NC}"
delete_repo dr: check-config ## Git: Delete repo on GitHub
	@project=$$(basename $$PWD); \
	user=$$(gh api user --jq '.login'); \
	echo -e "${C_RED}🗑️  Deleting repo: $$project on GitHub...${C_NC}"; \
	gh repo delete $$user/$$project
%:
	@:
