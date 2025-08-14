.PHONY: new run

METATRADERS_DIR := $(HOME)/Work/MetaTraders
MT4_DEV_DIR     := $(METATRADERS_DIR)/MT4

# MQL4 structure
MQL4_DIR        := $(MT4_DEV_DIR)/MQL4
INCLUDE_DIR     := $(MQL4_DIR)/Include
EXPERTS_DIR     := $(MQL4_DIR)/Experts
PROJECTS_MQL    := $(MQL4_DIR)/Projects

# Physical place where your projects live
PROJECTS_DIR    := $(METATRADERS_DIR)/Projects

# Templates live INSIDE MT4 dir (as ты сказал)
TEMPLATE_DIR    := $(MT4_DEV_DIR)/Templates
TEMPLATE_EXPERT := $(TEMPLATE_DIR)/expert_template.mq4  # Expert template name

new:
	@read -p "📛 Enter project name: " PROJECT_NAME; \
	if [ -z "$$PROJECT_NAME" ]; then \
		echo "❌ Project name cannot be empty!"; exit 1; \
	fi; \
	PROJECT_DIR="$(PROJECTS_DIR)/$$PROJECT_NAME"; \
	LINK_IN_INCLUDE="$(INCLUDE_DIR)/$$PROJECT_NAME"; \
	LINK_EXPERT="$(EXPERTS_DIR)/$$PROJECT_NAME.mq4"; \
	\
	# --- sanity checks ---
	if [ ! -d "$(MQL4_DIR)" ]; then \
		echo "❌ MQL4 dir not found: $(MQL4_DIR)"; exit 1; \
	fi; \
	if [ ! -f "$(TEMPLATE_EXPERT)" ]; then \
		echo "❌ Expert template not found: $(TEMPLATE_EXPERT)"; exit 1; \
	fi; \
	\
	# --- create real project dir (outside MQL4) ---
	if [ -e "$$PROJECT_DIR" ]; then \
		echo "❌ Project already exists: $$PROJECT_DIR"; exit 1; \
	fi; \
	echo "📁 Creating project: $$PROJECT_DIR"; \
	mkdir -p "$$PROJECT_DIR"; \
	\
	# --- link Include into project (read-only from MT4 Include) ---
	if [ ! -L "$$PROJECT_DIR/Include" ]; then \
		echo "🔗 Linking Include → project"; \
		ln -s "$(INCLUDE_DIR)" "$(PROJECT_DIR)"; \
	fi; \
	\
	# --- link project into MQL4/Projects/<name> ---
	# (MetaEditor видит проект в MQL4/Projects, но данные хранятся в твоём PROJECTS_DIR)
	if [ -e "$$LINK_IN_INCLUDE" ]; then \
		echo "❌ Path already exists: $$LINK_IN_PROJECTS"; exit 1; \
	fi; \
	echo "🔗 Linking project into MQL4/Projects: $$LINK_IN_INCLUDE → $$PROJECT_DIR"; \
	ln -s "$$PROJECT_DIR" "$$LINK_IN_INCLUDE"; \
	\
	# --- main linking: template → MQL4/Experts/<ProjectName>.mq4 (то, что компилится) ---
	if [ -e "$$LINK_EXPERT" ]; then \
		echo "❌ Expert already exists: $$LINK_EXPERT"; exit 1; \
	fi; \
	echo "🔗 Linking expert template → Experts: $$LINK_EXPERT → $(TEMPLATE_EXPERT)"; \
	ln -s "$(TEMPLATE_EXPERT)" "$$LINK_EXPERT"; \
	\
	echo "✅ Project '$$PROJECT_NAME' created and wired to MQL4."
