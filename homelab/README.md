# Homelab

Reference for the homelab box (`192.168.1.222`, hostname `homelab`) - where its
configs live, what's running, and where it overlaps with this work laptop.

This folder is **documentation only**. The actual configs live on the homelab
box at `/home/zephyr/Extra/Misc/homelab/` and are not synced into dotfiles.

## Box

| Field | Value |
|---|---|
| Hostname | `homelab` (SSH alias in `~/.ssh/config`) |
| IP | `192.168.1.222` (static) |
| OS | Debian Linux |
| User | `zephyr` |
| SSH key | `~/.ssh/id_ed25519` |
| Project root | `/home/zephyr/Extra/Misc/homelab/` |

The SSH alias is also wrapped by `alias homelab='ssh homelab'` in `zsh/.zshrc`.

## Project layout on the box

```
/home/zephyr/Extra/Misc/homelab/
  docker-compose.yml         # main compose file
  configs/
    caddy/Caddyfile          # bind-mounted into the caddy:2 container
    bifrost/                 # bifrost data dir (mounted)
    homeassistant/           # HA configs (mounted)
    openwebui/               # openwebui state (mounted)
    homepage/, homarr/       # commented-out services
  scripts/                   # rollback.sh, verify.sh
  backups/                   # rollback.sh + dated backups
```

## Services

Running via Docker Compose (`docker-compose.yml`):

| Container | Image | Listens / Ports | Notes |
|---|---|---|---|
| `caddy` | `caddy:2` | host net, `:80` | Reverse proxy for all `*.homelab` services. Bind-mounts `configs/caddy/Caddyfile` |
| `bifrost` | `maximhq/bifrost` | `5123` | LLM gateway |
| `openwebui` | `ghcr.io/open-webui/open-webui:main` | host net, `:9090` | OpenWebUI |
| `homeassistant` | `ghcr.io/home-assistant/home-assistant:stable` | host net, `:8123` | HA |
| `flaresolverr` | `ghcr.io/flaresolverr/flaresolverr:latest` | `8191` | Cloudflare bypass |
| `recommendarr` | `tannermiddleton/recommendarr:latest` | `3000` | Media recommendations |
| `speedtest-tracker` | `lscr.io/linuxserver/speedtest-tracker` | `9091`, `9443` | |
| `jellyseerr` | `fallenbagel/jellyseerr:latest` | `5051` | Plex requests |
| `glance` | `glanceapp/glance` | host net, `:8085` | Dashboard |
| `litellm` | `ghcr.io/berriai/litellm:main-stable` | `4000` | |
| `litellm_db` | `postgres:16` | `5432` | |
| `prometheus` | `prom/prometheus` | `9099` | |
| `portainer` | `portainer/portainer-ce:latest` | `9000`, `9553` | |
| `portainer_agent` | `portainer/agent:2.33.1` | `9001` | |

Plus `twingate-connector` (the `berserk-mayfly` connector for the `Lab` Twingate
remote network) - run separately from the compose file. See [Twingate](#twingate).

## Twingate

The homelab participates in the `zephyr` Twingate network via two connectors —
one *on* the homelab, one *on the laptop* — that together expose homelab
services and the laptop's openchamber to authenticated clients (phone via the
Android Twingate app, laptop via the desktop client).

### Connectors

| Connector | Remote network | Where it runs | Egress |
|---|---|---|---|
| `berserk-mayfly` | `Lab` | This homelab box (standalone, not in docker-compose) | LAN — directly reaches `192.168.1.222` and any `*.homelab` |
| `bronze-mouse` | `Mac (Work)` | Laptop (Docker container `twingate-connector`) | Corporate Tailnet egress on the laptop (CloudBees IP-allowlisted) |

The `Mac (Work)` connector is what makes phone access to GitHub-org repos work
without the phone joining a corporate VPN — see `../twingate/README.md` for the
GitHub resources side. From the homelab's perspective, that connector is a
peer that reaches the laptop directly via `host-gateway`.

### Resources served from the homelab side

These all run through `berserk-mayfly`:

| Resource | Address | What it serves |
|---|---|---|
| `Homelab` | `192.168.1.222` (all TCP+UDP) | Direct LAN access to the box (SSH, web UIs, anything) |
| `Homelab Services` | `*.homelab:80` (DNS wildcard) | Any `*.homelab` name → homelab Caddy reverse-proxy chain |
| `Access` | `192.168.1.222:32400` | Plex private link |

The `Homelab Services` wildcard is what makes the off-LAN fallback for
`openchamber.homelab` work without any per-service Twingate config: the
phone resolves via Twingate DNS → wildcard match → connector forwards to
homelab → homelab Caddy → laptop's openchamber.

### Resources served from the laptop side

For completeness, the laptop's `bronze-mouse` connector also exposes:
`Openchamber (Work Mac direct)` (DNS `openchamber.homelab:80`, served via
`--add-host=openchamber.homelab:host-gateway` on the connector container) and
all the GitHub-org resources. None of these go through the homelab.

### Access control

All of the above are gated to the `Admin` Twingate group:
`sharmarag93@gmail.com` (ADMIN role), `ptayal718@gmail.com` (MEMBER role).
The phone signs in with the first identity.

Full Twingate inventory (resource IDs, GraphQL admin examples, connector
start/stop commands) lives in `../twingate/README.md`. This section is the
homelab-eye view only.

## Caddy

Caddyfile path on the box:

```
/home/zephyr/Extra/Misc/homelab/configs/caddy/Caddyfile
```

Mounted into the container as `/etc/caddy/Caddyfile:ro`. The `caddy:2` container
runs in `network_mode: host`, so it binds `:80` directly on the homelab box.
There is also a system-installed `caddy` package present but its `caddy.service`
is `disabled` - the Docker container is the one actually serving traffic.

> **Agents/humans:** the live config is the docker-mounted file above
> (`/home/zephyr/Extra/Misc/homelab/configs/caddy/Caddyfile`). Do **not** read or
> edit the host `/etc/caddy/Caddyfile` — that belongs to the disabled stock
> `caddy` package and is *not* what serves traffic. Validate/reload via the
> container: `docker exec caddy caddy validate --config /etc/caddy/Caddyfile
> --adapter caddyfile && docker restart caddy`.

The Caddyfile reverse-proxies `*.homelab` subdomains to local services (most are
`127.0.0.1:<port>` since the box runs all of them). The interesting one is the
`openchamber.homelab` block, which proxies to *this laptop*:

```
http://openchamber.homelab {
    reverse_proxy macbook-arena.homelab:80 {
        header_up Host openchamber.homelab
    }
}
```

- `macbook-arena.homelab` is a stable hostname served by the homelab's own
  dnsmasq, and resolves to whichever IP the laptop is currently on (Wi-Fi or
  Ethernet, whichever owns the default route). The IP is auto-published by
  the laptop's `homelab-publish` LaunchAgent on every network change. See
  `../homelab-publish/README.md` for the publish flow.
- The laptop's own Caddy reverse-proxies `Host: openchamber.homelab` to
  `127.0.0.1:4096` where the openchamber LaunchAgent is listening (see
  `../openchamber/README.md`).
- `header_up Host openchamber.homelab` ensures the laptop's Caddy receives
  the canonical `Host` header rather than `macbook-arena.homelab:80`, so the
  matcher on the laptop side stays simple.
- No more health checks / load balancing / IP pairs — the dnsmasq publish
  mechanism replaces both. dnsmasq always points at one IP at a time, and
  the laptop's LaunchAgent updates that IP within seconds of a network
  change. Failure mode is a brief connect-timeout while a new TCP connection
  retries; previously the failure mode was `lb_policy first` flipping
  between two pinned IPs.

### Edit / reload workflow

```sh
ssh homelab
vim /home/zephyr/Extra/Misc/homelab/configs/caddy/Caddyfile
docker exec caddy caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
docker restart caddy        # full restart - reload sometimes fails to pick up
                            # bind-mount changes; restart is reliable
```

Caddy admin API is on a unix socket inside the container:

```sh
docker exec caddy curl -sS --unix-socket /run/caddy-admin.sock \
    http://localhost/reverse_proxy/upstreams
```

Useful to confirm health-check state after edits.

### Two-Caddy chain for `openchamber.homelab`

`openchamber.homelab` is the only `*.homelab` name that involves the laptop.
It rides through *two* Caddy instances cooperating:

| Caddy | Where | Listens | What it does |
|---|---|---|---|
| Homelab Caddy | `caddy:2` Docker container, host net | homelab `:80` | All `*.homelab`. For most names, reverse-proxies to `127.0.0.1:<port>` on the homelab. For `openchamber.homelab`, reverse-proxies to the laptop's Caddy via `macbook-arena.homelab:80` |
| Laptop Caddy | Homebrew (`homebrew.mxcl.caddy`) | laptop `:80` | A single `http://openchamber.homelab` site that reverse-proxies to `127.0.0.1:4096` (the openchamber LaunchAgent) |

The two-Caddy design isn't redundant — it exists because openchamber must be
reachable via three independent ingress paths that all converge on laptop
`:80`:

1. **Twingate `Mac (Work)` direct** (phone off home network)
   Phone → Twingate → `bronze-mouse` connector → `host-gateway` → laptop `:80`
2. **Twingate `Lab` wildcard fallback** (when `Mac (Work)` is down)
   Phone → Twingate → `berserk-mayfly` connector → homelab `:80` → homelab
   Caddy → laptop `:80`
3. **LAN client** (laptop or phone on home Wi-Fi, no Twingate)
   client → homelab via `*.homelab` DNS (`192.168.1.222`) → homelab Caddy →
   laptop `:80`

All three terminate at laptop Caddy, which serves the openchamber UI from
`127.0.0.1:4096`. One openchamber instance, three reachability paths, single
laptop-side matcher (`http://openchamber.homelab`).

The `header_up Host openchamber.homelab` directive in the homelab Caddyfile
is what keeps path 2 working — without it the laptop would receive
`Host: macbook-arena.homelab:80` and fail to match its single site block.

The laptop Caddyfile lives at `../caddy/Caddyfile`:

```
{ auto_https off; admin off }

http://openchamber.homelab {
    reverse_proxy 127.0.0.1:4096
}
```

Reload after edits with `caddy reload --config /Users/psharma/dotfiles/caddy/Caddyfile`
or `brew services restart caddy` if the admin API isn't reachable.

## DNS (`*.homelab`)

`dnsmasq` runs on the homelab box and resolves all `*.homelab` to
`192.168.1.222` (homelab itself), so traffic always reaches homelab Caddy first.

Config: `/etc/dnsmasq.d/homelab.conf`

```
address=/.homelab/192.168.1.222
no-resolv
server=8.8.4.4
server=1.1.1.1
```

Reload with `sudo systemctl restart dnsmasq` after edits.

The dotfiles file `dns/homelab` is a one-line `nameserver 192.168.1.222`
intended for use as a per-machine `/etc/resolv.conf` override on devices that
need to resolve `*.homelab` directly. Not currently linked anywhere automatic.

## Laptop IP auto-publishing

The homelab Caddy reverse-proxies `openchamber.homelab` to
`macbook-arena.homelab:80` — a stable hostname, not a fixed IP. That hostname
is owned by the homelab's own dnsmasq and is continuously refreshed to point
at whichever IP the laptop currently holds on its default-route interface.

```
laptop network change                    (Wi-Fi/Ethernet hot-swap, DHCP renewal, sleep/wake)
        │
        ▼
/var/run/resolv.conf rewritten           (macOS configd)
        │
        ▼
LaunchAgent fires                        (com.psharma.homelab-publish, WatchPaths)
        │
        ▼
zsh/scripts/homelab-publish-ip           (default-route iface → current IPv4)
        │
        ▼
ssh homelab homelab-publish-ip-receive   (NOPASSWD via /etc/sudoers)
        │
        ▼
write address=/macbook-arena.homelab/<ip>
to /etc/dnsmasq.d/laptop-address.conf
        │
        ▼
systemctl restart dnsmasq                (full restart — SIGHUP doesn't re-read /etc/dnsmasq.d/)
        │
        ▼
homelab Caddy resolves the new IP        (next TCP connect → DNS lookup → live IP)
```

End-to-end latency from a network change to a working DNS update is ~5-15 s
(LaunchAgent WatchPaths debounce + SSH round-trip + dnsmasq restart).
Verified by toggling `networksetup -setnetworkserviceenabled "AX88179A"
off/on` and observing 10 s detect-and-publish on each transition.

dnsmasq's **longest-match-wins** precedence is what makes this safe alongside
the existing wildcard: `address=/macbook-arena.homelab/<ip>` (specific, 22-char
match) overrides `address=/.homelab/192.168.1.222` (wildcard, 8-char match)
for this single name only. Every other `*.homelab` lookup still falls
through to `192.168.1.222`.

### Failure modes

| Situation | Behavior |
|---|---|
| Laptop off home Wi-Fi | SSH push fails fast (5 s `ConnectTimeout`), script logs and exits cleanly, state file unchanged. Next reconnect re-fires. |
| Laptop sleeping | LaunchAgent doesn't run (launchd suspends with the laptop); on wake, RunAtLoad-via-resume + WatchPaths fire. |
| dnsmasq restart slow | New TCP connections from homelab Caddy retry; dnsmasq is back in <1 s in practice. |
| Wrong IP cached at homelab Caddy | Caddy's static upstream re-resolves on each new TCP connection (HTTP keep-alive may pin a stale connection briefly; usually <2 min). |

### Files involved

| Path | Side | Role |
|---|---|---|
| `../homelab-publish/com.psharma.homelab-publish.plist` | laptop | LaunchAgent (RunAtLoad + WatchPaths + 5-min poll) |
| `../zsh/scripts/homelab-publish-ip` | laptop | The publish script (default-route → SSH → state file) |
| `~/.cache/homelab-publish-ip/{log,last_pushed_ip}` | laptop | Runtime state |
| `/usr/local/bin/homelab-publish-ip-receive` | homelab | Receiver — writes the dnsmasq directive, restarts dnsmasq |
| `/etc/sudoers` (last line) | homelab | NOPASSWD rule for the receiver — must be at end-of-file to win |
| `/etc/dnsmasq.d/laptop-address.conf` | homelab | The dynamic `address=` directive itself |

Bootstrap of all of the above is **not** automated by `install.sh` (deliberate
choice — sudoers and dnsmasq edits are too sensitive for unattended apply).
Step-by-step setup lives in `../homelab-publish/README.md`.

## How the laptop fits in

### `openchamber.homelab` request flow

```
            ┌─────────────────────────────────────────────────────────┐
            │  Phone or LAN client typing http://openchamber.homelab  │
            └──────────────────────────────┬──────────────────────────┘
                                           │
                ┌──────────────────────────┴──────────────────────────┐
                │                                                     │
                ▼                                                     ▼
      [Phone via Twingate]                              [LAN client, no Twingate]
                │                                                     │
   ┌────────────┴────────────┐                                        │
   │                         │                                        │
   ▼                         ▼                                        ▼
Mac (Work) connector    Lab connector                       dnsmasq on homelab
(bronze-mouse on        (berserk-mayfly                     resolves *.homelab
the laptop)             on homelab)                         → 192.168.1.222
   │                         │                                        │
   ▼                         ▼                                        ▼
laptop:80 via              homelab:80                          homelab:80
host-gateway                  │                                        │
   │                          ├──────────► same as ◄─────────────┘
   ▼                          ▼
laptop's Caddy           homelab's Caddy
(Host:                   (matches Host: openchamber.homelab)
 openchamber.homelab)         │
   │                          ▼
   ▼                     header_up Host openchamber.homelab
127.0.0.1:4096                │
(openchamber                  ▼
 LaunchAgent)            laptop:80 (via macbook-arena.homelab -> .2)
                              │
                              ▼
                         laptop's Caddy
                              │
                              ▼
                         127.0.0.1:4096
                         (openchamber LaunchAgent)
```

Three independent paths, all terminating at the openchamber LaunchAgent on this
laptop. If `openchamber/start.sh` isn't running, all of them break.

### Related Twingate resources

The full picture lives in [Twingate](#twingate) above. Quick recap of the two
resources that route specifically into / through the homelab path:

| Twingate resource | Network | Address | Path |
|---|---|---|---|
| `Openchamber (Work Mac direct)` | `Mac (Work)` | `openchamber.homelab:80` (DNS) | bronze-mouse → laptop:80 (via container's `--add-host=openchamber.homelab:host-gateway`) — **does not touch homelab** |
| `Homelab Services` | `Lab` | `*.homelab:80` (wildcard) | berserk-mayfly resolves via dnsmasq → homelab:80 → homelab Caddy → laptop:80 |

The `Homelab Services` wildcard automatically provides Lab-side fallback for
`openchamber.homelab` if the Mac (Work) connector goes down — Twingate falls
through from the more-specific direct resource to the wildcard, which routes
via the homelab Caddy reverse-proxy chain.

## Operations

```sh
# Restart everything
ssh homelab
cd /home/zephyr/Extra/Misc/homelab
docker compose restart

# Just caddy
docker restart caddy

# Tail caddy logs
docker logs -f caddy

# Tail all compose logs
docker compose logs -f --tail 50
```

## Related

- `caddy/Caddyfile` — the laptop's own Caddyfile (proxies `openchamber.homelab` and the laptop IPs to `127.0.0.1:4096`)
- `openchamber/` — the LaunchAgent that keeps openchamber running on the laptop
- `homelab-publish/` — the LaunchAgent that publishes the laptop IP to homelab dnsmasq
- `twingate/README.md` — Twingate connector setup, resources, network IDs
- `dns/homelab` — the `nameserver 192.168.1.222` line for clients that need `*.homelab` resolution
