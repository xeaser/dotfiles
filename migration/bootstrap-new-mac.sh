#!/usr/bin/env bash
set -euo pipefail

# Run FIRST on the NEW Mac. Prepares it to receive the migration push.
# Safe to re-run.

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing Xcode Command Line Tools — accept the GUI prompt, then re-run this script."
  xcode-select --install || true
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

brew list rsync >/dev/null 2>&1 || brew install rsync

if ! /usr/bin/pgrep oahd >/dev/null 2>&1; then
  echo "Installing Rosetta 2..."
  softwareupdate --install-rosetta --agree-to-license || true
fi

echo
echo "=== Remote Login (SSH) ==="
if systemsetup -getremotelogin 2>/dev/null | grep -qi "On"; then
  echo "Remote Login: ON"
else
  echo "Remote Login is OFF. Enable it:"
  echo "  System Settings > General > Sharing > Remote Login (allow your user)."
fi

echo
echo "=== TEMP IP (give this to migrate-push.sh on the OLD Mac) ==="
ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null \
  || echo "(no IPv4 on en0/en1 — check Wi-Fi/Ethernet)"

echo
echo "Do NOT assign 192.168.1.12 to this Mac until the OLD Mac is powered off."
