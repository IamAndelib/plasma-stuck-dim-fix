#!/usr/bin/env bash
# Removes plasma-stuck-dim-fix for the current user.
set -euo pipefail

unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

systemctl --user disable --now plasma-stuck-dim-fix.service 2>/dev/null || true
rm -f "$unit_dir/plasma-stuck-dim-fix.service" "$HOME/.local/bin/plasma-stuck-dim-fix"
systemctl --user daemon-reload

echo "Removed."
