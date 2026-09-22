# Windows-MT SPICE launcher

Starts Proxmox VM 103 when needed and opens its SPICE console with
`remote-viewer`.

## Install

The system needs network access to the Proxmox host and the commands `curl`,
`jq`, and `remote-viewer`.

Credentials are intentionally managed outside this repository. Make a private
credential file available locally, then run:

```sh
make install TOKEN_SOURCE=/path/to/private/credential
```

After installation, the launcher reads credentials through the local path
`~/.config/winmt-spice/token`.
