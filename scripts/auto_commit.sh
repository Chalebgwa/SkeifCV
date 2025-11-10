#!/usr/bin/env bash
# Auto committer script
# Usage:
#   ./scripts/auto_commit.sh            -> run once, commit if changes
#   ./scripts/auto_commit.sh --push     -> commit and push to current branch
#   ./scripts/auto_commit.sh --loop 300 -> run every 300s (loop), use --push to push
#
# Note: ensure executable: chmod +x scripts/auto_commit.sh

set -euo pipefail

PUSH=false
LOOP_INTERVAL=0

# simple arg parse
while [[ $# -gt 0 ]]; do
  case "$1" in
    --push) PUSH=true; shift ;;
    --loop) LOOP_INTERVAL="${2:-60}"; shift 2 ;;
    --help|-h) echo "Usage: $0 [--push] [--loop SECONDS]"; exit 0 ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  echo "Not inside a git repository."
  exit 1
fi
cd "$repo_root"

commit_changes() {
  # Detect unstaged or uncommitted changes
  if [[ -n "$(git status --porcelain)" ]]; then
    git add -A
    now="$(date -u +'%Y-%m-%d %H:%M:%SZ')"
    branch="$(git rev-parse --abbrev-ref HEAD)"
    git commit -m "Auto commit: ${now}"
    echo "Committed changes on ${branch} at ${now}"
    if [[ "$PUSH" == "true" ]]; then
      git push origin "$branch" || echo "Push failed"
    fi
  else
    echo "No changes to commit."
  fi
}

if [[ "$LOOP_INTERVAL" -gt 0 ]]; then
  echo "Starting loop with interval ${LOOP_INTERVAL}s. PUSH=${PUSH}"
  while true; do
    commit_changes || true
    sleep "$LOOP_INTERVAL"
  done
else
  commit_changes
fi
