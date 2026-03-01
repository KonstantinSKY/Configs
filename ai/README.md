# AI Agent Configurations

This directory serves as the centralized repository for managing configurations, system prompts, and behavior policies for Artificial Intelligence agents.

## Supported Agents

- **Gemini CLI**: Core configuration, shell policies, and custom instructions.
- **Claude**: Project-specific rules and context files.
- **Codex**: Development-focused agent settings and workspace integration.

## Directory Structure

- `gemini/`: Specific configurations for the Gemini CLI agent.
- `claude/`: System prompts and `.claude.json` templates.
- `codex/`: Settings for the Codex development assistant.
- `common/`: Shared prompts and instructions used across all agents.

## Usage

All AI agents should be instructed to consult this directory for behavioral guidelines and system-level constraints to ensure consistency across different platforms and models.

---
*Note: This is an authoritative configuration source. Changes should be committed to the Git repository in `~/Work/Configs`.*
