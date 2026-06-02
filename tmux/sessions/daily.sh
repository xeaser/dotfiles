#!/usr/bin/env bash
SESSION="daily"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux attach -t "$SESSION"
    exit 0
fi

# Start server with empty config to avoid oh-my-tmux _apply_configuration
# race condition that crashes/deadlocks tmux on fresh server start.
# Set base-index 1 immediately so window numbering is correct.
# Use send-keys to source config from INSIDE the session (external
# source-file deadlocks). Chain resurrect restore since continuum
# auto-restore can't detect fresh start with this workaround.
tmux -f /dev/null new-session -d -s "$SESSION"
tmux set-option -g base-index 1
tmux set-option -g pane-base-index 1
tmux move-window -s "$SESSION:0" -t "$SESSION:1" 2>/dev/null
tmux send-keys -t "$SESSION" "tmux source-file ~/.tmux.conf 2>/dev/null && clear" Enter
sleep 3
# Trigger resurrect restore via keybinding (prefix + Ctrl-r)
tmux send-keys -t "$SESSION" C-a C-r
sleep 2
tmux attach -t "$SESSION"
