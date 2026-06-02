#!/usr/bin/env bash
# Run OUTSIDE tmux. Will kill daily/bifrost-pf/local-server sessions and restore from RECOVERY_BACKUP snapshot.

set -euo pipefail

RESURRECT_DIR="$HOME/.local/share/tmux/resurrect"
BACKUP_FILE="tmux_resurrect_RECOVERY_BACKUP.txt"
SESSION="daily"

if [ ! -f "$RESURRECT_DIR/$BACKUP_FILE" ]; then
    echo "ERROR: recovery snapshot missing at $RESURRECT_DIR/$BACKUP_FILE" >&2
    exit 1
fi

echo "==> Killing stale tmux sessions so resurrect can recreate them..."
for s in daily bifrost-pf local-server; do
    tmux kill-session -t "$s" 2>/dev/null && echo "    killed: $s" || true
done

echo "==> Pointing 'last' symlink to recovery snapshot..."
ln -sf "$BACKUP_FILE" "$RESURRECT_DIR/last"
ls -la "$RESURRECT_DIR/last"

echo "==> Starting fresh daily session..."
tmux new-session -d -s "$SESSION"

echo "==> Waiting for plugins to initialize..."
sleep 2

echo "==> Triggering resurrect restore..."
bash "$HOME/.tmux/plugins/tmux-resurrect/scripts/restore.sh"

echo "==> Sessions after restore:"
tmux list-sessions

echo ""
echo "==> Done. Attach with: tmux attach -t $SESSION"
echo "    Or just run: tdaily"
