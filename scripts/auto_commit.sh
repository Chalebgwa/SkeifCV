#!/usr/bin/env bash
# Auto committer script
# Usage:
#   ./scripts/auto_commit.sh                    -> run once, commit if changes
#   ./scripts/auto_commit.sh --push             -> commit and push to current branch
#   ./scripts/auto_commit.sh --loop 300         -> run every 300s (loop), use --push to push
#   ./scripts/auto_commit.sh --install-cron     -> add a crontab entry to run this script
#   ./scripts/auto_commit.sh --remove-cron      -> remove the crontab entry
#   ./scripts/auto_commit.sh --cron-schedule '*/10 * * * *' -> set schedule when installing
#
# Note: ensure executable: chmod +x scripts/auto_commit.sh

set -euo pipefail

PUSH=false
LOOP_INTERVAL=0
INSTALL_CRON=false
REMOVE_CRON=false
CRON_SCHEDULE="*/5 * * * *"

# simple arg parse
while [[ $# -gt 0 ]]; do
  case "$1" in
    --push) PUSH=true; shift ;;
    --loop) LOOP_INTERVAL="${2:-60}"; shift 2 ;;
    --install-cron) INSTALL_CRON=true; shift ;;
    --remove-cron) REMOVE_CRON=true; shift ;;
    --cron-schedule) CRON_SCHEDULE="${2:-$CRON_SCHEDULE}"; shift 2 ;;
    --help|-h) echo "Usage: $0 [--push] [--loop SECONDS] [--install-cron] [--remove-cron] [--cron-schedule SCHEDULE]"; exit 0 ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  echo "Not inside a git repository."
  exit 1
fi
cd "$repo_root"

script_path="$repo_root/scripts/auto_commit.sh"
log_file="$repo_root/.auto_commit.log"
# Build the exact cron line we'll install/remove
cron_line="$CRON_SCHEDULE bash \"$script_path\" --push >> \"$log_file\" 2>&1"

install_cron() {
  current="$(crontab -l 2>/dev/null || true)"
  if echo "$current" | grep -F -x -q "$cron_line"; then
    echo "Cron job already installed."
    return 0
  fi
  (echo "$current"; echo "$cron_line") | crontab -
  echo "Installed cron job: $cron_line"
}

remove_cron() {
  current="$(crontab -l 2>/dev/null || true)"
  # Remove exact matching line
  updated="$(echo "$current" | grep -F -v -x -- "$cron_line" || true)"
  if [[ -z "$updated" ]]; then
    # If updated is empty, remove all crontab entries
    crontab -r 2>/dev/null || true
    echo "Removed cron job (crontab now empty)."
  else
    echo "$updated" | crontab -
    echo "Removed cron job (if present)."
  fi
}

# If user requested cron install/remove, do that and exit
if [[ "$INSTALL_CRON" == "true" ]]; then
  install_cron
  exit 0
fi

if [[ "$REMOVE_CRON" == "true" ]]; then
  remove_cron
  exit 0
fi

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
