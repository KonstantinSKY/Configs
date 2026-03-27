# Firefox

Shared Firefox settings live here and are linked into the local Firefox profile.

Files:
- `user.js`: privacy and browser behavior overrides
- `chrome/userChrome.css`: Firefox UI styling
- `chrome/userContent.css`: `about:` page styling
- `Makefile`: installs Firefox, normalizes the active profile to `sky.profile`, and links the shared files

Usage on a new machine:

```bash
make -f ~/Work/Configs/browsers/firefox/Makefile install
```

Notes:
- Run it with Firefox closed if you want the profile directory renamed safely.
- If no active profile exists yet, the Makefile creates `sky.profile` and links the shared files into it.
- Firefox Sync through your Mozilla account can restore synced data, but it does not replace this repo-managed overlay.
