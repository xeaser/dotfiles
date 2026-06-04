#!/usr/bin/env zsh
# openchamber LaunchAgent wrapper.
# Invoked by ~/Library/LaunchAgents/com.psharma.openchamber.plist
#
# Why a wrapper instead of running openchamber directly:
#   1. LaunchAgents start with a sparse PATH; node (via nvm) and bun are not visible.
#   2. ~/.secrets is not sourced by launchd; we need to source it for OPENCHAMBER_UI_PASSWORD.
#
# Logs:
#   /opt/homebrew/var/log/openchamber.log   (stdout)
#   /opt/homebrew/var/log/openchamber.err   (stderr)

set -eu

# Initialize nvm so `node` is on PATH (openchamber's cli.js shebang is #!/usr/bin/env node)
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck disable=SC1091
    \. "$NVM_DIR/nvm.sh"
fi

# Add bun (where the openchamber binary symlink lives) and Homebrew bin
export PATH="$HOME/.bun/bin:/opt/homebrew/bin:$PATH"

# Source secrets for OPENCHAMBER_UI_PASSWORD
if [ -f "$HOME/.secrets" ]; then
    # shellcheck disable=SC1091
    source "$HOME/.secrets"
else
    echo "openchamber: ~/.secrets not found — refusing to start without UI password" >&2
    exit 1
fi

if [ -z "${OPENCHAMBER_UI_PASSWORD:-}" ]; then
    echo "openchamber: OPENCHAMBER_UI_PASSWORD not set in ~/.secrets" >&2
    exit 1
fi

if ! command -v openchamber >/dev/null 2>&1; then
    echo "openchamber: binary not found on PATH after init (PATH=$PATH)" >&2
    exit 1
fi

export OPENCHAMBER_UI_PASSWORD

exec openchamber serve \
    --foreground \
    --port 4096 \
    --host 127.0.0.1
