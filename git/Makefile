
.PHONY: init create_repo force-ssh

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
	@echo "🔐 Checking GitHub CLI authentication..."; \
	if ! gh auth status >/dev/null 2>&1; then \
		echo "🔑 Not logged in. Launching GitHub login..."; \
		gh auth login; \
	fi; \
	@echo "🌐 Creating private repository '$$project' on GitHub..."; \
	gh repo create $$project --private --source=. --remote=origin; \
	@echo "✅ Remote 'origin' created by gh (usually SSH)."

init:
	@echo "🗂️  Initializing local Git repository..."
	git init -b main
	git add .
	git commit -m "Initial commit"
	@echo "✅ Git repository initialized with 'main' branch."

force-ssh:
	@project=$(word 2, $(MAKECMDGOALS));  \
	user=$$(git config user.username || gh api user --jq .login); \
	git remote set-url origin git@github.com:$$user/$$project.git; \
	@echo "🔁 Force-set remote origin to SSH: git@github.com:$$user/$$project.git"

commit:
	@message="$(subst __SPACE__ ,$(wordlist 2,999,$(MAKECMDGOALS)))"; \
	if [ -z "$$message" ]; then \
		message="no message"; \
	fi; \
	@echo "🔧 Committing with message: '$$message'"; \
	git add .; \
	git commit -m "$$message"; \
	git push; \
	@echo "✅ Committed and pushed changes to GitHub."
