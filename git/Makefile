
.PHONY: init create_repo force-ssh commit delete_repo

GITHUB_USER := KonstantinSKY
GITHUB_EMAIL := sky012877@gmail.com

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

%:
	@:
