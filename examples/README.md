# Examples

Project-local configuration templates. Copy these into your project root and customize.

## .nvim.lua -- Per-Project Neovim Config

Loaded automatically when nvim opens from the project directory (via `exrc`).

Use it for:
- Project-specific DAP (debug) configurations
- Custom LSP settings per project
- Project-local keybindings

```bash
cp ~/dotfiles/examples/.nvim.lua ~/Work/my-project/.nvim.lua
```

## .envrc -- Per-Project Environment Variables

Used by [direnv](https://direnv.net/) to auto-load/unload environment variables when you `cd` into a project.

Use it for:
- AWS_PROFILE per project
- KUBECONFIG for different clusters
- Go/Node/Python version or env vars
- PATH additions for project-local tools

```bash
cp ~/dotfiles/examples/.envrc ~/Work/my-project/.envrc
cd ~/Work/my-project
direnv allow
```

After `direnv allow`, variables load automatically on `cd` and unload when you leave.

## Notes

- `.nvim.lua` requires `vim.o.exrc = true` in your nvim config (already set in this dotfiles setup)
- `.envrc` requires `direnv` to be installed and hooked into your shell (handled by install.sh)
- Add both to your project's `.gitignore` if they contain machine-specific values
