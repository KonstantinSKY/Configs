.PHONY: new

# Paths
METATRADERS_DIR := $(HOME)/Work/MetaTraders
EXPERTS_DIR     := $(METATRADERS_DIR)/MT4/MQL4/Experts
PROJECTS_DIR    := $(METATRADERS_DIR)/Projects

# Windows root for MT4 include (double backslashes are important)
WIN_PROJECTS_ROOT := Z:\\Projects

# Entry file inside the project
MAIN_ENTRY := mine.mq4

# The only include line we will write into the expert file
# $$ is required so PROJECT_NAME expands in the shell at run-time
EXPERT_INCLUDE_LINE := #include "$(WIN_PROJECTS_ROOT)\\$${PROJECT_NAME}\\$(MAIN_ENTRY)"

new:
	@read -p "📛 Enter project name: " PROJECT_NAME; \
	if [ -z "$$PROJECT_NAME" ]; then \
		echo "❌ Project name cannot be empty!"; exit 1; \
	fi; \
	PROJECT_DIR="$(PROJECTS_DIR)/$$PROJECT_NAME"; \
	EXPERT_FILE="$(EXPERTS_DIR)/$$PROJECT_NAME.mq4"; \
	\
	# Fail if project dir or expert file already exist
	if [ -e "$$PROJECT_DIR" ]; then echo "❌ Project already exists: $$PROJECT_DIR"; exit 1; fi; \
	if [ -e "$$EXPERT_FILE" ]; then echo "❌ Expert file already exists: $$EXPERT_FILE"; exit 1; fi; \
	\
	# Create dirs
	mkdir -p "$$PROJECT_DIR" "$(EXPERTS_DIR)"; \
	\
	# Create expert with ONLY ONE include line
	printf '%s\n' "$(EXPERT_INCLUDE_LINE)" > "$$EXPERT_FILE"; \
	\
	echo "✅ Created: $$EXPERT_FILE"


repo:
