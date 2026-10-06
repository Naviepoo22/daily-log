#!/usr/bin/env bash
# Install a systemd timer that runs commit.sh once a day as the current user.
# Usage: ./install.sh [HH:MM]   (24h, in the VM's timezone; default 09:00)
# Re-run to change the time. Remove with: ./install.sh --uninstall
set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
UNIT=/etc/systemd/system/daily-log

if [ "${1:-}" = "--uninstall" ]; then
  sudo systemctl disable --now daily-log.timer || true
  sudo rm -f "$UNIT.service" "$UNIT.timer"
  sudo systemctl daemon-reload
  echo "removed daily-log timer"
  exit 0
fi

TIME="${1:-09:00}"
case "$TIME" in
  [0-2][0-9]:[0-5][0-9]) ;;
  *) echo "time must be HH:MM, got '$TIME'" >&2; exit 1 ;;
esac

sudo tee "$UNIT.service" >/dev/null <<EOF
[Unit]
Description=Daily log commit
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
User=$USER
ExecStart=$DIR/commit.sh
EOF

sudo tee "$UNIT.timer" >/dev/null <<EOF
[Unit]
Description=Run daily-log commit once a day

[Timer]
OnCalendar=*-*-* $TIME:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now daily-log.timer
systemctl list-timers daily-log.timer --no-pager
