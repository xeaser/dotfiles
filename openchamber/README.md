# openchamber

LaunchAgent that keeps `openchamber serve` running on this laptop at
`http://0.0.0.0:4096`. Required by the Twingate "Openchamber" resources, the
laptop's Caddy reverse-proxy for `openchamber.homelab`, and the homelab
Caddy's failover entry pointing at this laptop.

## Files

| File | Purpose |
|---|---|
| `start.sh` | Wrapper that sources `~/.secrets`, initialises `nvm`, adds bun/Homebrew to `PATH`, and execs `openchamber serve`. |
| `com.psharma.openchamber.plist` | LaunchAgent that runs `start.sh` continuously. Symlinked to `~/Library/LaunchAgents/` by `install.sh`. |

## Configuration

The wrapper runs:

```sh
openchamber serve --port 4096 --host 0.0.0.0 --ui-password "$OPENCHAMBER_UI_PASSWORD"
```

`OPENCHAMBER_UI_PASSWORD` lives in `~/.secrets` (gitignored). The plist itself
contains no secrets.

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
                    └── homelab Caddy → laptop:80 (.18 primary, .6 failover)
                        └── laptop Caddy → 127.0.0.1:4096
```

All paths terminate here. If this LaunchAgent isn't running they all break
with `502` at the laptop's Caddy.

## Manual / interactive use

The `oc-serve` shell alias in `zsh/.zshrc` runs the same command in the
foreground for ad-hoc development. Useful when you want to see live logs or
test a different port. Don't run `oc-serve` while the LaunchAgent is also
running — they'll conflict on `:4096`.

## Related

- `~/.secrets` — `OPENCHAMBER_UI_PASSWORD`
- `caddy/Caddyfile` (laptop side) — reverse-proxies `openchamber.homelab` → `127.0.0.1:4096`
- `homelab/README.md` — homelab Caddy config that fails over between this laptop's interfaces
- `twingate/README.md` — Twingate `Openchamber (Work Mac direct)` resource
