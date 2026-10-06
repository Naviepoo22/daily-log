#!/usr/bin/env bash
# Make 3-7 commits per day to log.txt (one line each), then push.
# The daily count is derived from the date, so it varies day to day but every run on
# the same day agrees on it. Re-running only tops up missing commits; every run pushes,
# so commits whose push failed earlier get delivered on the next run.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

today="$(date -u +%F)"
target=$(( 3 + $(printf '%s' "$today" | cksum | cut -d' ' -f1) % 5 ))

git pull --ff-only --quiet

done_count="$(grep -c "^$today" log.txt 2>/dev/null || true)"
done_count="${done_count:-0}"

for (( i = done_count + 1; i <= target; i++ )); do
  echo "$today #$i" >> log.txt
  git add log.txt
  git commit --quiet -m "chore: log $today ($i/$target)"
done
echo "$today: $target commits (had $done_count)"

git push --quiet
echo "pushed"
