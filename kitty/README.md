# kitty

[Kitty](https://sw.kovidgoyal.net/kitty/) terminal emulator configuration.

## Theme

Gruvbox dark via `theme.conf` (managed by `kitty +kitten themes`).

## Key Settings

| Setting | Value |
|---------|-------|
| Font size | 17 |
| Window margin | 14 |
| Background | Gruvbox dark, 82% opacity, macOS blur radius 30 |
| Tab bar | Dark base with lighter active tab |
| Tab bar style | Powerline (slanted) |
| Option as Alt | Yes (macOS) |
| Window decorations | System default |
| Scrollback | 10,000 lines |
| Audio bell | Disabled |
| Cursor | Beam |
| Layout | Tall (default) |

## Font Requirements

Requires a [Nerd Font](https://www.nerdfonts.com/) for Powerlevel10k and tmux icons. FiraCode Nerd Font Mono is recommended (commented in config, set via kitty font selector).

## Custom Keybindings

| Key | Action |
|-----|--------|
| `F1` | New window (same directory) |
| `F2` | Open editor in current directory |
