# Autoupdate

A systemd user timer that runs `make user-update` once a day on each machine.
`make user-update` updates the modules listed in `USER_UPDATE_MODULES` in the
root Makefile (currently `ai`). Nothing here needs sudo except linger.

```text
configs-update.service   runs make -C ~/Work/Configs user-update
configs-update.timer     daily at 04:00, random delay up to 30 min,
                         catches up after the machine was off
```

```bash
make -f autoupdate/Makefile status    # links, next/last run, linger (read-only)
make -f autoupdate/Makefile install   # link units, enable the timer
make -f autoupdate/Makefile run       # update now and show the log
make -f autoupdate/Makefile remove    # disable and unlink
journalctl --user -u configs-update   # full log
```

The units stay here; `~/.config/systemd/user` only links to them, so a change
reaches every machine. After changing a unit, run
`systemctl --user daemon-reload` on each machine (`install` does it).

A user timer runs only while the user has a session. On machines where nobody
stays logged in, enable linger once: `sudo loginctl enable-linger sky`.
