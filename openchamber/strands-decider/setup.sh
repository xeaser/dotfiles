#!/bin/zsh
# Idempotent setup for the local OpenChamber classifier. See README.md.
set -euo pipefail

HERE="${0:A:h}"
STRANDS_HOME="${STRANDS_HOME:-/Volumes/Work/Model/strands}"
LABEL="dev.openchamber.strands-decider-classifier"
PLIST_SRC="$HERE/$LABEL.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/$LABEL.plist"

[ -d "$(dirname "$STRANDS_HOME")" ] || { echo "Volume for $STRANDS_HOME is not mounted" >&2; exit 1; }
mkdir -p "$STRANDS_HOME"

[ -d "$STRANDS_HOME/repo" ] || git clone -q https://github.com/strands-labs/strands-decider.git "$STRANDS_HOME/repo"
[ -d "$STRANDS_HOME/.venv" ] || uv venv --python 3.12 "$STRANDS_HOME/.venv"
VIRTUAL_ENV="$STRANDS_HOME/.venv" uv pip install -q -e "$STRANDS_HOME/repo[mlx]"

# Download the model into the volume (first run needs network). Importing builds the engine.
HF_HOME="$STRANDS_HOME/hf" STRANDS_HOME="$STRANDS_HOME" PYTHONPATH="$HERE" \
    "$STRANDS_HOME/.venv/bin/python" -c "import serve_logged"

chmod +x "$HERE/run-strands"
mkdir -p "$HOME/Library/LaunchAgents"
ln -sfn "$PLIST_SRC" "$PLIST_DEST"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_DEST"
echo "Loaded $LABEL"
