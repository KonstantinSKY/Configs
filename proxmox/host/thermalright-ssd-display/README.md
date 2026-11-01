# Thermalright SSD cooler display

Driver for the digital display on the Thermalright Digital White M.2 SSD
cooler, installed on the Proxmox host (`pve`). Without a host program the
display only shows a spinning circle.

## Hardware

- USB `0416:8001` "Nuvoton HID Transfer" (`/dev/hidraw*`, 64-byte reports).
- Handshake reply: `PM=129 SUB=96` → LED style **LF11** (38 LEDs: `SSD`, `%`,
  `MB/s` indicators + five 7-segment digits).
- No fan RPM: the display shows temperature, busy %, read MB/s, write MB/s.
- The cooler sits on the **Samsung 990 PRO 2TB = `nvme0`**
  (`nvme1` is the 970 EVO Plus system disk).

The protocol was ported from
[trcc-linux](https://github.com/Lexonight1/thermalright-trcc-linux)
(`core/led_protocol.py`, `adapters/device/led.py`, `services/led_segment.py`).
The driver is a single stdlib-only Python script; no trcc install is needed.

## Files

| Repo file | Installed to |
|---|---|
| `thermalright-ssd-display` | `/usr/local/bin/thermalright-ssd-display` |
| `thermalright-ssd-display.service` | `/etc/systemd/system/thermalright-ssd-display.service` |
| `thermalright-ssd-display.default` | `/etc/default/thermalright-ssd-display` (settings) |

## Usage

```bash
cd ~/Work/Configs/proxmox/host/thermalright-ssd-display
make status      # read-only
make install     # sudo; does not overwrite existing /etc/default settings
make verify
make uninstall
```

Settings in `/etc/default/thermalright-ssd-display`, then
`systemctl restart thermalright-ssd-display`:

- `TR_DISK=nvme0` — NVMe controller to show.
- `TR_PHASES=temp,busy,read,write` — screens to rotate (e.g. `temp` only).
- `TR_PHASE_SECONDS=3` — seconds per screen.
- `TR_COLOR=255,255,255` — segment RGB color.

## Notes

- The firmware answers the handshake only once per power cycle; the driver
  continues without a reply.
- Values below 1 MB/s show as `0` (the display has no decimal point).
- The service restarts on failure and the driver reconnects if the USB device
  disappears.
