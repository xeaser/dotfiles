# openchamber

LaunchAgent that keeps `openchamber serve` running on this laptop at
`http://127.0.0.1:4096`. Required by the Twingate "Openchamber" resources, the
laptop's Caddy reverse-proxy for `openchamber.homelab`, and the homelab
Caddy's failover entry pointing at this laptop.

## Files

| File | Purpose |
|---|---|
| `start.sh` | Wrapper that sources `~/.secrets`, initialises `nvm`, prepends `~/.opencode/bin` (so the standalone opencode CLI is preferred) plus bun/Homebrew to `PATH`, and execs `openchamber serve`. |
| `com.psharma.openchamber.plist` | LaunchAgent that runs `start.sh` continuously. Symlinked to `~/Library/LaunchAgents/` by `install.sh`. |

## Configuration

`start.sh` runs:

```sh
openchamber serve --foreground --port 4096 --host 127.0.0.1
```

`--foreground` keeps the process in the foreground so launchd owns its
lifecycle (`KeepAlive` restarts it on exit); without it `openchamber` would
daemonise and launchd would immediately restart the exited parent.

The UI password is passed via the exported `OPENCHAMBER_UI_PASSWORD`
environment variable rather than the `--ui-password` flag, so it never appears
in `ps` output. It lives in `~/.secrets` (gitignored); `start.sh` refuses to
start if the file or the variable is missing. The plist itself contains no
secrets.

The service binds `127.0.0.1` only. It is never exposed directly — every
external path reaches it through the laptop's Caddy (see "How it fits"). To
bind all interfaces, prefer `--lan` over hand-writing `--host 0.0.0.0`.

Package install: `@openchamber/web` as a bun global, so the `openchamber` on
`PATH` is `~/.bun/bin/openchamber`. Upgrade with:

```sh
launchctl bootout gui/$UID/com.psharma.openchamber
bun add -g @openchamber/web@latest
launchctl bootstrap gui/$UID ~/Library/LaunchAgents/com.psharma.openchamber.plist
```

Stop the service first — swapping package files under the running process
leaves launchd restarting into a half-replaced `node_modules`. Neither the
plist nor `start.sh` pins a version, so they need no edits across upgrades.

The desktop app (`/Applications/OpenChamber.app`) is a **separate** install
with its own bundled copy. Updating it in-app does not touch this service, and
this service's version is what every path in "How it fits" actually serves.
Also decline the app's `openchamber startup` launch-at-boot management — it
would install a competing agent contending for `:4096`.

## Service management

```sh
launchctl kickstart -k gui/$UID/com.psharma.openchamber          # restart
launchctl bootout   gui/$UID/com.psharma.openchamber             # stop
launchctl bootstrap gui/$UID ~/Library/LaunchAgents/com.psharma.openchamber.plist
launchctl load -w   ~/Library/LaunchAgents/com.psharma.openchamber.plist  # fallback after bootout
```

Logs:

```sh
tail -f /opt/homebrew/var/log/openchamber.log
tail -f /opt/homebrew/var/log/openchamber.err
```

## How it fits

```
Phone (Twingate)
        │
        ├── Mac (Work) connector (bronze-mouse on this laptop)
        │       └── laptop:80 (Caddy) → reverse_proxy 127.0.0.1:4096 (this service)
        │
        └── Lab connector fallback (berserk-mayfly on homelab)
                └── matches *.homelab via the Homelab Services resource
                    → homelab:80 (Caddy) → laptop:80 (Caddy) → 127.0.0.1:4096

Anything on home Wi-Fi (no Twingate)
        │
        └── http://openchamber.homelab
                └── dnsmasq → 192.168.1.222 (homelab) :80
                    └── homelab Caddy (docker caddy:2) → macbook-arena.homelab:80 (→ .2 laptop)
                        └── laptop Caddy → 127.0.0.1:4096
```

All paths terminate here. If this LaunchAgent isn't running they all break
with `502` at the laptop's Caddy.

## Manual / interactive use

The `oc-serve` shell alias in `zsh/.zshrc` runs a similar command in the
foreground for ad-hoc development. Useful when you want to see live logs or
test a different port. Don't run `oc-serve` while the LaunchAgent is also
running — they'll conflict on `:4096`.

It is **not** identical to what the LaunchAgent runs: the alias binds
`--host 0.0.0.0` (all interfaces) and passes `--ui-password` as a flag, where
the service binds loopback only and uses the environment variable. Treat
`oc-serve` as the deliberately more exposed debugging path.

## Related

- `~/.secrets` — `OPENCHAMBER_UI_PASSWORD`
- `caddy/Caddyfile` (laptop side) — reverse-proxies `openchamber.homelab` → `127.0.0.1:4096`
- `homelab/README.md` — homelab Caddy (docker `caddy:2` container; live config at `/home/zephyr/Extra/Misc/homelab/configs/caddy/Caddyfile`, **not** the host `/etc/caddy/Caddyfile`) that proxies `openchamber.homelab` to this laptop via `macbook-arena.homelab`
- `twingate/README.md` — Twingate `Openchamber (Work Mac direct)` resource
