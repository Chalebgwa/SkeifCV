#!/usr/bin/env bash
# Watch for file saves and trigger the auto-committer.
# Usage:
#   ./scripts/watch_on_save.sh               -> watch repo root, run auto-committer on save
#   ./scripts/watch_on_save.sh --push        -> forward --push to auto-committer
#   ./scripts/watch_on_save.sh --debounce 2  -> use 2s debounce between triggers
#   ./scripts/watch_on_save.sh --path src    -> watch a specific path (relative to repo root)
#
# Requires: inotifywait (Linux) or fswatch (macOS). Make executable: chmod +x scripts/watch_on_save.sh

set -euo pipefail

PUSH=false
DEBOUNCE=1
WATCH_PATH="."

# parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --push) PUSH=true; shift ;;
    --debounce) DEBOUNCE="${2:-$DEBOUNCE}"; shift 2 ;;
    --path) WATCH_PATH="${2:-.}"; shift 2 ;;
    --help|-h) echo "Usage: $0 [--push] [--debounce SECONDS] [--path PATH]"; exit 0 ;;
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
if [[ ! -x "$script_path" ]]; then
  echo "auto_commit.sh not found or not executable at: $script_path"
  exit 1
fi

# build push flag
if [[ "$PUSH" == "true" ]]; then
  PUSH_FLAG="--push"
else
  PUSH_FLAG=""
fi

# debounce handling
last_trigger=0
debounce_seconds="${DEBOUNCE}"

trigger_commit() {
  now=$(date +%s)
  elapsed=$(( now - last_trigger ))
  if (( elapsed < debounce_seconds )); then
    return 0
  fi
  last_trigger=$now
  # run async so watcher continues; redirect output to log
  bash "$script_path" $PUSH_FLAG >> "$repo_root/.auto_commit.log" 2>&1 &
  echo "Triggered auto-commit at $(date -u +"%Y-%m-%d %H:%M:%SZ")"
}

# choose available watcher
if command -v inotifywait >/dev/null 2>&1; then
  echo "Using inotifywait to watch changes (Linux). Watching: $WATCH_PATH"
  # exclude common dirs; adjust as needed
  EXCLUDE='(\.git|node_modules|\.idea|build|\.dart_tool)'
  inotifywait -m -r -e close_write,modify,move,create,delete --format '%w%f' --exclude "$EXCLUDE" "$WATCH_PATH" |
  while read -r changed; do
    trigger_commit
  done
elif command -v fswatch >/dev/null 2>&1; then
  echo "Using fswatch to watch changes (macOS). Watching: $WATCH_PATH"
  # fswatch emits NUL-separated entries with -0
  fswatch -0 -r --exclude '\.git' "$WATCH_PATH" |
  while IFS= read -r -d '' event; do
    trigger_commit
  done
else
  # Fallback: use Python polling watcher if available
  if command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
    PYCMD="$(command -v python3 || command -v python)"
    echo "Using Python polling fallback to watch changes. Watching: $WATCH_PATH"
    # run an inline python watcher: args -> repo_root, WATCH_PATH, DEBOUNCE, script_path, PUSH_FLAG
    "$PYCMD" - "$repo_root" "$WATCH_PATH" "$debounce_seconds" "$script_path" "$PUSH_FLAG" <<'PYTHON'
import sys, os, time, subprocess

repo_root = sys.argv[1]
watch_path = sys.argv[2] or "."
debounce = int(sys.argv[3] or 1)
script_path = sys.argv[4]
push_flag = sys.argv[5] if len(sys.argv) > 5 else ""

watch_root = os.path.join(repo_root, watch_path) if not os.path.isabs(watch_path) else watch_path
if not os.path.exists(watch_root):
    print("Watch path does not exist:", watch_root)
    sys.exit(1)

IGNORES = {'.git', 'node_modules', '.idea', 'build', '.dart_tool'}

def should_ignore(path):
    parts = set(p for p in path.replace(repo_root, '').split(os.sep) if p)
    return bool(IGNORES & parts)

def snapshot():
    s = {}
    for root, dirs, files in os.walk(watch_root):
        if should_ignore(root):
            # prune ignored dirs so walk is faster
            dirs[:] = [d for d in dirs if d not in IGNORES]
            continue
        for fn in files:
            path = os.path.join(root, fn)
            try:
                st = os.stat(path)
            except OSError:
                continue
            s[path] = (st.st_mtime, st.st_size)
    return s

prev = snapshot()
last_trigger = 0.0

while True:
    time.sleep(1)
    cur = snapshot()
    changed = False
    # new or modified files
    for k, v in cur.items():
        if k not in prev or prev[k] != v:
            changed = True
            break
    # deleted files
    if not changed:
        for k in prev:
            if k not in cur:
                changed = True
                break
    if changed:
        now = time.time()
        if now - last_trigger >= debounce:
            cmd = ['bash', script_path]
            if push_flag == '--push':
                cmd.append('--push')
            try:
                subprocess.Popen(cmd, cwd=repo_root)
                print("Triggered auto-commit at", time.strftime("%Y-%m-%d %H:%M:%SZ", time.gmtime()))
            except Exception as e:
                print("Failed to run auto-commit:", e)
            last_trigger = now
        prev = cur.copy()
PYTHON
  else
    echo "Neither inotifywait nor fswatch nor Python found. Install one to use this watcher."
    exit 2
  fi
fi
