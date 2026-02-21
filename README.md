# dotfiles

macOS development environment managed with symlinks and a single install script.

![screenshot placeholder](screenshot.png)

## Quick Install

```bash
git clone https://github.com/xeaser/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./install.sh
```

## Structure

```
~/dotfiles/
├── zsh/                  # Zsh config + Powerlevel10k prompt
│   ├── .zshrc
│   └── .p10k.zsh
├── tmux/                 # oh-my-tmux config + scripts
│   ├── .tmux.conf.local
│   ├── .gitmux.conf
│   └── scripts/
│       └── spotify.sh
├── nvim/                 # LazyVim-based Neovim config
│   ├── init.lua
│   └── lua/
│       ├── config/
│       └── plugins/
├── kitty/                # Kitty terminal config
│   └── kitty.conf
├── git/                  # Git config
│   └── .gitconfig
├── Brewfile              # Homebrew packages
├── install.sh            # Idempotent setup script
├── .secrets.example      # Template for secrets
└── .gitignore
```

## What's Included

| Tool | Description |
|------|-------------|
| **zsh** | Oh My Zsh + Powerlevel10k with fzf-tab, autosuggestions, fast-syntax-highlighting, atuin, zoxide, direnv |
| **tmux** | oh-my-tmux with gruvbox theme, gitmux status, spotify, session management via sesh |
| **nvim** | LazyVim with gruvbox-material, avante (AI), neotest, DAP, opencode.nvim, project manager |
| **kitty** | Gruvbox dark theme, Nerd Fonts, powerline tabs |
| **brew** | All packages captured in Brewfile |

## Secrets Management

Secrets are never committed. The install script creates `~/.secrets` from `.secrets.example` on first run.

```bash
# After install, edit:
vim ~/.secrets
chmod 600 ~/.secrets
```

Sourced automatically by `.zshrc`.

## Key Shortcuts

### Zsh

| Shortcut | Action |
|----------|--------|
| `vim` / `vi` | Opens Neovim |
| `viz` | Edit .zshrc |
| `soz` | Source .zshrc |
| `k` | kubectl |
| `tdaily` | Attach to tmux "daily" session |

### Tmux (prefix: Ctrl+a)

| Shortcut | Action |
|----------|--------|
| `prefix + T` | sesh session picker (fzf) |
| `prefix + Z` | tmux-fzf launcher |
| `prefix + Space` | tmux-thumbs (copy hints) |
| `F12` | Suspend tmux (nested sessions) |
| `Ctrl+h/j/k/l` | Navigate panes (vim-aware) |

### Neovim (leader: Space)

| Shortcut | Action |
|----------|--------|
| `leader + aa` | Avante AI assistant |
| `leader + gg` | LazyGit |
| `leader + tt` | Run nearest test |
| `leader + td` | Debug nearest test |
| `leader + pp` | Browse projects |
| `leader + oo` | Toggle opencode |
| `Ctrl+h/j/k/l` | Navigate splits (tmux-aware) |
