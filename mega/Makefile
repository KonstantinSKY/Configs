.PHONY: help h sync s

help h:
	@echo "📘 Available targets:"
	@echo "---------------------------------------------------------------------"
	@echo "  make sync / s <LOCAL> <REMOTE>  - 🔁 Sync local folder with MEGA remote"
	@echo "  make help / h                   - 📖 Show this help"
	@echo "---------------------------------------------------------------------"

sync s:
	@if [ $(words $(MAKECMDGOALS)) -ne 3 ]; then \
		echo "❌ Usage: make sync <LOCAL_PATH> <REMOTE_PATH>"; \
		echo "Example: make sync /home/user/deploy /MyProjectDeploys/MyApp"; \
		exit 1; \
	fi; \
	LOCAL_PATH="$(word 2,$(MAKECMDGOALS))"; \
	REMOTE_PATH="$(word 3,$(MAKECMDGOALS))"; \
	\
	echo "📁 Local path: $$LOCAL_PATH"; \
	echo "🌐 Remote path: $$REMOTE_PATH"; \
	echo "---------------------------------------------------------------------"; \
	\
	echo "🔍 Verifying local path…"; \
	if [ ! -d "$$LOCAL_PATH" ]; then \
		echo "❌ Local path not found: $$LOCAL_PATH"; \
		exit 1; \
	fi; \
	echo "✅ Local path exists: $$LOCAL_PATH"; \
	echo "---------------------------------------------------------------------"; \
	\
	echo "🔄 Verifying Mega login..."; \
	mega-whoami >/dev/null 2>&1 || { echo "🚫 Not logged in. Run: mega-login"; exit 1; }; \
	echo "---------------------------------------------------------------------"; \
	\
	echo "🔍 Checking remote folder..."; \
	mega-ls "$$REMOTE_PATH" >/dev/null 2>&1 || { \
		echo "📁 Remote folder not found. Creating..."; \
		mega-mkdir -p "$$REMOTE_PATH" || { echo "❌ Failed to create remote folder"; exit 1; }; \
	}; \
	echo "✅ Remote folder ready."; \
	echo "---------------------------------------------------------------------"; \
	\
	echo "📁 Local path: $$LOCAL_PATH"; \
	echo "🌐 Remote path: $$REMOTE_PATH"; \
	echo "---------------------------------------------------------------------"; \
	\
	echo "🔁 Starting sync..."; \
	mega-sync "$$LOCAL_PATH" "$$REMOTE_PATH" || { echo "❌ mega-sync failed"; exit 1; }; \
	echo "---------------------------------------------------------------------"; \
	\
	echo "📋 Verifying sync is active..."; \
	mega-sync | grep -F "$$LOCAL_PATH" | grep -F "$$REMOTE_PATH" >/dev/null && \
		echo "✅ Sync established." || { echo "⚠️  Sync not listed. Please verify manually."; exit 1; }

%:
	@:
