# MT4 Project bootstrap Makefile (GNU make)
# ------------------------------------------------------------
# Every recipe runs in one shell; use strict shell options.
.ONESHELL:
SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c

.DEFAULT_GOAL := help
.PHONY: help h new repo rp expert e indicator i script s %-args-sink

-include $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../make/help.mk)

# Sink rule to allow passing an extra word as an "argument" after targets,
# so `make new MyProject` won't fail on unknown target "MyProject".
%-args-sink:

# ------------------------------------------------------------
# Paths
METATRADERS_DIR      := $(HOME)/Work/MetaTraders
PROJECTS_DIR         := $(METATRADERS_DIR)/Projects

# MQL4 folders
MQL4_DIR             := $(METATRADERS_DIR)/MT4/MQL4
EXPERTS_DIR          := $(MQL4_DIR)/Experts
INDICATORS_DIR       := $(MQL4_DIR)/Indicators
SCRIPTS_DIR          := $(MQL4_DIR)/Scripts

# Other tooling
GIT_MAKEFILE         := $(HOME)/Configs/git/Makefile
METATRADER_MAKEFILE  := $(HOME)/Configs/metatrader/Makefile

# Templates
MT_CONFIGS_DIR       := $(HOME)/Configs/metatrader
TEMPLATE_DIR         := $(MT_CONFIGS_DIR)/templates
EXPERT_TEMPLATE      := $(TEMPLATE_DIR)/expert.mq4
INDICATOR_TEMPLATE   := $(TEMPLATE_DIR)/indicator.mq4
SCRIPT_TEMPLATE      := $(TEMPLATE_DIR)/script.mq4

# Windows root for MT4 include (double backslashes are important)
WIN_PROJECTS_ROOT := Z:\\Projects

# Entry file name inside the project
EXPERT_MAIN_ENTRY := expert.mq4
SCRIPT_MAIN_ENTRY := script.mq4
INDICATOR_MAIN_ENTRY := indicator.mq4

# The include line written into the .mq4 stub
# $$ expands to $ inside the shell so PROJECT_NAME is substituted at runtime
EXPERT_INCLUDE_LINE := #include "$(WIN_PROJECTS_ROOT)\\$${PROJECT_NAME}\\$(MAIN_ENTRY)"

# ------------------------------------------------------------
# ------------------------------------------------------------
# 1) Project bootstrap (creates dir, MAIN_ENTRY from template or empty, copies per-project Makefile, sets up repo)
new:
	@echo "Creating project for MetaTrader .."
	# 1) Try to get name from CLI arg: `make new MyProject`
	PROJECT_NAME="$(word 2, $(MAKECMDGOALS))"
	# 2) If empty, prompt
	if [[ -z "$$PROJECT_NAME" ]]; then
		read -p "📛 Enter project name: " PROJECT_NAME
	fi
	if [[ -z "$$PROJECT_NAME" ]]; then
		echo "❌ Project name cannot be empty!" >&2
		exit 1
	fi
	PROJECT_DIR="$(PROJECTS_DIR)/$$PROJECT_NAME"
	MAIN_FILE="$$PROJECT_DIR/$(MAIN_ENTRY)"
	if [[ -e "$$PROJECT_DIR" ]]; then
		echo "❌ Project already exists: $$PROJECT_DIR" >&2
		exit 1
	fi
	echo "----------------------------------------------------------------------------------"
	echo "📁 Creating project dir: $$PROJECT_DIR"
	mkdir -p "$$PROJECT_DIR"

	echo "----------------------------------------------------------------------------------"
	echo "📄 Creating symlink project Makefile → $$PROJECT_DIR/Makefile"
	ln -s "$(METATRADER_MAKEFILE)" "$$PROJECT_DIR/Makefile"

	echo "----------------------------------------------------------------------------------"
	echo "Changing directory to → $$PROJECT_DIR"
	cd "$$PROJECT_DIR"
	ls -la

	echo "✅ Done."

# ------------------------------------------------------------
# 2) Git/GitHub integration
repo r:
	@echo "🛰  Creating GitHub repo"
	project="$(word 2, $(MAKECMDGOALS))"
	if [[ -z "$$project" ]]; then
		project="$$(basename "$$PWD")"
	fi

	@echo "📦 Project and repo name: $$project"
	@echo "🌿 Initializing git repo..."
	@$(MAKE) -f "$(GIT_MAKEFILE)" init
	@echo "----------------------------------------------------------------------------------"

	@echo "Copying gitignore..."
	cp "$(MT_CONFIGS_DIR)/gitignore" "$$PROJECT_DIR/.gitignore"

	@echo "----------------------------------------------------------------------------------"
	@$(MAKE) -f "$(GIT_MAKEFILE)" create_repo "$$project"
	@$(MAKE) -f "$(GIT_MAKEFILE)" init
	@$(MAKE) -f "$(GIT_MAKEFILE)" commit "Initial commit"
	git push -u origin main

	@echo "✅ Git prepared for: $$project"
	@echo "----------------------------------------------------------------------------------"

# ------------------------------------------------------------
# 3) MQL4 stubs (Expert / Indicator / Script)
#    Each target writes a single-line #include pointing to Z:\Projects\<name>\$(MAIN_ENTRY)

expert e:
	@project="$(word 2, $(MAKECMDGOALS))"
	if [[ -z "$$project" ]]; then
		project="$$(basename "$$PWD")"
	fi

	echo "Project: $$project"

	expert_main_file="$(PROJECTS_DIR)/$$project/$(EXPERT_MAIN_ENTRY)"
	echo "Copying main Expert file from template → $$expert_main_file"
	mkdir -p "$(PROJECTS_DIR)/$$project"

	if [[ -f "$(EXPERT_TEMPLATE)" ]]; then
		cp "$(EXPERT_TEMPLATE)" "$$expert_main_file"
	else
		echo "⚠ No EXPERT_TEMPLATE found → creating empty file"
		: > "$$expert_main_file"
	fi

	ls -la "$(PROJECTS_DIR)/$$project/"
	echo "-----------------------------------------------------------------------------------"
	echo "Creating Expert stub from project: $$project to MetaTrader Experts directory: $(EXPERTS_DIR)"
	mkdir -p "$(EXPERTS_DIR)"

	file_path="$(EXPERTS_DIR)/$$project.mq4"
	PROJECT_NAME="$$project" printf '%s\n' "$(EXPERT_INCLUDE_LINE)" > "$$file_path"

	echo "✅ Expert file created: $$file_path"
	echo "-----------------------------------------------------------------------------------"


indicator i:
	@project="$(word 2, $(MAKECMDGOALS))"
	if [[ -z "$$project" ]]; then
		project="$$(basename "$$PWD")"
	fi

	echo "Project: $$project"

	indicator_main_file="$(PROJECTS_DIR)/$$project/$(INDICATOR_MAIN_ENTRY)"
	echo "Copying main Indicator file from template → $$indicator_main_file"
	mkdir -p "$(PROJECTS_DIR)/$$project"

	if [[ -f "$(INDICATOR_TEMPLATE)" ]]; then
		cp "$(INDICATOR_TEMPLATE)" "$$indicator_main_file"
	else
		echo "⚠ No INDICATOR_TEMPLATE found → creating empty file"
		: > "$$indicator_main_file"
	fi

	ls -la "$(PROJECTS_DIR)/$$project/"

	echo "-----------------------------------------------------------------------------------"
	echo "Creating Indicator stub from project: $$project to MetaTrader Indicators directory: $(INDICATORS_DIR)"
	mkdir -p "$(INDICATORS_DIR)"

	file_path="$(INDICATORS_DIR)/$$project.mq4"
	PROJECT_NAME="$$project" MAIN_ENTRY="$(INDICATOR_MAIN_ENTRY)" printf '%s\n' "$(EXPERT_INCLUDE_LINE)" > "$$file_path"

	echo "✅ Indicator file created: $$file_path"
	echo "-----------------------------------------------------------------------------------"


script s:
	@project="$(word 2, $(MAKECMDGOALS))"
	if [[ -z "$$project" ]]; then
		project="$$(basename "$$PWD")"
	fi

	echo "Project: $$project"

	script_main_file="$(PROJECTS_DIR)/$$project/$(SCRIPT_MAIN_ENTRY)"
	echo "Copying main Script file from template → $$script_main_file"
	mkdir -p "$(PROJECTS_DIR)/$$project"

	if [[ -f "$(SCRIPT_TEMPLATE)" ]]; then
		cp "$(SCRIPT_TEMPLATE)" "$$script_main_file"
	else
		echo "⚠ No SCRIPT_TEMPLATE found → creating empty file"
		: > "$$script_main_file"
	fi

	ls -la "$(PROJECTS_DIR)/$$project/"

	echo "-----------------------------------------------------------------------------------"
	echo "Creating Script stub from project: $$project to MetaTrader Scripts directory: $(SCRIPTS_DIR)"
	mkdir -p "$(SCRIPTS_DIR)"

	file_path="$(SCRIPTS_DIR)/$$project.mq4"
	PROJECT_NAME="$$project" MAIN_ENTRY="$(SCRIPT_MAIN_ENTRY)" printf '%s\n' "$(EXPERT_INCLUDE_LINE)" > "$$file_path"

	echo "✅ Script file created: $$file_path"
	echo "-----------------------------------------------------------------------------------"

%:
	@:
