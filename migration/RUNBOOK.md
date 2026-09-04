# Mac-to-Mac migration runbook

Manual, MDM-safe migration (no Migration Assistant, no Time Machine).
Old Mac: `192.168.1.12` (arm64, macOS 26.6.2). New Mac: same user `psharma`, arm64, macOS 26.6.2.

## Order of operations

### 1. NEW Mac — prepare (Phase 1)
Copy `bootstrap-new-mac.sh` to the new Mac (AirDrop or paste) and run it:
```sh
bash bootstrap-new-mac.sh
```
Installs Homebrew, rsync 3.x, Rosetta. Prints the new Mac's **temp IP**.
Enable Remote Login if it reports OFF: System Settings > General > Sharing > Remote Login.

Keep the new Mac on its **temp IP** (NOT `192.168.1.12`) during transfer.

### 2. NEW Mac — create the Work volume
Disk Utility > add an APFS volume to the internal container, named exactly **`Work`**
(mounts at `/Volumes/Work`). Holds 30G of work data + the Obsidian vault
(`/Volumes/Work/Obsidian/Work`). If skipped, the push copies everything else and
tells you to create it and re-run.

### 3. OLD Mac — push
From a plain Terminal (not inside the OpenCode session), run:
```sh
~/dotfiles/migration/migrate-push.sh <new-mac-temp-ip>
```
Live databases (opencode 3.4G, superset, atuin, redisinsight) are snapshotted with
`sqlite3 .backup` for a consistent copy. Idempotent — safe to re-run.

### 4. NEW Mac — restore
```sh
~/dotfiles/migration/restore-new-mac.sh
```
Runs `dotfiles/install.sh` (brew bundle, oh-my-zsh, symlinks, openchamber agent),
fresh Determinate Nix, loads the homelab-publish + cua-driver agents, starts
caddy/ollama. Prints the manual checklist.

### 5. Cutover to `192.168.1.12`
Only after the new Mac is verified:
- Power OFF the old Mac (frees the IP).
- Assign `192.168.1.12` to the new Mac (static, or DHCP reservation to the new MAC).
- Verify caddy, `macbook-arena.homelab` DNS, Twingate.

## What is reproduced, not copied
Homebrew (Brewfile), Determinate Nix, oh-my-zsh/tmux/nvm, apps (`/Applications`),
Docker images, JetBrains config (Settings Sync), browser profiles (sign-in sync),
login keychain (re-auth), ollama/LM Studio models.

## What is copied
Keys/secrets (`.ssh`, `.gnupg`, `.secrets`, `.git-templates`, cloud creds), the
`dotfiles` repo, dev tool config/state (`.config`, `.claude`, `.codex`, `.omo`,
`.superset`, `.opencode`, atuin history, wakatime), dev app state
(OpenChamber, Superset, Obsidian, DBeaver), user data (Documents/Desktop/Downloads/
Pictures), manual binaries (`opscore`, `ocx`), and the `Work` volume.

## Manual after restore
git/opscore verification, TCC grants (Accessibility/Screen Recording — esp. CuaDriver),
app re-auth, node + model reinstalls, Docker image re-pull, IP cutover. Full list
printed by `restore-new-mac.sh`.

## Observed gaps (manual fixes needed — not handled by the scripts)
- kitty: `xterm-kitty` terminfo absent → copy from `kitty.app/Contents/Resources/terminfo` into `~/.terminfo` (else tmux/opencode/kitty TUIs error).
- git-secrets: binary not installed though `.gitconfig` sets its template hooks → `brew install git-secrets` (else `git init` / `brew tap-new` fail).
- OpenChamber: `@openchamber/web` bun global — symlink copied but package payload missing (dangling) → `bun add -g @openchamber/web` (else `:4096` down, caddy 502).
- opencode plugins (oh-my-openagent, dcp): land in stale cache format → rebuild bare-name dirs under `~/.cache/opencode/packages`.
- AWS: SSO tokens invalid on new machine → `aws sso login --sso-session cb`.
- Twingate: connector tokens are cloned onto both Macs → regenerate `bronze-mouse` token + recreate connector; archive old device.
- Login items: Docker Desktop + Tailscale not migrated → re-add.
- Static IP: use `networksetup -setmanual` (not `-setmanualip`); DHCP→manual drops DNS → also set `-setdnsservers`.
- Superset: host id = HMAC(IOPlatformUUID), not transplantable → new Mac registers as its own host; old cloud workspaces orphaned.
- tmux: oh-my-tmux deadlocks a fresh server on tmux 3.7c (unresolved).
- rsync: use Homebrew rsync on BOTH ends for `-aHAXs` (system openrsync rejects `-A`/`-X`).
