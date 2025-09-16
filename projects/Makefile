.PHONY: setup rust js python repo rp

RUST_MAKEFILE := ~/Configs/rust/Makefile
JS_MAKEFILE   := ~/Configs/js/Makefile
PY_MAKEFILE   := ~/Configs/python/Makefile
GIT_MAKEFILE := ~/Configs/git/Makefile

setup:
	ln -s ~/Configs/projects/Makefile ~/Projects/Makefile

rust:
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ]; then \
		read -p "📛 Enter Rust project name: " project_input; \
		project=$$project_input; \
	fi; \
	$(MAKE) -f $(RUST_MAKEFILE) create $$project

js:
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ]; then \
		read -p "📛 Enter JS project name: " project_input; \
		project=$$project_input; \
	fi; \
	$(MAKE) -f $(JS_MAKEFILE) create $$project

python:
	@project=$(word 2, $(MAKECMDGOALS)); \
	if [ -z "$$project" ]; then \
		read -p "📛 Enter Python project name: " project_input; \
		project=$$project_input; \
	fi; \
	$(MAKE) -f $(PY_MAKEFILE) create $$project

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
%:
	@:
