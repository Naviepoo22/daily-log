#!/usr/bin/env bash
# Append today's UTC date to log.txt, commit, and push.
# Safe to run more than once a day: only the first run commits; every run pushes,
# so a commit whose push failed earlier gets delivered on the next run.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

today="$(date -u +%F)"

git pull --ff-only --quiet

if ! grep -qx "$today" log.txt 2>/dev/null; then
  echo "$today" >> log.txt
  git add log.txt
  git commit --quiet -m "chore: log $today"
  echo "committed $today"
else
  echo "already committed $today"
fi

git push --quiet
echo "pushed"
