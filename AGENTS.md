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
make -f zsh/Makefile setup
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

## Optional and non-restore directories

Only configure these roles when the user explicitly selects them:

- `bluetooth`: installs packages and enables a system service.
- `docker`: enables Docker and adds the user to the privileged `docker` group.
- `kvm`: changes libvirt/QEMU services, groups, configuration, and networking.
- `megasync`: installs a user service and may enable user lingering.
- SSH targets: enable a network service and may change authentication policy.

`projects`, `rust`, and `metatrader` are project generators or templates, not
workstation restore stages. `tmux` currently contains configuration but has no
Makefile installer.

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
