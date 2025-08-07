MANJARO_MAKEFILE := $(HOME)/Configs/manjaro/Makefile

.PHONY: help install isetup s

help:
	@echo "🛠  Available targets:"
	@echo "  make install / i     Install Docker and its ecosystem"
	@echo "  make setup  / s      Enable and start Docker, add user to group"
	@echo "------------------------------------------------------------"

install i:
	@echo "🐳 Installing Docker ecosystem using universal Manjaro Makefile..."
	@make -f $(MANJARO_MAKEFILE) install docker docker-compose

	@echo "🔍 Checking installed Docker versions after install:"
	@docker --version || echo "❌ Docker not found"
	@docker compose version || echo "❌ docker compose not found"
	@docker buildx version || echo "❌ docker buildx not found"
	@echo "------------------------------------------------------------"

	@$(MAKE) setup

setup s:
	@echo "🔧 Enabling and starting Docker daemon..."
	@sudo systemctl enable docker
	@sudo systemctl start docker

	@echo "👤 Adding user '$(USER)' to 'docker' group..."
	@sudo usermod -aG docker $(USER)

	@echo "------------------------------------------------------------"
	@echo "🔍 Final Docker version check:"
	@docker --version || echo "❌ Docker not found"
	@docker compose version || echo "❌ docker compose not found"
	@docker buildx version || echo "❌ docker buildx not found"
	@echo "------------------------------------------------------------"

	@echo "⚠️  Please reboot or run 'newgrp docker' to apply group changes."
	@echo "✅ Docker setup complete."
