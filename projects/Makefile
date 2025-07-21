.PHONY: rust js python

RUST_MAKEFILE := ~/Configs/rust/Makefile
JS_MAKEFILE   := ~/Configs/js/Makefile
PY_MAKEFILE   := ~/Configs/python/Makefile

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

%:
	@:
