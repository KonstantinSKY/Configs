# Handoff

Рабочая директория: `/home/sky/Work/Configs`.

В начале новой сессии выполнить:

```bash
make status
git status --short --branch
```

Ожидаемое состояние:

- `make status`: `STATE: READY`, `NEXT: none`
- git: `## main...origin/main`, clean
- Work mounted: `/home/sky/Work`
- `restore-core`: `packages`, `workspace`, `user`, `desktop`, `verify` done

## Уже сделано

- Audio/dunst fixed: звук и volume OSD на центральном мониторе.
- Browsers, Telegram, Flatpak installed.
- Bluetooth installed/enabled/active.
- KVM installed; libvirt default network active/autostart.
- Docker installed; `docker.service` enabled/active; `sky` добавлен в `docker`.
- Rust installed: `rustc/cargo 1.97.0`, `rustup`, `rust-analyzer`, `clippy`, `rustfmt`.
- Neovim installed/config linked; Tree-sitter parsers актуальны.
- Zed installed/config linked; installer не делает full system update.
- tmux linked: `~/.tmux.conf -> /home/sky/Work/Configs/tmux/.tmux.conf`.

## После reboot/re-login проверить

```bash
id -nG
docker ps
make -f kvm/Makefile status
make -f bluetooth/Makefile status
make -f zed/Makefile status
ls -l /run/docker.sock /var/run/docker.sock
```

Ожидаемо:

- активная login-сессия должна видеть группы `docker` и `libvirt`;
- `docker ps` должен выполняться без `sudo`;
- `/run/docker.sock` и `/var/run/docker.sock` должны быть `root:docker` с mode `srw-rw----`;
- KVM использует modular libvirt: `virtqemud.socket` и `virtnetworkd.socket` active;
- legacy `libvirtd.service` может быть `disabled/inactive`, это не ошибка при active modular sockets;
- Bluetooth service enabled/active, controller powered on.

До reboot текущая shell-сессия может не видеть новые группы даже если `/etc/group`
уже содержит `sky` в `docker`/`libvirt`. Если после reboot `docker ps` всё ещё
даёт permission denied, сначала проверить `id -nG` и owner/group Docker socket.

## Осталось опционально

- `megasync/` из public `Configs` не закончен:
  - `megacmd` установлен
  - `megasync` package/service не установлен
  - `~/.config/systemd/user/mega-cmd-server.service` отсутствует
  - `Linger=no`
- Не путать public `Configs/megasync` с отдельным `/home/sky/Work/Security`.
- `metatrader/` — генератор/шаблоны, не restore stage.
- `projects/` Rust path рабочий; Node/Python toolkits намеренно не делались.

## Нельзя

- Не читать, не печатать, не копировать и не коммитить `voice-ptt/.env`.
- Не запускать `make setup`, `make upgrade`, `make dependencies`, `make restore-core`, `pacman`, `mount`, `sudo` без явного разрешения.
- Учитывать, что sandbox может не видеть desktop/systemd/D-Bus процессы.
