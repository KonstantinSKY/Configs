# Proxmox workspace

This directory is the main entry point for Proxmox-related setup. It organizes
three different roles that should stay conceptually separate:

- **control node**: the Debian/Proxmox environment used to manage VMs;
- **Proxmox host**: the actual PVE host layer;
- **Linux guest**: a VM running Linux under Proxmox.

All Proxmox automation lives here. The role-specific Makefiles are:

```text
proxmox/control/Makefile
proxmox/host/Makefile
proxmox/guest/Makefile
```

There are no bootstrap shell scripts in this module; Makefiles are the entry
points and contain the setup logic.

## Control node

The local `control/Makefile` prepares a small Debian/Proxmox control
environment. It is intended for the machine that manages VMs, not for a full
desktop restore.

The module keeps the toolset intentionally small:

- admin basics: `gh`, `git`, `gnupg`, `pass`, `make`, `tmux`, `neovim`,
  `curl`, `wget`, `ripgrep`, `rclone`, `rsync`, `jq`, `tree`, `file`,
  `unzip`, `zip`
- access tools: `openssh-client`, `openssh-server`, `sudo`
- VM utility: `qemu-utils`

It does not install Docker, Node.js, npm, libvirt clients, MegaCMD, or desktop
packages. MegaCMD is installed from the Security module because it uses the
MEGA account bootstrap path.

## Status

Read-only inspection:

```bash
cd ~/Work/Configs/proxmox
make status
```

Equivalent explicit target:

```bash
make control-status
```

## Create or update the admin user

Run as root on the target machine:

```bash
cd /mnt/GDATA/Configs/proxmox
make user ADMIN_USER=sky
```

Optionally install an SSH public key file into the user's `authorized_keys`:

```bash
make user ADMIN_USER=sky SSH_AUTHORIZED_KEYS_FILE=/root/sky.authorized_keys
```

Passwordless sudo is off by default. Enable it only when that is the intended
host policy:

```bash
make user ADMIN_USER=sky SUDO_NOPASSWD=true
```

## Install packages

```bash
make install-packages
```

## Full bootstrap

Create/update the user and install the minimal packages:

```bash
make install ADMIN_USER=sky SSH_AUTHORIZED_KEYS_FILE=/root/sky.authorized_keys
make verify ADMIN_USER=sky
```

## Proxmox host

The host layer currently manages Tailscale on the PVE host and intentionally
does not manage users or guest packages:

```bash
make host-status
make host-install
make host-tailscale-up
make host-verify
```

For auth-key based setup:

```bash
make host-tailscale-up-key AUTH_KEY_FILE=/mnt/GDATA/Security/tailscale/proxmox.authkey
```

## Linux guest

The guest layer is for Linux VMs. It installs and verifies QEMU Guest Agent,
OpenSSH, and Tailscale inside the guest:

```bash
make guest-status
make guest-install
make guest-tailscale-up
make guest-verify
```

Before using it, enable the guest-agent channel on the Proxmox host:

```bash
qm set <VMID> --agent enabled=1
```

## Naming

Use this split when adding new Proxmox automation:

- control-node concerns go in `proxmox/control/Makefile`;
- PVE host concerns go in `proxmox/host/Makefile`;
- Linux VM concerns go in `proxmox/guest/Makefile`.
