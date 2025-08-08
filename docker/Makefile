MANJARO_MAKEFILE := $(HOME)/Configs/manjaro/Makefile

.PHONY: help h install i setup set version v status s


help h:
	@echo "🛠  Available targets:"
	@echo "  make install / i     Install Docker and its ecosystem"
	@echo "  make setup  / set    Enable and start Docker, add user to group"
	@echo "  make version / v     Show installed Docker versions"
	@echo "  make status  / s     Show Docker daemon status and running containers"
	@echo "------------------------------------------------------------"

install i:
	@echo "🐳 Installing Docker ecosystem using universal Manjaro Makefile..."
	@make -f $(MANJARO_MAKEFILE) install docker docker-compose docker-buildx
	@$(MAKE) version
	@$(MAKE) setup

setup set:
	@echo "🔧 Enabling and starting Docker daemon..."
	@sudo systemctl enable docker
	@sudo systemctl start docker
	@echo "------------------------------------------------------------"
	@echo "👤 Adding user '$(USER)' to 'docker' group..."
	@sudo usermod -aG docker $(USER)
	@echo "------------------------------------------------------------"
	@$(MAKE) status
	@echo "⚠️  Please reboot or run 'newgrp docker' to apply group changes."
	@echo "✅ Docker setup complete."

version v:
	@echo "🔍 Checking installed Docker versions"
	@echo "🐳 Docker version:"
	@docker --version || echo "❌ Docker not found"
	@echo "🐳 Docker compose version:"
	@docker compose version || echo "❌ docker compose not found"
	@echo "🐳 Docker buildx version:"
	@docker buildx version || echo "❌ docker buildx not found"
	@echo "------------------------------------------------------------"

status s: version group
	@echo "🔍 Checking Docker status"
	@echo "🔍 Checking Docker daemon status..."
	@sudo systemctl status docker --no-pager || echo "❌ Docker service not found"
	@echo "------------------------------------------------------------"
	@echo "🔄 Docker info summary:"
	@docker info --format '  - Containers: {{.Containers}} (running: {{.ContainersRunning}}), Images: {{.Images}}, Storage Driver: {{.Driver}}' || echo "❌ docker info failed"
	@echo "------------------------------------------------------------"
	@echo "📦 Currently running containers:"
	docker ps
	@echo "------------------------------------------------------------"
	@docker ps --format '  - {{.Names}} ({{.Image}}) — Up: {{.Status}}' || echo "❌ docker ps failed"
	@echo "------------------------------------------------------------"

group g:
	@echo "🔒 Checking user group access:"
	@if id -nG "$(USER)" | grep -qw docker; then \
		echo "✅ User '$(USER)' is in the 'docker' group"; \
	else \
		echo "❌ User '$(USER)' is NOT in the 'docker' group. Run 'sudo usermod -aG docker $(USER)'"; \
	fi
	@echo "------------------------------------------------------------"
