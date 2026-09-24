# Shell Architecture

This module is a draft layout for shared shell startup files.
Nothing here is connected to `~/.bashrc`, `~/.zshrc`, or the existing
`Configs/zsh/rc` until an install/link target is added and run on purpose.

## Layout

```text
Configs/shell/
  Makefile
  README.md

  rc.common
  rc.interactive
  rc.tmux

  roles/
    workstation.rc
    proxmox.rc
    dev.rc
    prod.rc

  shells/
    bashrc
    zshrc
```

## Startup Model

The shell wrapper loads the shared layers first, then an optional machine role.

```text
shells/bashrc or shells/zshrc
  -> rc.common
  -> rc.interactive
  -> rc.tmux
  -> roles/$CONFIGS_SHELL_ROLE.rc
```

Role examples:

```sh
CONFIGS_SHELL_ROLE=proxmox
CONFIGS_TMUX_AUTO=ssh
```

```sh
CONFIGS_SHELL_ROLE=workstation
CONFIGS_TMUX_AUTO=off
```

`CONFIGS_TMUX_AUTO` accepts:

```text
off  - never auto-start tmux
ssh  - auto-start tmux only for SSH sessions
all  - auto-start tmux for every interactive terminal
```

## Roles

`workstation` is for the main graphical desktop.

`proxmox` is for the Proxmox control and backup node.

`dev` is for development VMs.

`prod` is for production machines with a minimal and cautious shell.

## Current Status

This is a proposed structure only. The current `Configs/zsh/rc` remains the
active workstation rc until we explicitly migrate or source this module.
