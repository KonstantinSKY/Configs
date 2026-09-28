# AI agents

Claude Code and Codex, with several accounts each, set up the same way on
every machine (Arch and Debian families).

```text
ai/
  Makefile                 install, accounts, status, verify
  claude/shared/           settings and folders shared by every Claude account
  claude/profiles/         tracked claude.json/settings snapshots (claude/Makefile)
  claude/statusline-command.sh
  codex/shared/            config.toml, rules, skills shared by every Codex account
  gemini/                  Gemini CLI shell rules
```

## Install

```bash
make -f ai/Makefile install-agents   # claude + codex into ~/.local/bin
make -f ai/Makefile install          # the same, plus Codex rules and verify
```

The official installers are used on every distro (`claude.ai/install.sh`,
`chatgpt.com/codex/install.sh`). They need no sudo and run no system upgrade.
Claude updates itself in the background; Codex only reports a new version. An agent that is already in `~/.local/bin` is
left alone. Run as the normal user, never with sudo.

Update both agents on this machine (every account uses the same program, so
all of them get the new version):

```bash
make -f ai/Makefile update
```

`update` always installs into the default dirs, even when started from an
account alias. Do not run `codex update` from `codexk`/`codexm`/`codexs`: with
their `CODEX_HOME` the new version would be stored inside that account dir.

AUR packages (`claude-code`, `openai-codex-bin`) are no longer used. Where
they are still installed, they sit in `/usr/bin` next to the official copy.

## Accounts

Each account is a separate config dir. The program is the same; the shell
aliases in `shell/rc` pick the dir:

```text
account   Codex                     Claude
default   ~/.codex      codex       ~/.claude      claude
k         ~/.codex-k    codexk      ~/.claude-k    claudek
m         ~/.codex-m    codexm      ~/.claude-m    claudem
s         ~/.codex-s    codexs      ~/.claude-s    claudes
```

An interactive start from a plain terminal opens a tmux session named after
the alias (`codexk`, then `codexk-2`, ...), so a closed window or a dropped
ssh does not end the agent; reattach with `tmux attach -t codexk`. Inside
tmux, for one-shot commands (`claude -p`, `codex exec`, `login`, `update`,
`--version`), or when output is piped, the agent runs directly.
`command codex` skips the wrapper.

```bash
make -f ai/Makefile accounts   # create all dirs, link them to the shared config
make -f ai/Makefile logins     # which accounts still need a login
make -f ai/Makefile status     # binaries, links, logins (read-only)
```

`accounts` links these entries in every account dir to one shared copy, so a
change applies to every account on every machine:

- Codex: `config.toml`, `rules/`, `skills/` -> `codex/shared/`
- Claude: `settings.json`, `settings.local.json`, `commands/`, `agents/`,
  `skills/`, `rules/` -> `claude/shared/`, plus `statusline-command.sh`

Existing files are kept as `<name>.backup.<date>`. A real `skills/` folder is
merged into the shared one before it is replaced by the link.

Log in to each account once per machine by starting it (`codexk`, then
`claudem` and `/login`, and so on). Logins stay local: never copy, link, or
commit `auth.json`, `.credentials.json`, `.claude.json` (`oauthAccount`),
histories, sessions, caches, or SQLite state. Sharing a login between
machines breaks it when one of them refreshes the token.

## Shared files are written by the agents

The agents update their own settings. Codex, for example, adds a trusted
project to `config.toml`. Because those files are links into this public
repository, such changes show up in `git status`. Review the diff before
committing and leave out private paths.
