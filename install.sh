#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { printf "${GREEN}[done]${NC} %s\n" "$1"; }
skip()  { printf "${YELLOW}[skip]${NC} %s\n" "$1"; }
error() { printf "${RED}[error]${NC} %s\n" "$1"; }

backup_and_link() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        skip "$dest already linked"
        return
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/$(basename "$dest").$(date +%s)"
        info "Backed up $dest"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    info "Linked $dest -> $src"
}

# -- Pre-flight: macOS check --------------------------------------------------

if [ "$(uname)" != "Darwin" ]; then
    error "This script is intended for macOS only."
    exit 1
fi

# -- Homebrew ------------------------------------------------------------------

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    info "Homebrew installed"
else
    skip "Homebrew already installed"
fi

# -- Brew bundle ---------------------------------------------------------------

if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    info "Installing Homebrew packages from Brewfile..."
    brew bundle install --file="$DOTFILES_DIR/Brewfile" --no-lock
    info "Brew bundle complete"
else
    error "Brewfile not found at $DOTFILES_DIR/Brewfile"
fi

# -- Oh My Zsh -----------------------------------------------------------------

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Cloning oh-my-zsh..."
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    info "oh-my-zsh installed"
else
    skip "oh-my-zsh already installed"
fi

# -- Oh My Zsh custom plugins --------------------------------------------------

declare -A OMZ_PLUGINS=(
    [fzf-tab]="https://github.com/Aloxaf/fzf-tab"
    [you-should-use]="https://github.com/MichaelAquilina/zsh-you-should-use"
    [zsh-completions]="https://github.com/zsh-users/zsh-completions"
    [zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search"
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [fast-syntax-highlighting]="https://github.com/zdharma-continuum/fast-syntax-highlighting"
    [zsh-autocomplete]="https://github.com/marlonrichert/zsh-autocomplete"
)

for plugin in "${!OMZ_PLUGINS[@]}"; do
    dest="$HOME/.oh-my-zsh/custom/plugins/$plugin"
    if [ ! -d "$dest" ]; then
        info "Cloning $plugin..."
        git clone "${OMZ_PLUGINS[$plugin]}" "$dest"
        info "$plugin installed"
    else
        skip "$plugin already installed"
    fi
done

# -- Powerlevel10k theme -------------------------------------------------------

P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    info "Cloning powerlevel10k..."
    git clone https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" --depth=1
    info "powerlevel10k installed"
else
    skip "powerlevel10k already installed"
fi

# -- Oh My Tmux ----------------------------------------------------------------

if [ ! -d "$HOME/.tmux" ]; then
    info "Cloning oh-my-tmux..."
    git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
    info "oh-my-tmux installed"
else
    skip "oh-my-tmux already installed"
fi

if [ ! -L "$HOME/.tmux.conf" ]; then
    ln -sf "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
    info "Linked ~/.tmux.conf -> ~/.tmux/.tmux.conf"
else
    skip "~/.tmux.conf already linked"
fi

# -- Symlinks ------------------------------------------------------------------

backup_and_link "$DOTFILES_DIR/zsh/.zshrc"              "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/zsh/.p10k.zsh"           "$HOME/.p10k.zsh"
backup_and_link "$DOTFILES_DIR/tmux/.tmux.conf.local"   "$HOME/.tmux.conf.local"
backup_and_link "$DOTFILES_DIR/tmux/.gitmux.conf"       "$HOME/.gitmux.conf"

mkdir -p "$HOME/.tmux/scripts"
backup_and_link "$DOTFILES_DIR/tmux/scripts/spotify.sh" "$HOME/.tmux/scripts/spotify.sh"

if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$HOME/.config/nvim" "$BACKUP_DIR/nvim.$(date +%s)"
    info "Backed up existing ~/.config/nvim"
fi
if [ -L "$HOME/.config/nvim" ] && [ "$(readlink "$HOME/.config/nvim")" = "$DOTFILES_DIR/nvim" ]; then
    skip "~/.config/nvim already linked"
else
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    info "Linked ~/.config/nvim -> $DOTFILES_DIR/nvim"
fi

mkdir -p "$HOME/.config/kitty"
backup_and_link "$DOTFILES_DIR/kitty/kitty.conf"        "$HOME/.config/kitty/kitty.conf"

if [ -f "$DOTFILES_DIR/git/.gitconfig" ]; then
    backup_and_link "$DOTFILES_DIR/git/.gitconfig"      "$HOME/.gitconfig"
fi

# -- Secrets -------------------------------------------------------------------

if [ ! -f "$HOME/.secrets" ]; then
    cp "$DOTFILES_DIR/.secrets.example" "$HOME/.secrets"
    chmod 600 "$HOME/.secrets"
    info "Created ~/.secrets from template (fill in your values)"
else
    skip "~/.secrets already exists"
fi

# -- Make scripts executable ---------------------------------------------------

chmod +x "$DOTFILES_DIR/tmux/scripts/spotify.sh"

# -- Done ----------------------------------------------------------------------

printf "\n${GREEN}Installation complete.${NC}\n\n"
printf "Next steps:\n"
printf "  1. Fill in values in ~/.secrets\n"
printf "  2. Run ${YELLOW}p10k configure${NC} to customize your prompt\n"
printf "  3. Restart your terminal or run ${YELLOW}source ~/.zshrc${NC}\n"
