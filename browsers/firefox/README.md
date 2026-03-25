# Firefox

Shared Firefox settings live here and are linked into the local Firefox profile.

Files:
- `user.js`: privacy and browser behavior overrides
- `chrome/userChrome.css`: Firefox UI styling
- `chrome/userContent.css`: `about:` page styling
- `setup_profile.sh`: finds the active Firefox profile, normalizes it to `sky.profile`, and links the shared files

Usage on a new machine:

```bash
~/Configs/browsers/firefox/setup_profile.sh
```

Notes:
- Run it with Firefox closed if you want the profile directory renamed safely.
- Firefox should be started at least once before running the script so a profile exists.
