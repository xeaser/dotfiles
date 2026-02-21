#!/usr/bin/env bash
SESSION="daily"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux attach -t "$SESSION"
    exit 0
fi

tmux new-session -d -s "$SESSION" -n "zsh"
tmux new-window -t "$SESSION" -n "k9s" "k9s"
tmux new-window -t "$SESSION" -n "nvim" "nvim"
tmux new-window -t "$SESSION" -n "jira" "jiratui ui"
tmux new-window -t "$SESSION" -n "homelab" "ssh -i ~/.ssh/id_ed25519 zephyr@192.168.1.222"
tmux new-window -t "$SESSION" -n "opencode" "AWS_PROFILE=cb-bedrock opencode"

tmux select-window -t "$SESSION:1"
tmux attach -t "$SESSION"
