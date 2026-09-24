# CachyOS SPICE launcher

Starts Proxmox VM 104 when needed and opens its SPICE console with
`remote-viewer`.

This launcher uses the same Proxmox API token flow as `windows-mt`, so it does
not require manually opening a `.vv` file.

## Install

The system needs network access to the Proxmox host and the commands `curl`,
`jq`, and `remote-viewer`.

Credentials are intentionally managed outside this repository. By default, this
launcher reuses the existing `~/.config/winmt-spice/token` token file.

```sh
make install
```
