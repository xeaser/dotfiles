# homelab-publish

LaunchAgent that pushes this laptop's current LAN IP to the homelab dnsmasq
under a stable hostname (`macbook-arena.homelab`). The homelab Caddy uses
that name as a `reverse_proxy` upstream, so when the laptop's IP drifts the
homelab side keeps working with no manual edits.

## How it triggers

| Trigger | When |
|---|---|
| `RunAtLoad` | At LaunchAgent load (login / first bootstrap) |
| `WatchPaths /var/run/resolv.conf` | Default-route DNS changes — DHCP renewal, network switch |
| `WatchPaths /Library/Preferences/SystemConfiguration/NetworkInterfaces.plist` | Any interface state change |
| `StartInterval 300` | Polling fallback every 5 minutes (catches edge cases) |
| `ThrottleInterval 10` | Rate-limit: skip re-runs within 10s of the previous |

Each fire runs the script to completion and exits. `KeepAlive` is **not** set
because this isn't a daemon — it's an event-driven one-shot.

## Files

| File | Purpose |
|---|---|
| `com.psharma.homelab-publish.plist` | LaunchAgent manifest (manually symlinked to `~/Library/LaunchAgents/`; not part of `install.sh`) |
| `../zsh/scripts/homelab-publish-ip` | The script (bash, on `$PATH` via dotfiles) — invoked by the LaunchAgent and runnable manually |

## What gets pushed

The script picks the interface owning the **default route** at the moment it
fires (via `route -n get default`), then `ipconfig getifaddr` for that
interface. So:

- Wi-Fi up, Ethernet down → Wi-Fi IP pushed (e.g. `192.168.1.12`)
- Ethernet up, Wi-Fi off/down → Ethernet IP pushed (e.g. `192.168.1.2`)
- Both up → whichever owns the default route (usually Ethernet if its service
  order is higher; Service Order is set in System Settings → Network)
- Wi-Fi disconnects mid-session → resolv.conf rewrites → LaunchAgent fires
  → new default-route IP (Ethernet) gets pushed automatically

Only a *single* IP is in dnsmasq at any time. Failover at the Caddy
load-balancer level is no longer needed because dnsmasq itself swaps the IP.

## Bootstrap (first-time install)

Not handled by `install.sh` — manual. Order matters: homelab side first, then
laptop side.

### Homelab side

The receiver writes a dnsmasq `address=` directive (not an `addn-hosts` entry).
Two things matter:

1. **`address=` instead of `addn-hosts`** — `/etc/dnsmasq.d/homelab.conf` already
   has `address=/.homelab/192.168.1.222` as the wildcard default for any
   `*.homelab` name. dnsmasq's `address=` directive resolves *authoritatively*
   and bypasses hosts files entirely, so an `addn-hosts` entry like
   `192.168.1.12 macbook-arena.homelab` is silently ignored. A second, more
   specific `address=/macbook-arena.homelab/192.168.1.12` *does* override the
   wildcard because dnsmasq picks the longest-match rule.
2. **`systemctl restart dnsmasq`, not `reload`** — `SIGHUP` (what `reload` sends)
   only re-reads `/etc/hosts` and `addn-hosts` files. It does **not** re-read
   the main config or anything in `/etc/dnsmasq.d/`. A full restart is the
   only reliable way to pick up a new `address=` directive.

```sh
ssh homelab

# 1. Receiver script — writes a dnsmasq address= file and restarts dnsmasq
sudo tee /usr/local/bin/homelab-publish-ip-receive > /dev/null <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[ "$#" -eq 2 ] || { echo "usage: $0 <hostname> <ip>" >&2; exit 1; }
NAME="$1"; IP="$2"
[[ "$IP"   =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || { echo "bad ip: $IP" >&2; exit 1; }
[[ "$NAME" =~ ^[a-zA-Z0-9.-]+$ ]] || { echo "bad name: $NAME" >&2; exit 1; }
DEST=/etc/dnsmasq.d/laptop-address.conf
TMP=$(mktemp)
grep -v "^address=/${NAME}/" "$DEST" 2>/dev/null > "$TMP" || true
echo "address=/${NAME}/${IP}" >> "$TMP"
mv "$TMP" "$DEST"
chmod 644 "$DEST"
systemctl restart dnsmasq
echo "ok: $NAME -> $IP"
EOF
sudo chown root:root /usr/local/bin/homelab-publish-ip-receive
sudo chmod 755 /usr/local/bin/homelab-publish-ip-receive

# 2. NOPASSWD sudoers entry — must go into /etc/sudoers itself, NOT /etc/sudoers.d/.
#    Debian's default /etc/sudoers has user-specific rules (e.g. `zephyr ALL=(ALL) ALL`)
#    AFTER the `@includedir /etc/sudoers.d` directive. Anything in /etc/sudoers.d/ is
#    parsed at the @includedir position, then the user-specific rules below it parse
#    LAST and override our NOPASSWD entry (sudo is last-match-wins).
#    Putting the rule at the very END of /etc/sudoers makes it the final match for
#    this command. visudo -cf validates before commit so a bad edit can't lock us out.
LINE='zephyr ALL=(ALL) NOPASSWD: /usr/local/bin/homelab-publish-ip-receive'
if ! sudo grep -qF "$LINE" /etc/sudoers; then
    sudo cp /etc/sudoers /etc/sudoers.bak.$(date +%s)
    TMP=$(mktemp)
    sudo cat /etc/sudoers > "$TMP"
    {
        echo ""
        echo "# homelab-publish-ip auto-published receiver (must be last to win)"
        echo "$LINE"
    } >> "$TMP"
    sudo visudo -cf "$TMP" && sudo cp "$TMP" /etc/sudoers
    rm -f "$TMP"
fi

# 3. (no separate dnsmasq config file needed — receiver writes laptop-address.conf
#     directly, and dnsmasq autoload of /etc/dnsmasq.d picks it up on next restart)
```

### Laptop side

```sh
ln -sf /Users/psharma/dotfiles/homelab-publish/com.psharma.homelab-publish.plist \
       ~/Library/LaunchAgents/com.psharma.homelab-publish.plist

launchctl bootstrap "gui/$UID" \
    ~/Library/LaunchAgents/com.psharma.homelab-publish.plist
# fallback if bootstrap returns I/O error 5 (post-bootout quirk):
# launchctl load -w ~/Library/LaunchAgents/com.psharma.homelab-publish.plist
```

`RunAtLoad: true` makes it fire immediately, so the first push happens at
bootstrap.

## Verify

```sh
# laptop side: did the script run?
tail -f ~/.cache/homelab-publish-ip/log
tail -f /opt/homebrew/var/log/homelab-publish.{log,err}

# homelab side: is the entry there?
ssh homelab cat /etc/dnsmasq.d/laptop-address.conf
ssh homelab "dig +short @127.0.0.1 macbook-arena.homelab"   # specific entry
ssh homelab "dig +short @127.0.0.1 plex.homelab"             # wildcard fallback still works
```

## Service management

```sh
# trigger immediately (out-of-band run)
launchctl kickstart -k gui/$UID/com.psharma.homelab-publish

# stop
launchctl bootout gui/$UID/com.psharma.homelab-publish

# manual one-off run (no LaunchAgent involved)
homelab-publish-ip
```

## Behavior when off home network

`ssh -o ConnectTimeout=5 homelab` fails fast (5s) when not on home LAN. The
script catches the failure, logs it as `ssh push failed`, and exits cleanly.
The state file is **not** updated, so the next time the laptop returns home
the IP gets pushed correctly even if it hasn't actually changed since the
last successful push.

dnsmasq keeps the previous (stale) entry. That's fine because:
- the homelab Caddy fallback path only matters when on home Wi-Fi (LAN browse)
- when remote, openchamber is reached via the Mac (Work) Twingate connector,
  which doesn't depend on the homelab Caddy at all

## Related

- `../zsh/scripts/homelab-publish-ip` — the actual script
- `../homelab/README.md` — documents the homelab Caddy + dnsmasq side, including the receiver setup and Caddyfile upstream
- `../openchamber/README.md` — the LaunchAgent that needs the laptop reachable
- `../twingate/README.md` — Twingate resources that use the homelab path as fallback
