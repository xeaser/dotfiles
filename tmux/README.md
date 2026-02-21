# tmux

Based on [oh-my-tmux](https://github.com/gpakosz/.tmux) with gruvbox dark theme applied natively via colour variables.

## Theme

Gruvbox dark256 colors set directly in `.tmux.conf.local` colour slots (1-17). No separate theme plugin needed.

## Status Bar

- **Left:** Session name, uptime
- **Right:** Spotify (now playing), gitmux (branch + status), battery, time, user@host

### gitmux

Git branch and status displayed via [gitmux](https://github.com/arl/gitmux) with gruvbox-styled colors. Config in `.gitmux.conf`.

### Spotify

Custom script (`scripts/spotify.sh`) shows currently playing track via AppleScript.

## Plugins (TPM)

| Plugin | Description |
|--------|-------------|
| **tmux-resurrect** | Persist sessions across tmux restarts |
| **tmux-continuum** | Auto-save and auto-restore sessions |
| **tmux-autoreload** | Auto-reload config on changes |
| **tmux-nerd-font-window-name** | Nerd Font icons for window names |
| **tmux-spotify** | Spotify controls |
| **tmux-network-bandwidth** | Network bandwidth monitor |
| **vim-tmux-navigator** | Seamless Ctrl+h/j/k/l navigation between vim and tmux |
| **tmux-fzf** | Fuzzy finder for sessions, windows, panes |
| **extrakto** | Fuzzy text selection from tmux buffer |
| **tmux-thumbs** | Copy hints (like vimium) |
| **tmux-suspend** | Suspend outer tmux for nested sessions |
| **tmux-cpu** | CPU usage monitor |

## Key Shortcuts

Prefix is `Ctrl+a` (rebound from default `Ctrl+b`).

| Shortcut | Action |
|----------|--------|
| `prefix + T` | sesh session picker via fzf |
| `prefix + Z` | tmux-fzf launcher |
| `prefix + Space` | tmux-thumbs copy hints |
| `prefix + s` | Spotify controls |
| `F12` | Suspend outer tmux (for nested sessions) |
| `prefix + I` | Install TPM plugins |
| `prefix + u` | Update TPM plugins |
| `Ctrl+h/j/k/l` | Navigate panes (vim-tmux-navigator) |
| `tdaily` | Launch/attach daily session (alias) |

## Sessions

Session layout scripts live in `sessions/`. These recreate named tmux sessions with predefined windows and commands.

### daily

Six-window dev session: general shell, k9s, nvim, jira, homelab SSH, opencode.

```bash
./sessions/daily.sh    # Creates and attaches (or attaches if exists)
```

The `tdaily` alias in `.zshrc` points to this script. Add more session scripts as needed following the same pattern.
