# Twingate

Documentation of the Twingate setup that gives my phone access to the
CloudBees GitHub org over both home Wi-Fi and mobile data. Replaces an
earlier laptop HTTPS-CONNECT proxy ("`github-proxy`", removed) and the
Hiddify Next workaround on the phone.

> Network: **`zephyr`** (admin console: https://zephyr.twingate.com)

---

## The problem this solves

- CloudBees GitHub allowlists corp tailnet egress IPs.
- My laptop is on the corp tailnet; my phone is BYOD and can't join it.
- Personal tailnet has no exit node, so Tailscale subnet-routing isn't an option.
- Need a way for the phone — on Wi-Fi or cellular — to reach `github.com`
  through the corp-allowlisted egress.

## Architecture (Option A — Twingate handles GitHub routing natively)

```
                       Wi-Fi or cellular
   Phone (Twingate ON) ─────────────────► Twingate Cloud
                                                 │
                                                 ▼
                                       Connector "bronze-mouse"
                                       (Docker on this laptop)
                                                 │
                                       docker bridge → host netns
                                                 │
                                                 ▼
                                          utun4 (corp tailnet)
                                                 │
                                                 ▼
                                       corp egress IP
                                  (e.g. 34.73.18.111, GCP)
                                                 │
                                                 ▼
                                           github.com ✓ allowlisted
```

Phone's resolver is intercepted by the Twingate client for the seven GitHub
domains listed below. Everything else on the phone goes direct (split tunnel).
No HTTP CONNECT proxy. No Hiddify. No code on the laptop beyond the
Connector container.

---

## Components

### Remote networks

| Name        | Connector       | Where it runs                   |
| ----------- | --------------- | ------------------------------- |
| `Lab`       | `berserk-mayfly`| Homelab box (`192.168.1.222`)   |
| `Mac (Work)`| `bronze-mouse`  | This laptop, Docker container   |

GitHub Resources are bound to **`Mac (Work)`** because only the laptop has
corp tailnet egress that CloudBees accepts.

### Connector on this laptop

Runs as a Docker container.

| Field            | Value                                                     |
| ---------------- | --------------------------------------------------------- |
| Container name   | `twingate-connector`                                      |
| Image            | `twingate/connector:latest`                               |
| Restart policy   | `unless-stopped`                                          |
| Network mode     | `bridge` (default Docker bridge)                          |
| Required env     | `TWINGATE_NETWORK`, `TWINGATE_ACCESS_TOKEN`, `TWINGATE_REFRESH_TOKEN` |
| Tokens stored in | `~/.secrets` (gitignored, not in repo)                    |
| Managed by       | `zsh/scripts/tw-connector` — aliases `tw-start`, `tw-stop`|

The Connector reads its tokens from `~/.secrets` via the wrapper script.
Outbound traffic from inside the container follows host routing, so the
laptop's `utun4` corp tailnet route for GitHub IPs is honored automatically.

### GitHub Resources (the 7 created for this setup)

All on `Mac (Work)` network, granted to the `Admin` group, TCP 443 only,
UDP/ICMP off.

| Name                  | Address                  | Resource ID (base64)              |
| --------------------- | ------------------------ | --------------------------------- |
| `GitHub`              | `*.github.com`           | `UmVzb3VyY2U6MzUzNzM0NQ==`        |
| `GitHub apex`         | `github.com`             | `UmVzb3VyY2U6MzU1MzYzMA==`        |
| `GitHub user content` | `*.githubusercontent.com`| `UmVzb3VyY2U6MzU1MzYzMQ==`        |
| `GitHub assets CDN`   | `*.githubassets.com`     | `UmVzb3VyY2U6MzU1MzYzMg==`        |
| `GitHub Copilot`      | `*.githubcopilot.com`    | `UmVzb3VyY2U6MzU1MzYzMw==`        |
| `GitHub Codespaces`   | `*.github.dev`           | `UmVzb3VyY2U6MzU1MzYzNA==`        |
| `GitHub Pages`        | `*.github.io`            | `UmVzb3VyY2U6MzU1MzYzNQ==`        |

`GitHub` reuses the slot of an earlier resource (originally
`Github Proxy / 192.168.1.12:8888`) by renaming + repointing it.

### Other resources (informational, pre-existing)

| Name                                  | Address              | Network     |
| ------------------------------------- | -------------------- | ----------- |
| `Access` (Plex)                       | `192.168.1.222:32400`| `Lab`       |
| `Homelab`                             | `192.168.1.222`      | `Lab`       |
| `Homelab Services`                    | `*.homelab:80`       | `Lab`       |
| `Openchamber (Work Mac direct)`       | `openchamber.homelab:80` | `Mac (Work)` |

### Access groups

| Group      | Type    | Members                                              |
| ---------- | ------- | ---------------------------------------------------- |
| `Everyone` | SYSTEM  | All users                                            |
| `Admin`    | MANUAL  | `sharmarag93@gmail.com`, `ptayal718@gmail.com`       |

All seven GitHub resources are scoped to `Admin`.

---

## Phone setup

1. Install **Twingate** Android client.
2. Sign in with `sharmarag93@gmail.com`, network `zephyr`.
3. **Settings → Network & internet → Private DNS = Automatic** (or Off).
   A custom Private DNS hostname will bypass Twingate's interception and
   silently break GitHub access.
4. Connect. The 7 GitHub resources should appear in the resource list
   alongside `Openchamber`, `Homelab`, etc.
5. Hiddify Next is no longer needed and has been uninstalled.

Test: open the GitHub mobile app and load CloudBees on Wi-Fi, then
disable Wi-Fi and repeat on cellular. Both must work.

---

## Operations

### Start / stop the Connector

```sh
tw-start              # docker start (or run if missing)
tw-stop               # docker stop
docker logs -f twingate-connector
docker inspect -f '{{.State.Status}}' twingate-connector
```

The Connector is also marked `--restart unless-stopped`, so a Docker daemon
restart brings it back automatically.

### Add a new domain (e.g. another GitHub-adjacent hostname)

Two options:

1. **UI:** Twingate Admin Console → Network → `Mac (Work)` → Add Resource →
   DNS address → assign to `Admin` group → TCP 443 only.
2. **API:** see `Disaster recovery` below; `resourceCreate` mutation pattern.

Keep the protocol scope tight (TCP 443 only). Don't add UDP / ICMP / wide
TCP unless the domain genuinely needs it.

### Remove a resource

UI: Admin Console → Resources → ⋮ → Delete.
API: `resourceDelete(id: "<base64-id>")`.

---

## Disaster recovery

### Connector container lost (image gone, machine reset, etc.)

```sh
source ~/.secrets
tw-start
```

The Connector re-registers automatically using the access + refresh tokens
in `~/.secrets`. Same Connector identity (`bronze-mouse`) — no need to
update Resource bindings.

### Connector tokens lost (e.g. ~/.secrets reset)

1. Twingate Admin Console → Network → `Mac (Work)` → `bronze-mouse` →
   Generate Tokens.
2. Update `~/.secrets`:
   ```
   export TWINGATE_NETWORK=zephyr
   export TWINGATE_ACCESS_TOKEN=...
   export TWINGATE_REFRESH_TOKEN=...
   ```
3. `tw-stop && docker rm twingate-connector && tw-start`.

### Resources accidentally deleted

Recreate via the API. Below is the exact mutation pattern used originally
(uses `TG_API_KEY` from `~/.secrets`):

```sh
source ~/.secrets
ENDPOINT="https://${TWINGATE_NETWORK}.twingate.com/api/graphql/"
MAC_NET="UmVtb3RlTmV0d29yazoyOTU3NDg="    # Mac (Work)
ADMIN="R3JvdXA6MzI2OTkw"                   # Admin group

create() {
  local name="$1" addr="$2"
  curl -s -X POST "$ENDPOINT" \
    -H "X-API-Key: $TG_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg name "$name" --arg addr "$addr" --arg net "$MAC_NET" --arg grp "$ADMIN" '{
      query: "mutation C($name:String!, $addr:String!, $net:ID!, $grp:[ID]) { resourceCreate(name:$name, address:$addr, remoteNetworkId:$net, protocols:{allowIcmp:false, tcp:{policy:RESTRICTED, ports:[{start:443,end:443}]}, udp:{policy:RESTRICTED}}, groupIds:$grp) { ok error entity { id name } } }",
      variables: { name: $name, addr: $addr, net: $net, grp: [$grp] }
    }')"
  echo
}

create "GitHub"              "*.github.com"
create "GitHub apex"         "github.com"
create "GitHub user content" "*.githubusercontent.com"
create "GitHub assets CDN"   "*.githubassets.com"
create "GitHub Copilot"      "*.githubcopilot.com"
create "GitHub Codespaces"   "*.github.dev"
create "GitHub Pages"        "*.github.io"
```

### Laptop replaced

1. Install Docker Desktop.
2. Clone dotfiles, run `install.sh`.
3. Populate `~/.secrets` from the password manager.
4. Twingate Admin Console → Network → `Mac (Work)` → Generate fresh tokens
   for the existing `bronze-mouse` connector slot (or delete it and let the
   new container register fresh).
5. `tw-start`.
6. The 7 GitHub Resources are bound to `Mac (Work)` → no resource changes
   needed; they automatically use whatever Connector is alive in that
   network.

---

## Verifying egress (confidence check)

If you ever doubt whether Connector traffic is still hitting CloudBees-
allowlisted egress, run this from the laptop:

```sh
docker run --rm --network=container:twingate-connector alpine:3.20 sh -c '
  apk add --no-cache --quiet curl
  curl -sS --max-time 10 -w "HTTP=%{http_code} remote_ip=%{remote_ip}\n" https://api.github.com/zen
  curl -sS --max-time 10 https://ifconfig.me; echo " (egress IP)"
'
```

Expect:
- `HTTP=200` and a real GitHub Zen quote.
- An egress IP that matches the corp tailnet exit (a GCP IP from the
  CloudBees allowlist range, not your home ISP).

If `HTTP=200` but the egress IP is your home ISP, the laptop has dropped
its corp tailnet route — fix that before debugging Twingate.

---

## Why this is safe (security notes)

- **Single Connector identity** (`bronze-mouse`) gates all phone-side GitHub
  traffic. Revoking its tokens (Admin Console → Connector → Revoke) cuts
  off the phone immediately.
- **Resources are scoped to TCP 443 only.** No UDP, no ICMP, no wider TCP.
- **Access list is `Admin` group only**, two members. Not `Everyone`.
- **Tokens in `~/.secrets`** which is gitignored. Repo never sees them.
- **Phone never gets corp tailnet credentials.** It only gets DNS-routed
  access to `*.github.com` and friends; everything else stays direct.
- **No HTTP CONNECT proxy** running on the laptop — strictly fewer attack
  surfaces than the previous Hiddify + `github-proxy` design.

---

## Related files in this repo

- `zsh/scripts/tw-connector` — the start/stop/status wrapper for the
  Connector container.
- `zsh/.zshrc` — defines `tw-start`, `tw-stop` aliases and the `homelab` ssh
  alias.
- `.secrets.example` — names of required env vars (no values).

## Useful links

- Twingate Admin Console: https://zephyr.twingate.com
- Twingate API GraphQL endpoint: https://zephyr.twingate.com/api/graphql/
  (auth: `X-API-Key: $TG_API_KEY`)
- Connector image: https://hub.docker.com/r/twingate/connector
