# openchamber

## Theme

`themes/gruvbox-glass-dark.json` is linked into
`~/.config/openchamber/themes/` by `install.sh`. Select **Gruvbox Glass** as the
dark theme in Settings → Appearance; reload themes after editing the file.
It uses the VS Code Gruvbox palette with explicit two-tone surfaces and readable
code/diff colors. OpenChamber can import VS Code theme files, but a native
theme keeps these surface choices stable instead of relying on import-time
color adjustments. Its desktop window does not gain OS-level blur from a theme.

The app's `settings.json` and `preferences.json` stay local. They contain
runtime/private state, and OpenChamber atomically replaces them when saving,
which breaks file-level symlinks. The theme itself is portable; on a new
machine, select it in Settings → Appearance.

There is no LaunchAgent any more. The server behind every remote path is the
one embedded in the **OpenChamber desktop app** (`/Applications/OpenChamber.app`),
listening on `127.0.0.1:57123`.

## How it works

- On start the app reuses `desktopLocalPort` from `~/.config/openchamber/settings.json`
  (currently `57123`, also the app's built-in default). If that port is taken it
  falls back to a random one, which would break the Caddy proxy; check with
  `lsof -iTCP:57123 -sTCP:LISTEN`.
- It binds loopback only (`desktopLanAccessEnabled: false`), which is what we
  want: the laptop's Caddy (`caddy/Caddyfile`) is the only thing that reaches it.
- The UI password is `desktopUiPassword` in the same settings file (Settings →
  Desktop in the app). The app injects it as the server's UI password.
- The app must be **running** for remote access to work. Add it to
  System Settings → General → Login Items so it starts at login.
  Do not use `openchamber startup`; it would install a competing agent.

Health check: `curl -s http://127.0.0.1:57123/health` (reports `"runtime":"desktop"`).

## How it fits

```
Phone (Twingate)
        │
        ├── Mac (Work) connector (bronze-mouse on this laptop)
        │       └── laptop:80 (Caddy) → reverse_proxy 127.0.0.1:57123 (desktop app)
        │
        └── Lab connector fallback (berserk-mayfly on homelab)
                → homelab:80 (Caddy) → laptop:80 (Caddy) → 127.0.0.1:57123

Anything on home Wi-Fi (no Twingate)
        └── http://openchamber.homelab → homelab Caddy → laptop Caddy → 127.0.0.1:57123
```

If the desktop app is quit, all paths return `502` from the laptop's Caddy.

## Manual / standalone use

`oc-serve` (`zsh/.zshrc`) runs a standalone `openchamber serve` on `:4096`
(all interfaces, password flag). It no longer conflicts with anything, but it is
a separate instance with its own OpenCode process; use it for debugging only.

## Related

- `caddy/Caddyfile`: reverse-proxies `openchamber.homelab` → `127.0.0.1:57123`
- `homelab/README.md`: homelab Caddy chain
- `twingate/README.md`: `Openchamber (Work Mac direct)` resource
