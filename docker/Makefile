# IMPORTANT FOR AI AGENTS:
# Do not modify this file without explicit user confirmation.

.PHONY: help install i setup group g version v status st
.DEFAULT_GOAL := help

MAKEFLAGS += --no-print-directory

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_DIR := $(abspath $(THIS_DIR)/..)
MANJARO_MAKEFILE := $(CONFIGS_DIR)/manjaro/Makefile

ifeq ($(filter $(CONFIGS_DIR)/make/help.mk,$(MAKEFILE_LIST)),)
include $(CONFIGS_DIR)/make/help.mk
endif

SEPARATOR := ---------------------------------------------------------------------

install i: ## Install Docker, docker-compose, docker-buildx and run setup
	@echo "🐳 Installing Docker ecosystem..."
	@$(MAKE) -f "$(MANJARO_MAKEFILE)" install docker docker-compose docker-buildx
	@echo "$(SEPARATOR)"
	@$(MAKE) -f "$(THIS_MAKEFILE)" setup

setup: ## Enable Docker daemon and add current user to docker group
	@echo "🔧 Enabling and starting Docker daemon..."
	@sudo systemctl enable docker
	@sudo systemctl start docker
	@echo "$(SEPARATOR)"
	@echo "👤 Adding user '$(USER)' to 'docker' group..."
	@sudo usermod -aG docker $(USER)
	@echo "$(SEPARATOR)"
	@$(MAKE) -f "$(THIS_MAKEFILE)" status
	@echo "⚠️  Run 'newgrp docker' or reboot to apply group changes."

group g: ## Check if current user is in the docker group
	@if id -nG "$(USER)" | grep -qw docker; then \
		echo "✅ User '$(USER)' is in the 'docker' group"; \
	else \
		echo "❌ User '$(USER)' is NOT in the 'docker' group"; \
		echo "   Run: sudo usermod -aG docker $(USER)"; \
	fi

version v: ## Show installed Docker component versions
	@echo "🐳 Docker:         $$(docker --version 2>/dev/null || echo 'not installed')"
	@echo "🐳 Docker Compose: $$(docker compose version 2>/dev/null || echo 'not installed')"
	@echo "🐳 Docker Buildx:  $$(docker buildx version 2>/dev/null || echo 'not installed')"

status st: ## Show Docker installation, daemon state, group membership, and running containers
	@echo "Docker status"
	@echo "$(SEPARATOR)"
	@$(MAKE) -f "$(THIS_MAKEFILE)" version
	@echo "$(SEPARATOR)"
	@$(MAKE) -f "$(THIS_MAKEFILE)" group
	@echo "$(SEPARATOR)"
	@echo "🔍 Docker daemon:"
	@systemctl is-active docker >/dev/null 2>&1 \
		&& echo "✅ docker daemon is running" \
		|| echo "❌ docker daemon is not running"
	@echo "$(SEPARATOR)"
	@echo "📦 Running containers:"
	@docker ps --format "  - {{.Names}} ({{.Image}}) — {{.Status}}" 2>/dev/null || echo "  (docker not available)"
