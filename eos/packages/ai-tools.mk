.PHONY: install-ai-tools ai-tools

AI_TOOLS = \
	claude-code \
	openai-codex

install-ai-tools ai-tools: ## Install AI coding tools
	@$(MAKE) -s -f $(THIS_MAKEFILE) update
	@yay -S --needed --noconfirm $(AI_TOOLS)
