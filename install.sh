#!/usr/bin/env bash
# Installs plasma-stuck-dim-fix for the current user. No root needed.
set -euo pipefail
cd "$(dirname "$0")"

bin_dir="$HOME/.local/bin"
unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

for cmd in kscreen-doctor dbus-monitor busctl systemctl; do
    command -v "$cmd" >/dev/null || { echo "missing: $cmd" >&2; exit 1; }
done

install -Dm755 bin/plasma-stuck-dim-fix "$bin_dir/plasma-stuck-dim-fix"
install -Dm644 systemd/plasma-stuck-dim-fix.service "$unit_dir/plasma-stuck-dim-fix.service"

systemctl --user daemon-reload
systemctl --user enable --now plasma-stuck-dim-fix.service

echo
"$bin_dir/plasma-stuck-dim-fix" --status
echo
echo "Installed. Logs: journalctl --user -u plasma-stuck-dim-fix -f"
