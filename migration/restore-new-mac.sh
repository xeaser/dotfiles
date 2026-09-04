#!/usr/bin/env bash
set -euo pipefail

# Run on the NEW Mac AFTER migrate-push.sh completes. Safe to re-run.

eval "$(/opt/homebrew/bin/brew shellenv)"
H="$HOME"

echo "== Fix permissions on keys/secrets =="
chmod 700 "$H/.ssh" "$H/.gnupg" 2>/dev/null || true
chmod 600 "$H/.secrets" 2>/dev/null || true
[ -f "$H/.ssh/id_ed25519" ] && chmod 600 "$H/.ssh/id_ed25519"
find "$H/.ssh" -type f -name '*.pub' -exec chmod 644 {} \; 2>/dev/null || true
[ -f "$H/.ssh/config" ] && chmod 600 "$H/.ssh/config"
find "$H/.gnupg" -type d -exec chmod 700 {} \; 2>/dev/null || true
find "$H/.gnupg" -type f -exec chmod 600 {} \; 2>/dev/null || true

echo "== dotfiles install (brew bundle + omz + symlinks + openchamber agent) =="
if [ -d "$H/dotfiles" ]; then
  ( cd "$H/dotfiles" && ./install.sh )
else
  echo "ERROR: ~/dotfiles missing — run migrate-push.sh from the OLD Mac first."; exit 1
fi

echo "== Determinate Nix (fresh install) =="
if [ ! -d /nix/store ] && [ ! -e /nix/receipt.json ]; then
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
else
  echo "Nix already present, skipping."
fi

echo "== LaunchAgents: link from dotfiles + load (install.sh handles openchamber) =="
mkdir -p "$H/Library/LaunchAgents"
AGENTS=(
  "com.psharma.homelab-publish:$H/dotfiles/homelab-publish/com.psharma.homelab-publish.plist"
  "com.trycua.driver.serve:$H/dotfiles/cua-driver/com.trycua.driver.serve.plist"
)
for entry in "${AGENTS[@]}"; do
  label="${entry%%:*}"; src="${entry#*:}"
  dest="$H/Library/LaunchAgents/$label.plist"
  if [ -f "$src" ]; then
    ln -sfn "$src" "$dest"
    launchctl bootout "gui/$UID/$label" 2>/dev/null || true
    launchctl bootstrap "gui/$UID" "$dest" 2>/dev/null \
      || launchctl load -w "$dest" 2>/dev/null \
      || echo "  could not load $label (load manually later)"
    echo "  linked + loaded $label"
  else
    echo "  MISSING plist in dotfiles: $src"
  fi
done

echo "== caddy config symlink (/opt/homebrew/etc/Caddyfile -> dotfiles) =="
if [ -f "$H/dotfiles/caddy/Caddyfile" ]; then
  ln -sfn "$H/dotfiles/caddy/Caddyfile" /opt/homebrew/etc/Caddyfile \
    && echo "  linked Caddyfile" || echo "  could not link Caddyfile"
fi

echo "== homelab DNS resolver (/etc/resolver/homelab) — needs sudo =="
if [ -f "$H/dotfiles/dns/homelab" ] && [ ! -e /etc/resolver/homelab ]; then
  sudo mkdir -p /etc/resolver \
    && sudo ln -sfn "$H/dotfiles/dns/homelab" /etc/resolver/homelab \
    && echo "  linked /etc/resolver/homelab" \
    || echo "  could not set /etc/resolver/homelab (run manually with sudo)"
else
  echo "  present or source missing — skipping"
fi

echo "== brew services =="
brew services start caddy  2>/dev/null || true
brew services start ollama 2>/dev/null || true

echo "== ~/Work symlink -> /Volumes/Work =="
if [ -d /Volumes/Work ] && [ ! -e "$H/Work" ]; then
  ln -s /Volumes/Work "$H/Work"
  echo "  created ~/Work -> /Volumes/Work"
elif [ -L "$H/Work" ]; then
  echo "  ~/Work already a symlink -> $(readlink "$H/Work")"
else
  echo "  /Volumes/Work missing or ~/Work exists as non-symlink — check manually"
fi

echo "== binaries =="
[ -f "$H/.local/bin/ocx" ] && chmod +x "$H/.local/bin/ocx"
[ -f "$H/bin/opscore" ] && chmod +x "$H/bin/opscore"

echo "== Dock/Finder preferences (imported from OLD Mac snapshot) =="
PREFSRC="$H/migration-prefs"
for dom in com.apple.dock com.apple.finder; do
  pl="$PREFSRC/$dom.plist"
  if [ -f "$pl" ]; then
    defaults import "$dom" "$pl" 2>/dev/null && echo "  imported $dom" || echo "  could not import $dom"
  else
    echo "  $dom.plist not staged — skipping"
  fi
done
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

cat <<'EOF'

=== RESTORE DONE — remaining MANUAL steps ===

1. VERIFY git (auth + signing use the copied SSH key + gh token):
     gh auth status
     git -C ~/dotfiles status
     git -C ~/dotfiles log --show-signature -1
     opscore --version        # git-secrets provider; must run (may need company VPN/auth)

2. GRANT TCC permissions (System Settings > Privacy & Security) — not transferable:
   - Accessibility: AltTab, Rectangle, Maccy, Raycast, BetterDisplay, Mac Mouse Fix,
                    Deskflow, CuaDriver
   - Screen Recording: CuaDriver, zoom, BetterDisplay
   Then reload the driver: launchctl kickstart -k gui/$UID/com.trycua.driver.serve

3. RE-AUTH apps (keychain was NOT copied): 1Password, Slack, Docker Desktop,
   gcloud (gcloud auth login), browsers (sign-in sync).

4. REINSTALL runtimes not copied: node (nvm/brew) then global npm packages;
   ollama models (ollama pull ...); LM Studio models.

5. DOCKER (images/volumes were NOT migrated — re-pull/recreate):
   - Start Docker Desktop, then recreate the Twingate connector:
       ~/dotfiles/twingate/connector-run.sh   # pulls image + runs with ~/.secrets tokens
   - Other containers you ran here: neo4j (codegraph backend), factory-db (postgres:17).
     Re-pull + recreate as needed; their data volumes did not transfer.

6. CUTOVER to 192.168.1.12:
   - Confirm everything above works on the NEW Mac.
   - Power OFF the OLD Mac (frees the IP, avoids conflict).
   - Assign 192.168.1.12 to the NEW Mac (static, or DHCP reservation to the NEW MAC).
   - Verify homelab: caddy running, macbook-arena.homelab resolves, Twingate up.

7. Optional: disable Remote Login on the NEW Mac if you don't need it.
EOF
