#!/usr/bin/env bash
set -uo pipefail

# Run on the OLD Mac AFTER migrate-push.sh finishes. Read-only.
# Reports what landed on the NEW Mac, snapshot integrity, and key perms.
#
# Usage: ./verify-migration.sh <new-mac-ip>

NEW_MAC_IP="${1:-}"
[ -z "$NEW_MAC_IP" ] && { echo "Usage: $0 <new-mac-ip>"; exit 1; }
R="psharma@$NEW_MAC_IP"
O=(-o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new)
H="/Users/psharma"
ISSUES=0
note(){ printf '  [ISSUE] %s\n' "$*"; ISSUES=$((ISSUES+1)); }
rexec(){ ssh "${O[@]}" "$R" "$1"; }

echo "== presence on NEW Mac =="
PATHS=(
  "$H/.ssh" "$H/.gnupg" "$H/.secrets" "$H/.git-templates"
  "$H/.aws" "$H/.azure" "$H/.kube" "$H/.docker" "$H/.npmrc" "$H/.terraform.d"
  "$H/dotfiles" "$H/.config" "$H/.claude" "$H/.claude.json" "$H/.codex"
  "$H/.omo" "$H/.sisyphus" "$H/.superset" "$H/.opencode"
  "$H/.local/share/opencode" "$H/.local/share/atuin" "$H/.local/bin" "$H/.bun"
  "$H/Library/Application Support/OpenChamber"
  "$H/Library/Application Support/Superset"
  "$H/Library/Application Support/obsidian"
  "$H/Documents" "$H/Desktop" "$H/Downloads" "$H/Pictures"
  "$H/bin" "$H/.local/bin/ocx" "/Volumes/Work"
)
for p in "${PATHS[@]}"; do
  rexec "test -e '$p'" && echo "  ok: $p" || note "missing: $p"
done

echo "== live DB snapshots (exist, integrity, size vs source) =="
DBS=(
  "$H/.local/share/opencode/opencode.db"
  "$H/.superset/local.db"
  "$H/.superset/tanstack-db.sqlite"
  "$H/.local/share/atuin/history.db"
  "$H/.local/share/atuin/records.db"
  "$H/.local/share/atuin/meta.db"
  "$H/.redis-insight/redisinsight.db"
)
for db in "${DBS[@]}"; do
  [ -f "$db" ] || continue
  os=$(stat -f%z "$db" 2>/dev/null || echo 0)
  ns=$(rexec "stat -f%z '$db' 2>/dev/null" || echo 0)
  if [ "${ns:-0}" -le 0 ]; then
    note "db missing/empty on new Mac: $db"
  elif [ "$ns" -lt $((os / 2)) ]; then
    note "db possibly truncated: $db (old ${os}B / new ${ns}B)"
  else
    integ=$(rexec "sqlite3 '$db' 'PRAGMA integrity_check;' 2>/dev/null | head -1")
    if [ "$integ" = "ok" ]; then
      echo "  ok: $db (old ${os}B / new ${ns}B, integrity ok)"
    else
      note "db integrity_check != ok: $db (got: ${integ:-none})"
    fi
  fi
done

echo "== perms on keys/secrets (rsync should have preserved) =="
check_perm(){
  local p="$1" want="$2" m
  m=$(rexec "stat -f '%Lp' '$p' 2>/dev/null")
  [ "$m" = "$want" ] && echo "  ok: $p ($m)" \
    || note "perm $p is ${m:-missing}, expected $want (restore-new-mac.sh will fix)"
}
check_perm "$H/.ssh" 700
check_perm "$H/.secrets" 600
check_perm "$H/.ssh/id_ed25519" 600

echo "== Work volume size (old vs new) =="
ow=$(du -sh /Volumes/Work 2>/dev/null | awk '{print $1}')
nw=$(rexec "du -sh /Volumes/Work 2>/dev/null | awk '{print \$1}'")
echo "  old: ${ow:-?}   new: ${nw:-?}"

echo
if [ "$ISSUES" -eq 0 ]; then
  echo "VERIFY: no issues found."
else
  echo "VERIFY: $ISSUES issue(s) noted above."
fi
