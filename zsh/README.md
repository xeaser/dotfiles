# zsh

Oh My Zsh with Powerlevel10k classic prompt, two-line layout with dotted gap filler.

## Theme

Powerlevel10k (`nerdfont-v3`, classic style). Run `p10k configure` to regenerate.

## Plugins

| Plugin | Description |
|--------|-------------|
| **fzf-tab** | Replace zsh completion with fzf-powered interface |
| **zsh-autosuggestions** | Fish-like autosuggestions as you type |
| **fast-syntax-highlighting** | Real-time syntax highlighting in the shell |
| **zsh-autocomplete** | Real-time type-ahead completion |
| **zsh-completions** | Additional completion definitions |
| **zsh-history-substring-search** | Type and search history with up/down arrows |
| **you-should-use** | Reminds you of existing aliases |
| **git** | Git aliases and completion (oh-my-zsh built-in) |

## Integrations

- **direnv** -- per-directory environment variables
- **zoxide** -- smart `cd` replacement (tracks frecency)
- **atuin** -- searchable, syncable shell history
- **fzf-tab** -- fuzzy completion for everything

## Key Aliases

| Alias | Command |
|-------|---------|
| `vim` / `vi` | `nvim` |
| `viz` | Edit `.zshrc` |
| `soz` | Source `.zshrc` |
| `viztmux` | Edit `.tmux.conf.local` |
| `k` | `kubectl` |
| `tidy` | `go mod tidy` |
| `build` | `make build` |
| `tdaily` | `tmux a -t daily` |
| `ssologin` | `aws sso login --sso-session cb` |
