# plasma-stuck-dim-fix

![License](https://img.shields.io/github/license/IamAndelib/plasma-stuck-dim-fix)
![KDE Plasma](https://img.shields.io/badge/Plasma-6-1d99f3)

Fixes a KDE Plasma 6 bug where the screen stays dim after you unlock it.

> **Fixed upstream in Plasma 6.8.4.** KDE merged the real fix on 2026-11-22 ([commit](https://invent.kde.org/plasma/powerdevil/-/commit/fb6c6f6f930f1cfa7f3ca90c037cac790eecc9d8)). Use this until your distro ships PowerDevil 6.8.4 or later, then run `./uninstall.sh`. Check your version with `plasmashell --version`.

## The problem

You lock the screen (or walk away), come back, unlock, and the screen is darker than before. The brightness slider still shows the same value, and moving the slider doesn't help: the moment you touch it, the screen goes dim again.

It happens "sometimes". It usually takes a lock long enough for the screen to turn off, on a monitor that disconnects when it goes to sleep (common with HDMI and DisplayPort monitors).

## Why it happens

Plasma dims an idle screen without changing your brightness. PowerDevil, Plasma's power manager, asks KWin to multiply the picture by a dimming factor (30% on the systems seen so far) and asks it to go back to 100% when you return.

The dimming is done by a part of PowerDevil that only exists while a monitor with brightness control is connected. If your only such monitor drops off while dimmed (the screen turned off and the monitor went to sleep, or you suspended), PowerDevil deletes that part, but the 30% limit it set stays behind. When the monitor comes back, the new part doesn't know it has to undim, and the leftover 30% is applied to the monitor again. It is then re-sent every time you move the slider. Restarting PowerDevil clears the leftover limit.

Upstream: fixed by [this PowerDevil commit](https://invent.kde.org/plasma/powerdevil/-/commit/fb6c6f6f930f1cfa7f3ca90c037cac790eecc9d8) (KDE bugs [513809](https://bugs.kde.org/show_bug.cgi?id=513809) and [528077](https://bugs.kde.org/show_bug.cgi?id=528077)). Similar reports: [504441](https://bugs.kde.org/show_bug.cgi?id=504441), [516631](https://bugs.kde.org/show_bug.cgi?id=516631).

## Do you have it?

While the screen looks too dark, run:

```bash
kscreen-doctor -o | grep -i 'brightness control'
```

If it says something like `set to 75% and dimming to 30%` while you're using the computer, this is your bug. Normally it says `dimming to 100%`.

Quick one-off fix:

```bash
systemctl --user restart plasma-powerdevil
```

## What this does

A small user service watches for the screen being unlocked. Three seconds later it checks every monitor. If one is still dimmed, it restarts PowerDevil and logs what it did. Otherwise it does nothing.

It never sets brightness itself, needs no root, and uses only tools that ship with Plasma and dbus.

## Install

```bash
git clone https://github.com/IamAndelib/plasma-stuck-dim-fix
cd plasma-stuck-dim-fix
./install.sh
```

This puts the script in `~/.local/bin` and enables a systemd user service.

Uninstall with `./uninstall.sh`.

## Use

```bash
plasma-stuck-dim-fix --status    # brightness and dimming per monitor
plasma-stuck-dim-fix --check     # check now, fix if stuck
journalctl --user -u plasma-stuck-dim-fix -f    # see what it did
```

Settings (set them in the service with `systemctl --user edit plasma-stuck-dim-fix`):

| Variable | Default | Meaning |
|---|---|---|
| `PLASMA_STUCK_DIM_DELAY` | `3` | Seconds to wait after unlock before checking |

## Requirements

- KDE Plasma 6 on Wayland, with a `kscreen-doctor` that shows dimming (`plasma-stuck-dim-fix --status` tells you)
- `dbus-monitor` (in `dbus-tools` on Fedora, `dbus` on Arch, `dbus-bin` on Debian/Ubuntu)

Tested on Fedora-based Bazzite with Plasma 6.8.3 and an HDMI monitor using DDC/CI brightness.

## License

GPL-3.0
