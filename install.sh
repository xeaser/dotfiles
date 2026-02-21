#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false

# -- Parse arguments -----------------------------------------------------------

for arg in "$@"; do
    case "$arg" in
        --dry-run|--check) DRY_RUN=true ;;
        --help|-h)
            printf "Usage: ./install.sh [--dry-run]\n"
            printf "  --dry-run, --check   Show what would be installed/linked without making changes\n"
            exit 0
            ;;
        *) printf "Unknown argument: %s\n" "$arg"; exit 1 ;;
    esac
done

# -- Colors and output ---------------------------------------------------------

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

INSTALLED=0
MISSING=0
MISLINKED=0

ok()       { printf "${GREEN}  [installed]${NC}  %s\n" "$1"; ((INSTALLED++)) || true; }
missing()  { printf "${RED}  [missing]${NC}    %s\n" "$1"; ((MISSING++)) || true; }
needlink() { printf "${BLUE}  [needs link]${NC} %s -> %s\n" "$1" "$2"; ((MISLINKED++)) || true; }
wronglink(){ printf "${YELLOW}  [wrong link]${NC} %s\n  ${YELLOW}current:${NC}  %s\n  ${YELLOW}expected:${NC} %s\n" "$1" "$2" "$3"; ((MISLINKED++)) || true; }
info()     { printf "${GREEN}[done]${NC} %s\n" "$1"; }
skip()     { printf "${YELLOW}[skip]${NC} %s\n" "$1"; }
error()    { printf "${RED}[error]${NC} %s\n" "$1"; }
section()  { printf "\n${CYAN}--- %s ---${NC}\n" "$1"; }

# -- Symlink helper ------------------------------------------------------------

check_link() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        ok "$dest"
    elif [ -L "$dest" ]; then
        wronglink "$dest" "$(readlink "$dest")" "$src"
    elif [ -e "$dest" ]; then
        needlink "$dest (exists, not a symlink)" "$src"
    else
        needlink "$dest (does not exist)" "$src"
    fi
}

backup_and_link() {
    local src="$1"
    local dest="$2"

    if $DRY_RUN; then
        check_link "$src" "$dest"
        return
    fi

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

# -- Pre-flight: macOS check ---------------------------------------------------

if [ "$(uname)" != "Darwin" ]; then
    error "This script is intended for macOS only."
    exit 1
fi

if $DRY_RUN; then
    printf "\n${CYAN}=== Dotfiles Dry Run ===${NC}\n"
    printf "Checking what needs to be installed/linked...\n"
fi

# -- Homebrew ------------------------------------------------------------------

section "Homebrew"

if ! command -v brew &>/dev/null; then
    if $DRY_RUN; then
        missing "Homebrew"
    else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        info "Homebrew installed"
    fi
else
    if $DRY_RUN; then
        ok "Homebrew ($(brew --version | head -1))"
    else
        skip "Homebrew already installed"
    fi
fi

# -- Brew bundle ---------------------------------------------------------------

section "Brew Packages"

if $DRY_RUN; then
    if [ -f "$DOTFILES_DIR/Brewfile" ]; then
        pkg_count=$(grep -c "^[bt][ar][pe]w" "$DOTFILES_DIR/Brewfile" 2>/dev/null || echo "?")
        ok "Brewfile found ($pkg_count packages)"
        brew_missing=$(timeout 15 brew bundle check --file="$DOTFILES_DIR/Brewfile" 2>&1 || true)
        if echo "$brew_missing" | grep -q "satisfied"; then
            ok "All Brewfile packages installed"
        elif echo "$brew_missing" | grep -q "needs to be installed"; then
            echo "$brew_missing" | grep "needs to be installed" | while read -r line; do
                missing "$line"
            done
        else
            printf "${YELLOW}  [slow]${NC}       brew bundle check timed out (run manually: brew bundle check --file=Brewfile)\n"
        fi
    else
        missing "Brewfile not found"
    fi
else
    if [ -f "$DOTFILES_DIR/Brewfile" ]; then
        info "Installing Homebrew packages from Brewfile..."
        brew bundle install --file="$DOTFILES_DIR/Brewfile"
        info "Brew bundle complete"
    else
        error "Brewfile not found at $DOTFILES_DIR/Brewfile"
    fi
fi

# -- Oh My Zsh -----------------------------------------------------------------

section "Oh My Zsh"

if [ -d "$HOME/.oh-my-zsh" ]; then
    if $DRY_RUN; then ok "oh-my-zsh"; else skip "oh-my-zsh already installed"; fi
else
    if $DRY_RUN; then
        missing "oh-my-zsh"
    else
        info "Cloning oh-my-zsh..."
        git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
        info "oh-my-zsh installed"
    fi
fi

# -- Oh My Zsh custom plugins --------------------------------------------------

section "ZSH Plugins"

OMZ_PLUGIN_NAMES=(fzf-tab you-should-use zsh-completions zsh-history-substring-search zsh-autosuggestions fast-syntax-highlighting zsh-autocomplete)
OMZ_PLUGIN_URLS=(
    "https://github.com/Aloxaf/fzf-tab"
    "https://github.com/MichaelAquilina/zsh-you-should-use"
    "https://github.com/zsh-users/zsh-completions"
    "https://github.com/zsh-users/zsh-history-substring-search"
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zdharma-continuum/fast-syntax-highlighting"
    "https://github.com/marlonrichert/zsh-autocomplete"
)

for i in "${!OMZ_PLUGIN_NAMES[@]}"; do
    plugin="${OMZ_PLUGIN_NAMES[$i]}"
    url="${OMZ_PLUGIN_URLS[$i]}"
    dest="$HOME/.oh-my-zsh/custom/plugins/$plugin"
    if [ -d "$dest" ]; then
        if $DRY_RUN; then ok "$plugin"; else skip "$plugin already installed"; fi
    else
        if $DRY_RUN; then
            missing "$plugin"
        else
            info "Cloning $plugin..."
            git clone "$url" "$dest"
            info "$plugin installed"
        fi
    fi
done

# -- Powerlevel10k theme -------------------------------------------------------

section "Powerlevel10k"

P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
    if $DRY_RUN; then ok "powerlevel10k"; else skip "powerlevel10k already installed"; fi
else
    if $DRY_RUN; then
        missing "powerlevel10k"
    else
        info "Cloning powerlevel10k..."
        git clone https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" --depth=1
        info "powerlevel10k installed"
    fi
fi

# -- Oh My Tmux ----------------------------------------------------------------

section "Oh My Tmux"

if [ -d "$HOME/.tmux" ]; then
    if $DRY_RUN; then ok "oh-my-tmux"; else skip "oh-my-tmux already installed"; fi
else
    if $DRY_RUN; then
        missing "oh-my-tmux"
    else
        info "Cloning oh-my-tmux..."
        git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
        info "oh-my-tmux installed"
    fi
fi

if [ -L "$HOME/.tmux.conf" ]; then
    if $DRY_RUN; then ok "~/.tmux.conf symlink"; else skip "~/.tmux.conf already linked"; fi
else
    if $DRY_RUN; then
        needlink "~/.tmux.conf" "~/.tmux/.tmux.conf"
    else
        ln -sf "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
        info "Linked ~/.tmux.conf -> ~/.tmux/.tmux.conf"
    fi
fi

# -- Symlinks ------------------------------------------------------------------

section "Symlinks"

backup_and_link "$DOTFILES_DIR/zsh/.zshrc"              "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/zsh/.p10k.zsh"           "$HOME/.p10k.zsh"
backup_and_link "$DOTFILES_DIR/tmux/.tmux.conf.local"   "$HOME/.tmux.conf.local"
backup_and_link "$DOTFILES_DIR/tmux/.gitmux.conf"       "$HOME/.gitmux.conf"

mkdir -p "$HOME/.tmux/scripts" 2>/dev/null || true
backup_and_link "$DOTFILES_DIR/tmux/scripts/spotify.sh" "$HOME/.tmux/scripts/spotify.sh"

if $DRY_RUN; then
    local_nvim="$HOME/.config/nvim"
    if [ -L "$local_nvim" ] && [ "$(readlink "$local_nvim")" = "$DOTFILES_DIR/nvim" ]; then
        ok "$local_nvim"
    elif [ -L "$local_nvim" ]; then
        wronglink "$local_nvim" "$(readlink "$local_nvim")" "$DOTFILES_DIR/nvim"
    elif [ -d "$local_nvim" ]; then
        needlink "$local_nvim (directory, needs backup + link)" "$DOTFILES_DIR/nvim"
    else
        needlink "$local_nvim" "$DOTFILES_DIR/nvim"
    fi
else
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
fi

mkdir -p "$HOME/.config/kitty" 2>/dev/null || true
backup_and_link "$DOTFILES_DIR/kitty/kitty.conf"        "$HOME/.config/kitty/kitty.conf"

if [ -f "$DOTFILES_DIR/git/.gitconfig" ]; then
    backup_and_link "$DOTFILES_DIR/git/.gitconfig"      "$HOME/.gitconfig"
fi

# k9s (individual config files, not clusters/)
mkdir -p "$HOME/.config/k9s" 2>/dev/null || true
backup_and_link "$DOTFILES_DIR/k9s/config.yaml"         "$HOME/.config/k9s/config.yaml"
backup_and_link "$DOTFILES_DIR/k9s/aliases.yaml"         "$HOME/.config/k9s/aliases.yaml"
backup_and_link "$DOTFILES_DIR/k9s/views.yaml"           "$HOME/.config/k9s/views.yaml"

# opencode (individual files and directories, not plugin/mcp)
mkdir -p "$HOME/.config/opencode" 2>/dev/null || true
backup_and_link "$DOTFILES_DIR/opencode/opencode.jsonc"      "$HOME/.config/opencode/opencode.jsonc"
backup_and_link "$DOTFILES_DIR/opencode/ocx.jsonc"           "$HOME/.config/opencode/ocx.jsonc"
backup_and_link "$DOTFILES_DIR/opencode/oh-my-opencode.json" "$HOME/.config/opencode/oh-my-opencode.json"
backup_and_link "$DOTFILES_DIR/opencode/dcp.jsonc"           "$HOME/.config/opencode/dcp.jsonc"
backup_and_link "$DOTFILES_DIR/opencode/package.json"        "$HOME/.config/opencode/package.json"

mkdir -p "$HOME/.config/opencode/commands" 2>/dev/null || true
backup_and_link "$DOTFILES_DIR/opencode/commands/ci.md"      "$HOME/.config/opencode/commands/ci.md"
backup_and_link "$DOTFILES_DIR/opencode/commands/pr.md"      "$HOME/.config/opencode/commands/pr.md"

mkdir -p "$HOME/.config/opencode/skills/aws-sso-reauth" 2>/dev/null || true
mkdir -p "$HOME/.config/opencode/skills/ci-status" 2>/dev/null || true
mkdir -p "$HOME/.config/opencode/skills/pr-status" 2>/dev/null || true
backup_and_link "$DOTFILES_DIR/opencode/skills/aws-sso-reauth/SKILL.md" "$HOME/.config/opencode/skills/aws-sso-reauth/SKILL.md"
backup_and_link "$DOTFILES_DIR/opencode/skills/ci-status/SKILL.md"      "$HOME/.config/opencode/skills/ci-status/SKILL.md"
backup_and_link "$DOTFILES_DIR/opencode/skills/pr-status/SKILL.md"      "$HOME/.config/opencode/skills/pr-status/SKILL.md"

mkdir -p "$HOME/.config/opencode/profiles/default" 2>/dev/null || true
backup_and_link "$DOTFILES_DIR/opencode/profiles/default/AGENTS.md"       "$HOME/.config/opencode/profiles/default/AGENTS.md"
backup_and_link "$DOTFILES_DIR/opencode/profiles/default/ocx.jsonc"       "$HOME/.config/opencode/profiles/default/ocx.jsonc"
backup_and_link "$DOTFILES_DIR/opencode/profiles/default/opencode.jsonc"  "$HOME/.config/opencode/profiles/default/opencode.jsonc"

# -- Secrets -------------------------------------------------------------------

section "Secrets"

if [ -f "$HOME/.secrets" ]; then
    if $DRY_RUN; then ok "~/.secrets"; else skip "~/.secrets already exists"; fi
else
    if $DRY_RUN; then
        missing "~/.secrets (will create from template)"
    else
        cp "$DOTFILES_DIR/.secrets.example" "$HOME/.secrets"
        chmod 600 "$HOME/.secrets"
        info "Created ~/.secrets from template (fill in your values)"
    fi
fi

# -- CLI tools -----------------------------------------------------------------

section "CLI Tools"

cli_tools=(brew git nvim tmux kitty fzf zoxide atuin direnv sesh gitmux lazygit)

for tool in "${cli_tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
        if $DRY_RUN; then ok "$tool ($(command -v "$tool"))"; fi
    else
        if $DRY_RUN; then missing "$tool (install via Brewfile)"; fi
    fi
done

# -- Make scripts executable ---------------------------------------------------

chmod +x "$DOTFILES_DIR/tmux/scripts/spotify.sh" 2>/dev/null || true

# -- Summary -------------------------------------------------------------------

if $DRY_RUN; then
    printf "\n${CYAN}=== Summary ===${NC}\n"
    printf "${GREEN}  Installed/Linked:${NC}  %d\n" "$INSTALLED"
    printf "${RED}  Missing:${NC}           %d\n" "$MISSING"
    printf "${BLUE}  Needs linking:${NC}     %d\n" "$MISLINKED"

    TOTAL=$((MISSING + MISLINKED))
    if [ "$TOTAL" -eq 0 ]; then
        printf "\n${GREEN}Everything is up to date.${NC}\n"
    else
        printf "\n${YELLOW}Run ./install.sh to install/link %d items.${NC}\n" "$TOTAL"
    fi
else
    printf "\n${GREEN}Installation complete.${NC}\n\n"
    printf "Next steps:\n"
    printf "  1. Fill in values in ~/.secrets\n"
    printf "  2. Run ${YELLOW}p10k configure${NC} to customize your prompt\n"
    printf "  3. Restart your terminal or run ${YELLOW}source ~/.zshrc${NC}\n"
fi
