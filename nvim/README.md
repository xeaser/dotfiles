# nvim

[LazyVim](https://www.lazyvim.org/) based Neovim configuration with gruvbox-material colorscheme.

## Colorscheme

**gruvbox-material** (hard background, material foreground) with extensive highlight overrides for NeoTree, bufferline, floats, diagnostics, indent guides, and more. Also includes catppuccin, kanagawa, everforest, and onedark as lazy-loaded alternatives.

The editor, sidebar, statusline, and bufferline are transparent
(`gruvbox_material_transparent_background = 2`) so the terminal's blurred
background shows through in Kitty and Zed. Floats, popups, and completion menus
stay solid for readability. Set `local transparent = false` in
`lua/plugins/colorscheme.lua` to restore the solid two-tone layout.

## Plugins

| Plugin | Description |
|--------|-------------|
| **avante.nvim** | AI assistant (Claude provider) |
| **opencode.nvim** | OpenCode integration with snacks.nvim |
| **neovim-project** | Project manager with fzf-lua picker |
| **neotest** | Test runner (Go, Jest, Python, Busted adapters) |
| **nvim-dap-ui** | Debug adapter UI with auto NeoTree toggle |
| **noice.nvim** | Classic bottom cmdline (overrides popup default) |
| **vim-tmux-navigator** | Seamless Ctrl+h/j/k/l pane navigation |
| **treesitter** | Extended parsers: Go, Bash, Lua, Python, YAML, JSON |

## Key Shortcuts

Leader key is `Space`.

| Shortcut | Action |
|----------|--------|
| `leader + aa` | Avante AI chat |
| `leader + gg` | LazyGit |
| `leader + tt` | Run nearest test |
| `leader + tf` | Run file tests |
| `leader + ts` | Toggle test summary |
| `leader + td` | Debug nearest test |
| `leader + pp` | Browse projects |
| `leader + pr` | Recent project |
| `leader + oo` | Toggle opencode |
| `leader + oa` | Ask opencode |
| `Ctrl+h/j/k/l` | Navigate splits (tmux-aware) |
| `gnn` | Init treesitter selection |
| `grn` | Expand treesitter selection |
