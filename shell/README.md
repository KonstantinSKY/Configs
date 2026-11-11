# Shell layer

One shell configuration for every machine, loaded by both bash and zsh.

```text
shell/
  rc          shared settings for all machines
  gui.rc      additions for machines with a graphical session
  server.rc   additions for machines without one
  Makefile    status, link, verify
```

## How it loads

```text
~/.bashrc or ~/.zshrc
  -> shell/rc
       shared: paths, editor, helpers, t1..t5/tm/tl, AIX, claude/codex, pass, upd
       -> gui.rc     if /usr/share/xsessions or /usr/share/wayland-sessions exists
       -> server.rc  otherwise (plus Proxmox aliases when pveversion exists)
       -> powerlevel10k (zsh only, when installed)
       -> ~/.config/configs/local.rc (optional, machine-local, not in git)
```

The class is detected on every start and exported as `CONFIGS_SHELL_CLASS`.
Aliases for programs that are not installed are harmless.

tmux is never started automatically: use `t1`..`t5`, `tm <session>` to attach
to any named session, and `tl` to list sessions. AIX creates its own tmux
sessions when started from a plain shell. `upd` and `updf` run the system
update in a tmux session named `upd`, so a dropped ssh (for example when the
update restarts tailscaled) does not leave apt or pacman hanging; run `upd`
again to attach to an update that is still in progress.

## Zed on the shared Work filesystem

All development and agents run on `dev`. The `z` function opens paths under
`~/Work` on `dev` over SSH Remote (`ssh://dev/...`). There, dev's own file
watcher sees the agents' changes, including git, without polling. Set
`Z_REMOTE_HOST` to use another host.

`z` falls back to local Zed through `zl` when `dev` does not answer SSH within
3 seconds, when a path is outside `~/Work`, or when the shell already runs on
`dev`. `zl` always opens locally with `ZED_FILE_WATCHER_MODE=poll`. Polling
detects changes made by another VM on the shared Work filesystem even when the
local kernel sends no file-change event. The variable applies only to that Zed
invocation; it is not exported into the rest of the shell.

`z` opens the current directory; `z /path/to/project` opens that path, and
`z a.txt b.txt` opens several files in one call.
`VISUAL` is `zeditor --wait`, so `git commit` and `crontab -e` wait until the
file is closed in Zed.
After changing the function, open a new terminal or source `shell/gui.rc`.
Fully quit an already running Zed before starting it through `z`: a CLI
invocation can otherwise forward to the existing process with its old watcher
mode. Direct `zeditor` and desktop-menu launches do not use this function.

## Install

```bash
make -f shell/Makefile status
make -f shell/Makefile link
```

`link` writes this block to `~/.bashrc`, and to `~/.zshrc` when zsh exists:

```sh
# >>> configs shell >>>
export CONFIGS_SHELL_DIR="/home/sky/Work/Configs/shell"
[ -r "$CONFIGS_SHELL_DIR/rc" ] && . "$CONFIGS_SHELL_DIR/rc"
# <<< configs shell <<<
```

It replaces the old `custom shell config` block that loaded `zsh/rc`, keeps a
backup of each changed file, and does nothing when the file is already current.
No sudo is needed.

The login shell must be bash or zsh; fish does not read these files.

## Private settings

Configs is a public repository. Keep anything tied to private directories
in `~/.config/configs/local.rc`, not here.
