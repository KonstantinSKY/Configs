

.PHONY: create

RUST_MAKEFILE := ~/Configs/rust/Makefile
GIT_MAKEFILE := ~/Configs/git/Makefile
GITIGNORE_TEMPLATE := ~/Configs/rust/gitignore

create:
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ] || echo "$$project" | grep -q '^[[:space:]]*$$'; then \
		read -p "📛 Enter project name: " project_input; \
		project=$$project_input; \
	fi; \
	if [ -z "$$project" ] || echo "$$project" | grep -q '^[[:space:]]*$$'; then \
		echo "❌ Error: Project name is required."; exit 1; \
	fi; \
	echo "📦 Creating Rust project: $$project"; \
	cargo new "$$project" --vcs none; \
	ln -sf $(RUST_MAKEFILE) "$$project/Makefile"; \
	echo "🔗 Linked Makefile into project"; \
	echo "✅ Done."

repo:
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ]; then \
		project=$$(basename $$PWD); \
	fi; \
	echo "📦 Project and repo name: $$project"; \
	echo "Initializing Git repository"; \
	$(MAKE) -f $(GIT_MAKEFILE) init; \
	echo "📦 Creating repo"; \
	$(MAKE) -f $(GIT_MAKEFILE) create_repo $$project; \
	echo "Setting up SSH"; \
	$(MAKE) -f $(GIT_MAKEFILE) force_ssh $$project; \
	echo "Copying gitignore"; \
	$(MAKE) copy_gitignore


copy_gitignore:
	@if [ -f $(GITIGNORE_TEMPLATE) ]; then \
		cp $(GITIGNORE_TEMPLATE) .gitignore; \
		echo "📄 Copied gitignore template to .gitignore"; \
	else \
		echo "⚠️  Warning: gitignore template not found at $(GITIGNORE_TEMPLATE)"; \
	fi; \
	$(MAKE) -f $(GIT_MAKEFILE) commit "add gitignore"
%:
	@:
