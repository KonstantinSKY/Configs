# VM 100: USB controller passthrough for the Bluetooth headset

VM 100 (`Endeavouros`, the `eos` workstation) gets one whole chipset USB
controller through PCIe/VFIO. This file records the host side so it can be
restored after a Proxmox reinstall or a VM move. The guest side lives in
`bluetooth/` (`headset-install`, `headset-verify`,
`bluetooth/wireplumber/51-bt-headset-mic.conf`).

## Why the whole controller

The Bluetooth adapter is a Foxconn/MediaTek MT7922 (USB `0489:e10a`); the
Sony WH-XB910N headset with its mic connects to it.

It used to be passed as a single USB device (`usbN: host=0489:e10a`) behind
QEMU's emulated XHCI. QEMU broke the headset audio (SCO over isochronous USB
transfers): the guest logged `corrupted SCO packet`, only CVSD (8 kHz) worked,
and mSBC gave silent headphones.

With the real controller passed through, the adapter sits on real hardware
(guest PCI `02:00.0`), there are no SCO errors, and mSBC works for both sound
and mic.

## Current configuration

Recorded 2026-11-01 on `pve` (pve-manager 9.2.20, kernel 7.0.14-19-pve).

`qm config 100` (relevant lines):

```text
name: Endeavouros
machine: q35
bios: ovmf
hostpci0: 0000:03:00,pcie=1,x-vga=1,driver=keep
hostpci1: 0000:14:00.0,pcie=1
usb0: host=045e:07a5
usb1: host=046d:c52b
```

- `hostpci0` is the GPU (RX 6600, `1002:73ff` + `1002:ab28`). It is unrelated to
  this file and is listed only for context.
- `hostpci1` is the USB controller.
- `usb0`/`usb1` are the Microsoft and Logitech wireless receivers. They stay
  on the host controller and are forwarded as single USB devices. No `usbN`
  entry for `0489:e10a` remains, and none should.

Passed-through controller:

```text
PCI address   0000:14:00.0
Device        AMD 800 Series Chipset USB 3.x XHCI Controller [1022:43fd] (rev 01)
Subsystem     ASMedia [1b21:1142]
PCI path      00:02.1 -> 04:00.0 -> 05:0c.0 -> 14:00.0
ACPI path     \_SB_.PCI0.GPP7.UP00.DP60.XH00
IOMMU group   22: 05:0c.0 (PCIe switch downstream port, pcieport, stays on host)
                  14:00.0 (this controller)
Host driver   vfio-pci (while VM 100 runs); module xhci_pci
```

The host has a second, identical controller that it keeps:

```text
0000:12:00.0  [1022:43fd]  IOMMU group 21  xhci_hcd  (host USB buses usb1/usb2)
              path 00:02.1 -> 04:00.0 -> 05:08.0 -> 0a:00.0 -> 0b:0c.0 -> 12:00.0
```

Devices on 12:00.0 (they stay on the host): the Thermalright display
`0416:8001`, the Logitech receiver `046d:c52b` and Microsoft receiver
`045e:07a5` (forwarded via `usb1`/`usb0`), and MSI USB Audio `0db0:cd0e`.

## What goes to the VM with the controller

Everything plugged into the ports of 14:00.0 goes into the VM:

- Bluetooth adapter MT7922 `0489:e10a`;
- webcam eMeet C960;
- MSI Mystic Light (RGB controller).

While VM 100 runs, the host has no access to these ports. The controller's
buses do not appear in the host's `lsusb`. A device plugged into one of these
ports appears only in the guest. The physical port mapping was not checked from
the host because it cannot enumerate a controller bound to vfio-pci. To see the
mapping, run `lsusb -t` in the guest and look under PCI `02:00.0`.

## IOMMU and VFIO settings

No extra host configuration was needed for this controller:

- Kernel command line is only `quiet` (`/proc/cmdline`,
  `GRUB_CMDLINE_LINUX_DEFAULT="quiet"`, no `/etc/kernel/cmdline`). AMD-Vi is
  enabled by default on this platform, so neither `amd_iommu=on` nor `iommu=pt`
  is set.
- `/etc/modprobe.d/vfio.conf` lists only the GPU:
  `options vfio-pci ids=1002:73ff,1002:ab28`.
- Proxmox binds 14:00.0 to vfio-pci itself when the VM starts, because
  `hostpci1` has no `driver=keep`.

Do not add `1022:43fd` to `vfio-pci ids=`. Both chipset controllers share
that ID, so the host would also lose 12:00.0 with the Thermalright display and
the receivers.

## Restore

1. Check that IOMMU is active and the controller has a clean group:

   ```bash
   dmesg | grep -i AMD-Vi
   ls /sys/kernel/iommu_groups/$(basename $(readlink /sys/bus/pci/devices/0000:14:00.0/iommu_group))/devices
   ```

   Expect only the controller plus its PCIe bridge (`05:0c.0`).

2. Make sure the address still points at the right controller, because both
   have the same ID. The right one is the controller that carries the Bluetooth
   adapter (ACPI `...DP60.XH00`, behind `05:0c.0`). With the controller on the
   host driver (VM stopped):

   ```bash
   for d in /sys/bus/usb/devices/*; do
     [ "$(cat $d/idVendor 2>/dev/null):$(cat $d/idProduct 2>/dev/null)" = 0489:e10a ] && readlink -f $d
   done
   ```

   The PCI address before `/usbN/` in the output is the controller to pass
   through.

3. Add it to the VM. VM 100 must use `machine: q35`, which `pcie=1` requires.
   The change takes effect at the next VM start:

   ```bash
   qm set 100 --hostpci1 0000:14:00.0,pcie=1
   ```

4. Remove any single-device passthrough of the adapter, if one exists:

   ```bash
   qm config 100 | grep 0489:e10a      # e.g. usb2: host=0489:e10a
   qm set 100 --delete usb2
   ```

Note: VM 100 is the workstation the SSH session usually comes from. Stopping
it from that session cuts the session off. Run the stop/start detached, for
example with `systemd-run`.

## Verify

On the host:

```bash
qm config 100 | grep -E '^(hostpci|usb)'
lspci -nnk -s 14:00.0          # Kernel driver in use: vfio-pci while VM 100 runs
```

In the guest (`eos`):

```bash
lspci -nn | grep 1022:43fd     # the controller at 02:00.0
make -f bluetooth/Makefile headset-verify
```

`headset-verify` warns when the adapter is again behind the emulated QEMU XHCI
(then only CVSD works).
