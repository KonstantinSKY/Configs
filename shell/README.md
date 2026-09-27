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
       shared: paths, editor, helpers, t1..t5/tl, AIX, claude/codex, pass, upd
       -> gui.rc     if /usr/share/xsessions or /usr/share/wayland-sessions exists
       -> server.rc  otherwise (plus Proxmox aliases when pveversion exists)
       -> powerlevel10k (zsh only, when installed)
       -> ~/.config/configs/local.rc (optional, machine-local, not in git)
```

The class is detected on every start and exported as `CONFIGS_SHELL_CLASS`.
Aliases for programs that are not installed are harmless.

tmux is never started automatically: use `t1`..`t5`. AIX creates its own
tmux sessions when started from a plain shell.

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
(for example Security) in `~/.config/configs/local.rc`, not here.
