# Sourced by EVERY zsh: interactive, non-interactive, login, and scripts.
# This is the only startup file a tool that shells out (`zsh -c`, `sh -c`,
# launchd, cron, CI, GUI apps) is guaranteed to read -- .zshrc is interactive-only.
#
# Keep this file cheap and side-effect free: no subprocess forks ($(...)),
# no TTY assumptions, no completions. Anything that costs a fork belongs in
# .zshrc so it runs once per terminal rather than once per shell invocation.

# Deduplicate PATH. `path` is the array view; `PATH` the string view.
# Dedup keeps the LEFTMOST copy, which makes dotfiles_path re-runnable:
# re-prepending an entry promotes it even if a later copy already exists.
typeset -U path PATH

export GOPATH="$HOME/go"
export BUN_INSTALL="$HOME/.bun"
export NVM_DIR="$HOME/.nvm"
export EDITOR='nvim'

# Single source of truth for PATH. Called here for every shell, and again from
# .zprofile because /etc/zprofile runs path_helper after this file and rebuilds
# PATH with /etc/paths entries first, demoting everything prepended below.
dotfiles_path() {
  path+=(
    "$HOME/bin"
    "$HOME/dotfiles/zsh/scripts"
    "$GOPATH/bin"
    "$HOME/.lmstudio/bin"
    "$HOME/.local/bin"
    /opt/homebrew/opt/postgresql/bin
    "$HOME/Library/Python/3.9/bin"
  )

  # Prepends, listed in final precedence order (first entry wins).
  # Homebrew python3 and curl must outrank /usr/bin, which ships 3.9.6 and
  # curl 8.7.1. python@3 needs two dirs: libexec/bin holds the unversioned
  # python/pip, bin holds python3/pip3. The python@3 symlink tracks brew's
  # current python3, so a 3.15 bump needs no edit here. curl is keg-only --
  # brew never creates /opt/homebrew/bin/curl, so it must be named explicitly.
  path=(
    /opt/homebrew/opt/curl/bin
    /opt/homebrew/opt/python@3/libexec/bin
    /opt/homebrew/opt/python@3/bin
    /opt/homebrew/opt/postgresql@18/bin
    "$HOME/.opencode/bin"
    "$BUN_INSTALL/bin"
    "$HOME/.antigravity/antigravity/bin"
    $path
  )

  export PATH
}

dotfiles_path
