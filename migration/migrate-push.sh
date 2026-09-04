#!/usr/bin/env bash
set -euo pipefail

# Run on the OLD Mac. Pushes data to the NEW Mac over rsync + ssh.
# Non-destructive: never uses --delete and never modifies the OLD Mac
# (only creates temp DB snapshots in a temp dir, removed on exit).
#
# Usage: ./migrate-push.sh <new-mac-temp-ip>
# Prereqs on NEW Mac: bootstrap-new-mac.sh has run, Remote Login is ON.

NEW_MAC_IP="${1:-}"
NEW_USER="psharma"
[ -z "$NEW_MAC_IP" ] && { echo "Usage: $0 <new-mac-temp-ip>"; exit 1; }

REMOTE="$NEW_USER@$NEW_MAC_IP"
RSYNC="/opt/homebrew/bin/rsync"
RRPATH="/opt/homebrew/bin/rsync"
SSH_OPTS=(-o StrictHostKeyChecking=accept-new -o ConnectTimeout=10)

STAGING="$(mktemp -d /tmp/mac-migration.XXXXXX)"
caffeinate -dimsu &
CAF=$!
trap 'rm -rf "$STAGING"; kill "$CAF" 2>/dev/null || true' EXIT

FLAGS=(-aHAX --numeric-ids --human-readable --info=progress2
  --exclude='.DS_Store' --exclude='*.log' --exclude='*.bak'
  --exclude='*.migbak' --exclude='*.dedupbak' --exclude='*.tmp'
  --exclude='node_modules' --exclude='.Trash' --exclude='__pycache__'
  --exclude='*.sock' --exclude='*.pid' --exclude='.cache'
  --exclude='*.photoslibrary')
RSH=(-e "ssh ${SSH_OPTS[*]}" --rsync-path="$RRPATH")

command -v "$RSYNC" >/dev/null || { echo "OLD Mac missing brew rsync: brew install rsync"; exit 1; }
command -v sqlite3 >/dev/null || { echo "sqlite3 not found on OLD Mac"; exit 1; }
ssh "${SSH_OPTS[@]}" "$REMOTE" "command -v $RRPATH >/dev/null" \
  || { echo "NEW Mac unreachable or brew rsync missing. Run bootstrap-new-mac.sh there."; exit 1; }

push() {
  local src="$1" dest="$2"; shift 2
  if [ ! -e "$src" ]; then echo "skip (absent): $src"; return; fi
  local rc=0
  if [ -d "$src" ]; then
    ssh "${SSH_OPTS[@]}" "$REMOTE" "mkdir -p \"$dest\""
    "$RSYNC" "${FLAGS[@]}" "${RSH[@]}" "$@" "${src%/}/" "$REMOTE:${dest%/}/" || rc=$?
  else
    ssh "${SSH_OPTS[@]}" "$REMOTE" "mkdir -p \"$(dirname "$dest")\""
    "$RSYNC" "${FLAGS[@]}" "${RSH[@]}" "$@" "$src" "$REMOTE:$dest" || rc=$?
  fi
  if [ "$rc" -eq 0 ]; then return 0; fi
  if [ "$rc" -eq 23 ] || [ "$rc" -eq 24 ]; then
    echo "  WARN: rsync partial (code $rc) for $src — protected xattrs/vanished files skipped; continuing"
    return 0
  fi
  echo "  ERROR: rsync failed (code $rc) for $src"
  return "$rc"
}

backup_db() {
  local db="$1" dest="$2"
  if [ ! -f "$db" ]; then echo "skip db (absent): $db"; return; fi
  local snap="$STAGING/${dest//\//_}"
  echo "snapshot: $db"
  sqlite3 "$db" ".backup '$snap'"
  ssh "${SSH_OPTS[@]}" "$REMOTE" "mkdir -p \"$(dirname "$dest")\""
  "$RSYNC" -aHAX "${RSH[@]}" "$snap" "$REMOTE:$dest"
}

H="/Users/psharma"

echo "== Group A: keys & secrets =="
push "$H/.ssh"           "$H/.ssh" --exclude='authorized_keys' --exclude='authorized_keys.*'
push "$H/.gnupg"         "$H/.gnupg"
push "$H/.secrets"       "$H/.secrets"
push "$H/.git-templates" "$H/.git-templates"
push "$H/.aws"           "$H/.aws"
push "$H/.azure"         "$H/.azure"
push "$H/.kube"          "$H/.kube"
push "$H/.docker"        "$H/.docker"
push "$H/.npmrc"         "$H/.npmrc"
push "$H/.terraform.d"   "$H/.terraform.d"

echo "== Group B: dotfiles repo (resolves git, symlinks, Brewfile) =="
push "$H/dotfiles"       "$H/dotfiles"

echo "== Group C: dev tool config & state =="
push "$H/.config"               "$H/.config"
push "$H/.claude"               "$H/.claude"
push "$H/.claude.json"          "$H/.claude.json"
push "$H/.codex"                "$H/.codex"
push "$H/.omo"                  "$H/.omo"
push "$H/.sisyphus"             "$H/.sisyphus"
push "$H/.omp"                  "$H/.omp"
push "$H/.gemini"               "$H/.gemini"
push "$H/.grok"                 "$H/.grok"
push "$H/.copilot"              "$H/.copilot"
push "$H/.factory"              "$H/.factory"
push "$H/.cursor"               "$H/.cursor"
push "$H/.continue"             "$H/.continue"
push "$H/.aitk"                 "$H/.aitk"
push "$H/.beads"                "$H/.beads"
push "$H/.bun"                  "$H/.bun"
push "$H/.local/bin"            "$H/.local/bin"
push "$H/.local/pipx"           "$H/.local/pipx"
push "$H/.wakatime"             "$H/.wakatime" --exclude='offline_heartbeats.bdb'
push "$H/.dbclient"             "$H/.dbclient"

push "$H/.superset"             "$H/.superset" --exclude='local.db' --exclude='tanstack-db.sqlite'
push "$H/.opencode"             "$H/.opencode"
push "$H/.local/share/opencode" "$H/.local/share/opencode" --exclude='opencode.db*'
push "$H/.local/share/atuin"    "$H/.local/share/atuin" --exclude='*.db' --exclude='*.db-*'
push "$H/.redis-insight"        "$H/.redis-insight" --exclude='redisinsight.db'

echo "== App Support (dev apps) =="
push "$H/Library/Application Support/OpenChamber" "$H/Library/Application Support/OpenChamber"
push "$H/Library/Application Support/Superset"    "$H/Library/Application Support/Superset"
push "$H/Library/Application Support/obsidian"    "$H/Library/Application Support/obsidian"
push "$H/Library/DBeaverData"                     "$H/Library/DBeaverData"
push "$H/.obsidian-headless"                      "$H/.obsidian-headless"

echo "== Live database snapshots (consistent point-in-time) =="
backup_db "$H/.local/share/opencode/opencode.db" "$H/.local/share/opencode/opencode.db"
backup_db "$H/.superset/local.db"                "$H/.superset/local.db"
backup_db "$H/.superset/tanstack-db.sqlite"      "$H/.superset/tanstack-db.sqlite"
backup_db "$H/.local/share/atuin/history.db"     "$H/.local/share/atuin/history.db"
backup_db "$H/.local/share/atuin/records.db"     "$H/.local/share/atuin/records.db"
backup_db "$H/.local/share/atuin/meta.db"        "$H/.local/share/atuin/meta.db"
backup_db "$H/.redis-insight/redisinsight.db"    "$H/.redis-insight/redisinsight.db"

echo "== Group D: user data + binaries =="
push "$H/Documents" "$H/Documents"
push "$H/Desktop"   "$H/Desktop"
push "$H/Downloads" "$H/Downloads"
push "$H/Pictures"  "$H/Pictures"
push "$H/bin"       "$H/bin"
push "/usr/local/bin/ocx" "$H/.local/bin/ocx"

echo "== Group E: Work volume (30G, incl. Obsidian vault) =="
if ssh "${SSH_OPTS[@]}" "$REMOTE" "test -d /Volumes/Work"; then
  push "/Volumes/Work" "/Volumes/Work"
else
  echo "SKIP: /Volumes/Work not mounted on NEW Mac."
  echo "Create an APFS volume named exactly 'Work' (Disk Utility) on the NEW Mac, then re-run:"
  echo "  $0 $NEW_MAC_IP    (idempotent; already-copied groups sync quickly)"
fi

echo
echo "PUSH COMPLETE. Next: run migration/restore-new-mac.sh on the NEW Mac."
