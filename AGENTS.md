# Configs workspace instructions

## Environment

- The authoritative repository is `~/Work/Configs`.
- `~/Work` is a separately mounted filesystem labeled `Work`.
- The target platform is EndeavourOS/Arch Linux with i3 on X11.
- `voice-ptt/.env` contains a secret and must never be printed, copied, or committed.

## Mandatory session startup

When starting work in this repository, run this read-only command first:

```bash
make status
```

Use its `STATE` and `NEXT` output to advise the user. Do not infer that a full
setup is required merely because the setup marker is absent.

After `make status`, also inspect the repository without changing it:

```bash
git status --short
```

Preserve all existing user changes. A resumed agent must treat an interrupted
setup as a state-discovery task, not as permission to restart every stage.

## State handling

- `WORK_NOT_MOUNTED`: recommend `make mount` from the temporary clone. Explain
  that it modifies `/etc/fstab` and requires sudo.
- `TEMPORARY_CLONE`: recommend `cd ~/Work/Configs`. Do not run setup from the
  temporary clone.
- `CONFIGS_NOT_FOUND`: stop and ask the user to inspect the mounted Work disk.
  Do not clone, copy, move, delete, or overwrite anything automatically.
- `NOT_EOS_WORKSTATION`: the host is not EndeavourOS (for example the Proxmox
  host, Ubuntu VMs, or CachyOS). Never recommend `make setup`, `make upgrade`,
  or `restore-core` there. Use the printed `PACKAGE_PROFILE` and recommend the
  read-only `make packages-verify-profile`; `make packages-install-profile`
  only with authorization.
- `SETUP_REQUIRED`: recommend `make setup`. Explain that it performs a full
  system upgrade and installs packages using sudo.
- `VOICE_PTT_ENV_REQUIRED`: explain that `voice-ptt/.env` must be restored or
  created. Never display or modify its contents without explicit permission.
- `VOICE_PTT_NOT_INSTALLED`: recommend `make voice-ptt`.
- `READY`: do not recommend reinstalling or upgrading anything.

`READY` currently means only that the mounted workspace, AI tools, and Voice
PTT first-run layer are ready. It does not mean that every directory in this
repository has been installed or configured.

The agent sandbox may not see desktop-session processes. A `pgrep` miss alone is
not proof that Voice PTT is stopped. If the user reports that PTT is not working,
recommend or run `make voice-ptt` with the user's authorization.

## Safety and authorization

- `make status` is always safe to run automatically.
- Never run `make mount`, `make setup`, `make upgrade`, `make dependencies`,
  `make restore-core`, mirror-management commands, `pacman`, `mount`, or any
  sudo command without explicit user authorization.
- Never mount over a non-empty unmounted `~/Work` directory.
- Never delete or overwrite an existing `~/Work/Configs` directory.
- Do not install or modify i3 unless the user explicitly requests it.

## Visible sudo prompts

When a command needs `sudo` and the sudo credential cache is not already active,
do not leave the user at an invisible PTY password prompt. Prefer opening a
visible terminal window so the user can review the command and type the password
outside chat:

```bash
alacritty -e bash -lc 'sudo <command>; echo; read -rp "Press Enter to close... "'
```

For a command plus verification, keep both in the same visible terminal:

```bash
alacritty -e bash -lc 'sudo <command>; <check command>; echo; read -rp "Press Enter to close... "'
```

Never ask the user to paste sudo passwords, account passwords, passphrases,
tokens, or recovery codes into chat. If a hidden sudo prompt was started by
mistake, cancel it before retrying in a visible terminal.

## Restore workflow

Run from a temporary clone:

```bash
make mount
```

Then continue from the repository on the mounted Work filesystem:

```bash
cd ~/Work/Configs
make setup
```

`make setup` runs these stages in order:

```text
EndeavourOS mirror tools
-> backup and rank Arch + EndeavourOS mirrors
-> full system upgrade and keyrings
-> dependencies
-> AI
-> Voice PTT
-> verify
```

This root `make setup` is deliberately the minimal first-run layer. It gives the
user a working AI assistant and Voice PTT before the rest of the workstation is
restored. Do not silently expand its meaning or assume that it configures i3,
applications, Docker, KVM, Bluetooth, or other optional services.

## OS and host detection

Before planning any work beyond the minimal first-run layer, detect the system
using read-only commands:

```bash
uname -s
cat /etc/os-release
printf '%s\n' "${XDG_SESSION_TYPE:-unknown}"
```

On Linux, use `ID` and `ID_LIKE` from `/etc/os-release` to select the distro
flow. Detect the host profile separately as `desktop`, `laptop`, or `vm`; the
i3 Makefile already provides profile detection through its `check` target.

The supported workstation is EndeavourOS (`ID=endeavouros`, `ID_LIKE=arch`)
with i3 on X11. The obsolete Manjaro-specific configuration was removed; do not
reintroduce `pacman-mirrors`, `manjaro-keyring`, Manjaro packages, or a
`manjaro/` dispatcher. EndeavourOS system setup belongs in `eos/Makefile`.

## Mandatory EndeavourOS bootstrap

On a fresh EndeavourOS installation, mirrors are a required stage before the
full upgrade. Root `make upgrade` delegates to `eos/Makefile bootstrap`, which
runs:

```text
install reflector + eos-rankmirrors if needed
-> back up both mirror lists
-> install the tracked Reflector policy
-> rank Arch mirrors with reflector
-> rank EndeavourOS mirrors with eos-rankmirrors
-> validate both mirror lists
-> restore both backups automatically on failure
-> pacman -Syu with Arch and EndeavourOS keyrings
-> ensure yay is installed
-> enable Pamac AUR support when Pamac exists
```

The two independent files are:

```text
/etc/pacman.d/mirrorlist
/etc/pacman.d/endeavouros-mirrorlist
```

The tracked Reflector policy is `eos/reflector.conf`. Do not use
`pacman-mirrors` on EndeavourOS. Do not enable `reflector.timer` automatically;
that is a separate policy decision because it can replace a known-good list
later. Do not perform another full upgrade inside later restore stages.

## Full workstation restore order

After the minimal first-run layer is `READY`, use the following dependency
order for a clean installation:

```text
detect OS/session/host
-> mount Work
-> EndeavourOS mirrors, keyrings, and full system upgrade
-> base dependencies
-> AI and Voice PTT
-> workspace directories and XDG symlinks
-> Git and shell
-> X11 session environment
-> fonts, GTK, and Qt
-> terminal and editors
-> rofi and picom
-> i3 host profile
-> desktop applications
-> explicitly selected system services
-> verification
-> re-login or reboot when required
```

Existing leaf entry points, in that order, are:

```bash
make -f workspace/Makefile symlinks
make -f git/Makefile link
make -f zsh/Makefile setup      # zsh + p10k, shell/ loader block, chsh
make -f xprofile/Makefile install
make -f fonts/Makefile install
make -f gtk/Makefile install
make -f qt/Makefile install
make -f alacritty/Makefile install
make -f nvim/Makefile install
make -f zed/Makefile install
make -f rofi/Makefile link
make -f picom/Makefile install
make -f i3/Makefile check
make -f i3/Makefile setup
```

The root Makefile now provides a resumable core orchestrator:

```bash
make restore-status
make restore-core
```

`restore-status` is read-only. `restore-core` is an authorized aggregate only
when the user explicitly asks to run it; it installs packages and may request
sudo. It deliberately does not perform another full system upgrade because the
minimal first-run `make setup` already did that. It installs packages with
`--needed` and records successful stage checkpoints under
`~/.local/state/configs/restore-core-v1/`.

The implemented stages are `packages`, `workspace`, `user`, `desktop`, and
`verify`. On rerun, completed checkpoints are skipped. Checkpoints assist
recovery but do not override real package, link, or service inspection when a
stage appears inconsistent.

## Package profiles

`packages/Makefile` picks one profile per machine from the distro family and
the machine class. The class uses the same rule as `shell/rc`: an installed
graphical session (`/usr/share/xsessions` or `/usr/share/wayland-sessions`)
means `desktop`, otherwise `server`.

```text
arch-desktop    base, tailscale, workstation core, i3 desktop group*, fonts
arch-server     base, tailscale, zsh/tmux/neovim
debian-desktop  base, tailscale, CLI core (no Debian desktop set is mapped)
debian-server   base, tailscale, CLI core (zsh/tmux/neovim)

* only when /usr/share/xsessions/i3.desktop exists
```

`make -f packages/Makefile detect` prints the family, class, `I3_SESSION`, and
profile; `profile` prints only the name. `install-profile` and `verify-profile`
follow the table. The i3 desktop group is skipped on desktops without i3 (for
example CachyOS with sway); an explicit `make -f packages/Makefile
install-desktop` still installs it, and counts as the user's request for i3.

Arch package groups need yay. `install-yay-arch` installs it from the distro
repository (EndeavourOS, CachyOS) or builds `yay-bin` from AUR on plain Arch,
and the Arch install targets call it first. `install-server-core-arch` uses
pacman only.

Root `restore-status` and `restore-core` target only `arch-desktop` machines
with i3; other profiles report `PROFILE_NOT_SUPPORTED`.

## Shell layer

All interactive shell configuration lives in `shell/` and is shared by bash
and zsh on every machine. `zsh/rc` was removed; do not reintroduce a
zsh-only rc or per-machine rc files.

```text
shell/rc          shared: paths, editor, helpers, t1..t5/tl, AIX, claude/codex,
                  pass helpers, upd/updf by package family, zsh prompt
shell/gui.rc      only what needs a display: zeditor/z, winmt, cachyos
shell/server.rc   gs, ports, svc-failed, logs; Proxmox aliases when pveversion exists
shell/Makefile    status (read-only), link, verify
```

`shell/rc` picks the machine class on every start and exports it as
`CONFIGS_SHELL_CLASS`: `gui` when `/usr/share/xsessions` or
`/usr/share/wayland-sessions` exists, otherwise `server`. There are no roles,
no class override file, and no per-host variables. Put new settings in
`shell/rc` unless they truly need a display (`gui.rc`) or only make sense on
servers (`server.rc`). Aliases for programs that are not installed are fine.

Rules for editing `shell/`:

- Code must run in both bash and zsh. Guard zsh-only code with
  `[ -n "${ZSH_VERSION:-}" ]`.
- Define functions as `function name { ... }`, not `name() { ... }`.
  Frameworks such as oh-my-zsh (CachyOS) predefine aliases like `la`, and the
  `name()` form then fails to parse and stops the rest of rc from loading.
- The file must end with a successful status so the first prompt does not show
  an error; use `if ...; fi` rather than a trailing `test && action`.
- Do not start tmux automatically. AIX creates its own `aix-*` tmux sessions
  only when launched outside tmux; the user attaches to plain shells with
  `t1`..`t5`.
- Configs is a public repository. Do not reference private directories from
  `shell/`; machine-local or private additions go in
  `~/.config/configs/local.rc`, which `shell/rc` sources when present.
- Check changes with `make -f shell/Makefile verify` and an interactive login
  on at least one bash server and one zsh workstation.

`make -f shell/Makefile link` (also called by `make -f zsh/Makefile link` and
`setup`) writes a `# >>> configs shell >>>` block to `~/.bashrc`, and to
`~/.zshrc` when zsh exists, replaces the old `custom shell config` block,
keeps a backup of each changed file, and needs no sudo. The login shell must
be bash or zsh; fish does not read these files.

Current machines, all using `~/Work/Configs` from the shared Work disk:

```text
pve    Proxmox VE host (Debian 13)   server  bash  Work is the local btrfs disk
end    EndeavourOS, i3 (VM 100)      gui     zsh   Work via virtiofs tag gdata
dev    Ubuntu 26.04 (VM 101)         server  bash  Work via virtiofs tag gdata
prod   Ubuntu 26.04 (VM 102)         server  bash  Work via virtiofs tag gdata
cachy  CachyOS, sway (VM 104)        gui     zsh   Work via virtiofs tag gdata
```

VMs mount Work with this `/etc/fstab` line after the Proxmox VM has
`virtiofs0: dirid=gdata`:

```text
gdata /home/sky/Work virtiofs rw,relatime,nofail,x-systemd.mount-timeout=10s 0 0
```

## AI agents

Claude Code and Codex are installed per user with the official installers into
`~/.local/bin` on every distro; the AUR packages are no longer used. Details
are in `ai/README.md`.

```bash
make -f ai/Makefile status           # read-only: binaries, account links, logins
make -f ai/Makefile install-agents   # no sudo; skips agents already installed
make -f ai/Makefile update           # latest claude + codex for all accounts
make -f ai/Makefile accounts         # account dirs linked to ai/*/shared
```

- Accounts are `default`, `k`, `m`, `s` for both agents (`~/.codex-k`,
  `~/.claude-m`, ...), started with the `codexk`/`claudem` aliases from
  `shell/rc`.
- Settings are shared through links to `ai/codex/shared` and
  `ai/claude/shared`. Logins are per machine and are never copied, linked,
  printed, or committed; the user logs in to each account.
- `accounts` replaces existing files with links (keeping backups) and merges a
  real `skills/` folder into the repository. Run it on a machine only with the
  user's authorization.
- The agents write to the shared files (Codex adds trusted projects to
  `config.toml`). Review that diff before committing; do not commit private
  paths.
- Do not install the agents with sudo, npm, or AUR, and do not change AIX
  account records (`exec_path`, homes) without a separate decision.

## User-level updates

`make user-update` runs the `update` target of each module in
`USER_UPDATE_MODULES` (root Makefile), currently `ai`. A failed module does not
stop the others; the target fails at the end and names it. Only add a module
whose `update` needs no sudo and asks nothing, because it runs unattended.
Never add `eos`, `fonts`, or `flatpak`: their `update` targets use sudo.

`autoupdate/` holds a systemd user timer (daily 04:00 America/Los_Angeles on
every machine, random delay up to 30 min, catches up after downtime) that runs
`make user-update`. The unit files
live in the repository and are linked into `~/.config/systemd/user`.
`make -f autoupdate/Makefile status` is read-only; `install` enables the timer
on the current machine and needs the user's authorization. Machines without a
standing login need `sudo loginctl enable-linger sky` once.

## Optional and non-restore directories

Only configure these roles when the user explicitly selects them:

- `bluetooth`: installs packages and enables a system service.
- `docker`: enables Docker and adds the user to the privileged `docker` group.
- `kvm`: changes libvirt/QEMU services, groups, configuration, and networking.
- `megasync`: installs a user service and may enable user lingering.
- `proxmox`: the single Proxmox workspace. Its root Makefile delegates to
  `proxmox/control`, `proxmox/host`, and `proxmox/guest`. Run the read-only
  `status`, `host-status`, or `guest-status` target first. Installation,
  service changes, user changes, and Tailscale authentication require explicit
  authorization. Auth keys must live outside git, in a private directory that
  this repository does not name.
- SSH targets: enable a network service and may change authentication policy.

`projects`, `rust`, and `metatrader` are project generators or templates, not
workstation restore stages. `tmux/Makefile` only links `tmux/.tmux.conf`; the
tmux session helpers live in `shell/rc`.

`browsers/Makefile` now uses the EndeavourOS package flow. Browser installation
is still an application stage, not part of the minimal AI/Voice setup.

## Resuming after interruption

When a previous agent or command may have stopped partway through:

1. Run `make status` and `git status --short`.
2. Re-detect OS, session type, and host profile if the next stage depends on
   them.
3. Identify the last completed stage using that stage's read-only `status`,
   `check`, or `verify` target where available.
4. Inspect package presence, symlink destinations, service state, and group
   membership rather than relying only on a marker file.
5. Continue from the first incomplete stage. Do not rerun `mount`, mirror
   ranking, a full system upgrade, destructive cleanup, or every earlier stage
   by default. Inspect mirror headers and backup files before deciding that a
   mirror stage was interrupted.
6. Ask for explicit authorization before any resumed command that uses sudo,
   installs/removes packages, changes services/groups, or replaces files.

Most leaf Makefiles are intended to be idempotent, but some perform backups,
package removal, service restarts, or repeated full updates. Verify the exact
target before using it as a recovery action.
