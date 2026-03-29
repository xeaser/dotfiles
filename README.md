# dotfiles

Development environment managed with symlinks and a single install script. Primarily macOS, with Linux support (see below).

![Terminal setup - kitty + tmux + nvim](screenshot.png)

## Quick Install

```bash
git clone https://github.com/xeaser/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./install.sh
```

## Structure

```
~/dotfiles/
├── zsh/                  # Zsh + Powerlevel10k, plugins, custom scripts
├── tmux/                 # oh-my-tmux config, gitmux, spotify status
├── nvim/                 # LazyVim config, plugins, cheatsheet
├── kitty/                # Kitty terminal theme + settings
├── git/                  # .gitconfig, .gitignore_global
├── k9s/                  # Kubernetes UI: aliases, views, cluster templates
├── opencode/             # AI assistant: config, skills, commands, profiles
├── caddy/                # Caddyfile reverse proxy
├── dns/                  # Homelab DNS config
├── finicky/              # macOS browser routing rules
├── codegraphcontext/     # Code graph MCP server
├── .superset/            # AI orchestration config
├── examples/             # Project-local config templates (.nvim.lua, .envrc)
├── Brewfile              # Homebrew packages
├── install.sh            # Idempotent setup script
├── .secrets.example      # Template for secrets
└── .gitignore
```

## Dry Run

Check what needs to be installed or linked without making any changes:

```bash
./install.sh --dry-run
```

Shows a color-coded report: green = installed, red = missing, blue = needs linking, yellow = wrong symlink target. Includes a summary count at the end.

## What's Included

| Tool | Description |
|------|-------------|
| **zsh** | Oh My Zsh + Powerlevel10k with fzf-tab, autosuggestions, fast-syntax-highlighting, atuin, zoxide, direnv |
| **tmux** | oh-my-tmux with gruvbox theme, gitmux status, spotify, session management via sesh |
| **nvim** | LazyVim with 21 extras: gruvbox-material theme, NeoTree, DAP debugging, neotest, illuminate, aerial, navic, indent-blankline, avante (AI), opencode.nvim, project manager. See [cheatsheet](nvim/cheatsheet.md) |
| **kitty** | Gruvbox dark theme, Nerd Fonts, powerline tabs |
| **k9s** | Kubernetes terminal UI with custom aliases (dp, sec, jo), pod column layouts with image versions and resource usage |
| **opencode** | AI coding assistant with oh-my-opencode model routing, MCP servers (postgres, GitHub, Atlassian, JetBrains, Obsidian), custom skills (AWS SSO, CI status, PR status, code review), slash commands |
| **caddy** | Reverse proxy config (Caddyfile) for local/homelab services |
| **dns** | Homelab DNS configuration |
| **finicky** | macOS browser routing rules (finicky.ts) |
| **codegraphcontext** | Code graph MCP server for codebase analysis |
| **.superset** | AI orchestration config (setup/teardown/run hooks) |
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
| `leader + ph` | Project history |
| `leader + oo` | Toggle opencode |
| `leader + z` | Project debug configs (per-project .nvim.lua) |
| `leader + db` | Toggle breakpoint |
| `leader + dc` | Start/continue debugging |
| `leader + e` | Toggle NeoTree file explorer |
| `leader + cs` | Toggle aerial symbols sidebar |
| `leader + rs` | Refactoring picker |
| `leader + uC` | Colorscheme picker |
| `Ctrl+h/j/k/l` | Navigate splits (tmux-aware) |

> Full keybinding reference: [nvim/cheatsheet.md](nvim/cheatsheet.md)

## Linux Support

The setup is primarily macOS but works on Linux with `--skip-brew`:

```bash
./install.sh --skip-brew
```

This skips Homebrew and installs all symlinks, clones oh-my-zsh, plugins, oh-my-tmux, and powerlevel10k.

**Install packages manually on Linux** using your distro's package manager before running the script:

```bash
# Debian/Ubuntu
sudo apt install zsh tmux neovim fzf kitty git curl

# Arch
sudo pacman -S zsh tmux neovim fzf kitty git curl
```

Then install tools not in distro repos (zoxide, atuin, sesh, gitmux, lazygit, direnv) via their official install instructions or Homebrew for Linux.

**macOS-only features** (skipped automatically on Linux):
- `toggleNotch`, `volUp` aliases (osascript)
- Spotify status in tmux (requires osascript)
- `macos_option_as_alt` in kitty
- Homebrew casks (GUI apps)
