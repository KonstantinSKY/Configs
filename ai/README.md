# AI Agent Configurations

This directory serves as the centralized repository for managing configurations, system prompts, and behavior policies for Artificial Intelligence agents.

## Supported Agents

- **Gemini CLI**: Core configuration, shell policies, and custom instructions.
- **Claude**: Project-specific rules and context files.
- **Codex**: Development-focused agent settings and workspace integration.

## Directory Structure

- `gemini/`: Specific rule sources for the Gemini CLI agent.
- `claude/`: System prompts and `.claude.json` templates.
- `codex/`: Rule sources for the Codex development assistant.
- `common/`: Shared prompts and instructions used across all agents.

## Usage

All AI agents should be instructed to consult this directory for behavioral guidelines and system-level constraints to ensure consistency across different platforms and models. Installation syncs these source files into the agent-specific runtime directories by copying them.

## Shared runtime config

The shared files under `codex/shared/` and `claude/shared/` are the safe,
tracked layer for multiple local accounts.

- Codex profiles link `config.toml`, `rules/`, and `skills/` to
  `ai/codex/shared/`.
- Claude profiles link `settings.json`, `settings.local.json`, `commands/`,
  `agents/`, `skills/`, `rules/`, and `statusline-command.sh` to
  `ai/claude/shared/`.

Do not link or commit account state such as Codex `auth.json`, histories,
sessions, caches, SQLite state, or Claude `.claude.json` / `oauthAccount`.

---
*Note: This is an authoritative configuration source. Changes should be committed to the Git repository in `~/Work/Configs`.*
