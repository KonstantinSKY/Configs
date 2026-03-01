.PHONY: help get git ai

REPO_HTTP=https://github.com/KonstantinSKY/Configs.git
REPO_SSH=git@github.com:KonstantinSKY/Configs.git
DIR_NAME=Configs

AI_PACKAGES=gemini-cli claude-code openai-codex-bin
GEMINI_POLICY_DIR=$(HOME)/.gemini/policies
GEMINI_POLICY_SRC=$(HOME)/Configs/ai/gemini/shell-rules.toml
GEMINI_POLICY_DEST=$(GEMINI_POLICY_DIR)/shell-rules.toml

help:
	@echo "📘 Available targets:"
	@echo "   make get     → Clone 'Configs' repo via HTTPS into current directory"
	@echo "   make ai      → Install Gemini, Claude, Codex and setup configurations"
	@echo "   make git     → Add all changes, generate commit message via Gemini, and push"

get:
	@echo "🔍 Checking if ./$(DIR_NAME) exists..."
	@if [ -d "$(DIR_NAME)" ]; then \
		TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
		BACKUP_NAME="$(DIR_NAME).backup_$$TIMESTAMP"; \
		echo "📦 Found existing directory. Backing up to ./$$BACKUP_NAME..."; \
		mv "$(DIR_NAME)" "$$BACKUP_NAME"; \
	else \
		echo "✅ No existing $(DIR_NAME) found."; \
	fi

	@echo "⬇️  Cloning via HTTPS..."
	@git clone $(REPO_HTTP)

	@echo "🔄 Switching remote to SSH..."
	@cd $(DIR_NAME) && git remote set-url origin $(REPO_SSH)

	@echo "✅ Done! Cloned to ./$(DIR_NAME) with SSH remote."

ai:
	@echo "📦 Installing AI Agents from AUR via yay..."
	yay -S --needed --noconfirm $(AI_PACKAGES)
	@echo "⚙️  Setting up Gemini shell policies..."
	mkdir -p $(GEMINI_POLICY_DIR)
	@if [ -L "$(GEMINI_POLICY_DEST)" ]; then \
		echo "✅ Symlink already exists: $(GEMINI_POLICY_DEST)"; \
	elif [ -f "$(GEMINI_POLICY_DEST)" ]; then \
		echo "📦 Backing up existing shell-rules.toml..."; \
		mv "$(GEMINI_POLICY_DEST)" "$(GEMINI_POLICY_DEST).bak"; \
		ln -sf $(GEMINI_POLICY_SRC) $(GEMINI_POLICY_DEST); \
	else \
		echo "🔗 Creating symlink: $(GEMINI_POLICY_DEST) -> $(GEMINI_POLICY_SRC)"; \
		ln -sf $(GEMINI_POLICY_SRC) $(GEMINI_POLICY_DEST); \
	fi
	@echo "✅ AI Setup complete."

git:
	@$(MAKE) -f git/Makefile git
