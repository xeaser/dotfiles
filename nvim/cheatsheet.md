# LazyVim Keybinding Cheatsheet

> Leader key is `Space`. So `<leader>ff` means `Space` then `f` then `f`.
> Config: LazyVim v15 | Extras: lang.go, lang.python, lang.json, lang.yaml, lang.docker, lang.terraform, lang.helm, lang.markdown, lang.git, lang.typescript, dap.core, test.core, editor.fzf, editor.neo-tree, editor.illuminate, editor.navic, editor.aerial, editor.refactoring, ui.indent-blankline, ui.mini-animate, coding.mini-surround

---

## File Navigation

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `<leader>ff` | Find files (root dir) | Cmd+Shift+O |
| `<leader>fF` | Find files (cwd) | -- |
| `<leader>fg` | Find files (git tracked) | -- |
| `<leader>fr` | Recent files | Cmd+E |
| `<leader>fR` | Recent files (cwd) | -- |
| `<leader>fc` | Find config file | -- |
| `<leader>` `<Space>` | Find files (root dir) | Cmd+Shift+O |

---

## File Explorer (NeoTree)

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `<leader>e` | Toggle explorer (root dir) | Cmd+1 (Project panel) |
| `<leader>E` | Toggle explorer (cwd) | -- |
| `<leader>fe` | Same as `<leader>e` | -- |
| `<leader>fE` | Same as `<leader>E` | -- |
| `<leader>ge` | Git explorer | Alt+9 (Git panel) |
| `<leader>be` | Buffer explorer | -- |

**Inside NeoTree:**

| Key | Action |
|-----|--------|
| `Enter` | Open file |
| `a` | Create file/directory |
| `d` | Delete |
| `r` | Rename |
| `c` | Copy |
| `m` | Move |
| `y` | Copy name to clipboard |
| `Y` | Copy relative path |
| `P` | Toggle preview |
| `s` | Open in horizontal split |
| `S` | Open in vertical split |
| `H` | Toggle hidden files |
| `/` | Filter |
| `q` | Close explorer |

---

## Buffers and Tabs

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `H` | Previous buffer | Cmd+Shift+[ |
| `L` | Next buffer | Cmd+Shift+] |
| `<leader>,` | Switch buffer (picker) | Ctrl+Tab |
| `<leader>fb` | Buffer picker | Ctrl+Tab |
| `<leader>fB` | All buffers | -- |
| `<leader>bp` | Pin buffer | Pin Tab |
| `<leader>bP` | Close non-pinned buffers | Close All but Pinned |
| `<leader>bl` | Close buffers to the left | Close Tabs to Left |
| `<leader>br` | Close buffers to the right | Close Tabs to Right |
| `[B` | Move buffer left | -- |
| `]B` | Move buffer right | -- |

---

## Windows and Splits

| Keybinding | Action |
|------------|--------|
| `Ctrl+W v` | Split vertical |
| `Ctrl+W s` | Split horizontal |
| `Ctrl+W w` | Cycle through windows |
| `Ctrl+W q` | Close window |
| `Ctrl+W h/j/k/l` | Move to left/down/up/right window |
| `Ctrl+W =` | Equalize window sizes |
| `Ctrl+W _` | Maximize window height |
| `Ctrl+W \|` | Maximize window width |
| `Ctrl+W T` | Move window to new tab |

---

## Go to Line / Position

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `:<number>` | Go to line (e.g., `:42`) | Cmd+L |
| `<number>G` | Go to line (e.g., `42G`) | Cmd+L |
| `gg` | Go to first line | Cmd+Home |
| `G` | Go to last line | Cmd+End |
| `Ctrl+F` | Scroll forward (page down) | Page Down |
| `Ctrl+B` | Scroll backward (page up) | Page Up |
| `Ctrl+D` | Scroll half page down | -- |
| `Ctrl+U` | Scroll half page up | -- |
| `zz` | Center cursor on screen | -- |
| `zt` | Cursor line to top of screen | -- |
| `zb` | Cursor line to bottom of screen | -- |
| `%` | Jump to matching bracket | -- |

---

## LSP Navigation

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `gd` | Go to definition | Cmd+B / Cmd+Click |
| `gD` | Go to declaration | Cmd+B |
| `grr` | Find all references | Alt+F7 |
| `gri` | Go to implementation | Cmd+Alt+B |
| `grt` | Go to type definition | Cmd+Shift+B |
| `K` | Hover documentation | Ctrl+Q / F1 |
| `gO` | Document symbols (outline) | Alt+7 (Structure panel) |
| `<leader>ss` | Goto symbol (current file) | Cmd+F12 |
| `<leader>sS` | Goto symbol (workspace) | Cmd+Alt+Shift+N |
| `<leader>cS` | LSP refs/defs in Trouble | -- |
| `<leader>cs` | Symbols in Trouble panel | -- |

---

## LSP Actions

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `gra` | Code action (quick fix) | Alt+Enter |
| `grn` | Rename symbol | Shift+F6 |
| `<leader>cF` | Format injected languages | -- |
| `<leader>cm` | Mason (manage LSP/tools) | Settings > Plugins |

---

## Code Folding (Expand/Collapse)

Fold method: `indent` | All folds open by default (`foldlevel=99`)

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `za` | Toggle fold under cursor | Cmd+. |
| `zo` | Open fold | Cmd++ |
| `zc` | Close fold | Cmd+- |
| `zO` | Open all folds recursively under cursor | -- |
| `zC` | Close all folds recursively under cursor | -- |
| `zR` | **Open ALL folds in file** | Cmd+Shift++ |
| `zM` | **Close ALL folds in file** | Cmd+Shift+- |
| `zr` | Open one more fold level | -- |
| `zm` | Close one more fold level | -- |
| `zj` | Move to next fold | -- |
| `zk` | Move to previous fold | -- |

---

## Search

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `/` | Search forward in file | Cmd+F |
| `?` | Search backward in file | -- |
| `n` / `N` | Next / previous match | F3 / Shift+F3 |
| `*` | Search word under cursor (forward) | -- |
| `#` | Search word under cursor (backward) | -- |
| `<leader>/` | Grep in all files (root dir) | Cmd+Shift+F |
| `<leader>sg` | Grep in all files (root dir) | Cmd+Shift+F |
| `<leader>sG` | Grep in all files (cwd) | -- |
| `<leader>sw` | Search current word (root dir) | -- |
| `<leader>sW` | Search current word (cwd) | -- |
| `<leader>sb` | Search buffer lines | -- |

---

## Search and Replace

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `<leader>sr` | Search and Replace (grug-far) | Cmd+Shift+R |
| `:%s/old/new/g` | Replace all in file (vim) | Cmd+R |
| `:%s/old/new/gc` | Replace all with confirm | -- |

---

## Diagnostics and Errors

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `]d` | Next diagnostic | F2 |
| `[d` | Previous diagnostic | Shift+F2 |
| `]D` | Last diagnostic in buffer | -- |
| `[D` | First diagnostic in buffer | -- |
| `<leader>xx` | Diagnostics (Trouble panel) | Alt+6 (Problems) |
| `<leader>xX` | Buffer diagnostics (Trouble) | -- |
| `<leader>sd` | Diagnostics picker | -- |
| `<leader>sD` | Buffer diagnostics picker | -- |
| `Ctrl+W d` | Show diagnostic under cursor | -- |

---

## Trouble Panel

| Keybinding | Action |
|------------|--------|
| `<leader>xx` | Diagnostics |
| `<leader>xX` | Buffer diagnostics |
| `<leader>xL` | Location list |
| `<leader>xQ` | Quickfix list |
| `<leader>xT` | TODO/FIX/FIXME |
| `<leader>xt` | TODO only |
| `[q` / `]q` | Prev/next trouble item |

---

## Flash (Fast Jump)

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `s` | Flash jump (type chars to jump) | AceJump plugin |
| `S` | Flash treesitter (select by AST node) | -- |

---

## Treesitter Incremental Selection (Custom)

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `gnn` | Start selection | Ctrl+W (Extend Selection) |
| `grn` | Expand selection (node) | Ctrl+W again |
| `grc` | Expand selection (scope) | -- |
| `grm` | Shrink selection | Ctrl+Shift+W |

> NOTE: `grn` in normal mode triggers LSP rename. The treesitter `grn`
> only activates in visual mode after `gnn` starts a selection.

---

## Comments

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `gcc` | Toggle comment (current line) | Cmd+/ |
| `gc` | Toggle comment (visual selection) | Cmd+/ |

---

## Git (gitsigns)

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `<leader>gs` | Git status | Alt+9 |
| `<leader>gc` | Git commits | Git Log |
| `<leader>gl` | Git commits (log) | Git Log |
| `<leader>gd` | Git diff (hunks) | Cmd+D |
| `<leader>gS` | Git stash | Git Stash |
| `]h` / `[h` | Next/prev git hunk | -- |

---

## Debugging (DAP)

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `<leader>db` | Toggle breakpoint | Cmd+F8 |
| `<leader>dB` | Conditional breakpoint | -- |
| `<leader>dc` | Continue / Start debugging | F9 |
| `<leader>di` | Step into | F7 |
| `<leader>do` | Step out | Shift+F8 |
| `<leader>dO` | Step over | F8 |
| `<leader>dC` | Run to cursor | Alt+F9 |
| `<leader>dt` | Terminate | Cmd+F2 |
| `<leader>du` | Toggle DAP UI | -- |
| `<leader>dr` | Toggle REPL | -- |
| `<leader>de` | Eval expression | Alt+F8 |
| `<leader>dl` | Run last | -- |
| `<leader>da` | Run with args | -- |
| `<leader>dj` | Down (stack frame) | -- |
| `<leader>dk` | Up (stack frame) | -- |
| `<leader>dw` | Widgets | -- |
| `<leader>ds` | Session picker | -- |
| `<leader>dP` | Pause | -- |
| `<leader>dg` | Go to line (no execute) | -- |

---

## Go Debug (Project-Local - aifr-core)

> These keybindings are only available when nvim is opened from the aifr-core project root. They require the project's `.nvim.lua` file to be trusted on first load.

| Keybinding | Action | GoLand/PyCharm Equivalent |
|---|---|---|
| `<leader>dga` | Debug AIFR API | Run Configuration: AIFR API |
| `<leader>dgw` | Debug AIFR Worker | Run Configuration: AIFR Worker |
| `<leader>dgi` | Debug Integration Tests | Run Configuration: Integration Tests |

---

## TODO Comments

| Keybinding | Action |
|------------|--------|
| `]t` | Next TODO comment |
| `[t` | Previous TODO comment |
| `<leader>st` | Search TODOs (picker) |
| `<leader>sT` | Search TODO/FIX/FIXME |
| `<leader>xt` | TODOs in Trouble |
| `<leader>xT` | TODO/FIX/FIXME in Trouble |

---

## Sessions and Projects

| Keybinding | Action |
|------------|--------|
| `<leader>qs` | Restore session |
| `<leader>ql` | Restore last session |
| `<leader>qd` | Don't save current session |
| `<leader>qS` | Select session |

---

## Project (neovim-project)

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `<leader>pp` | Browse/pick project | File > Open Recent Project |
| `<leader>pr` | Load most recent project | -- |
| `<leader>ph` | Project history | File > Recent Projects |
| `<leader>pl` | Load project by path (interactive prompt, tab-completion) | File > Open |

> Plugin: `coffebar/neovim-project` with fzf-lua picker.
> Project roots: `~/Work/{AIFR,Agentic,Infra,MCP,X,CB,Exp,Learning,bifrost}/*`

---

## OpenCode (AI Assistant)

| Keybinding | Action |
|------------|--------|
| `<leader>oa` | Ask opencode |
| `<leader>os` | Execute opencode action |
| `<leader>oo` | Toggle opencode |
| `<leader>ou` | Scroll opencode up |
| `<leader>od` | Scroll opencode down |
| `go` | Add range to opencode (operator) |
| `goo` | Add current line to opencode |

---

## Noice (Notifications)

| Keybinding | Action |
|------------|--------|
| `<leader>sna` | Noice all messages |
| `<leader>snd` | Dismiss all notifications |
| `<leader>snh` | Noice history |
| `<leader>snl` | Noice last message |
| `<leader>snt` | Noice picker |
| `<leader>un` | Dismiss all notifications |
| `<leader>n` | Notification history |

---

## Miscellaneous

| Keybinding | Action |
|------------|--------|
| `<leader>:` | Command history |
| `<leader>?` | Show all keymaps (which-key) |
| `<leader>.` | Toggle scratch buffer |
| `<leader>S` | Select scratch buffer |
| `<leader>uC` | Colorscheme picker |
| `gx` | Open URL/filepath under cursor in browser |
| `[` `<Space>` | Add blank line above |
| `]` `<Space>` | Add blank line below |

---

## Modes

| Key | Action |
|-----|--------|
| `i` | Enter Insert mode (before cursor) |
| `I` | Enter Insert mode (start of line) |
| `a` | Enter Insert mode (after cursor) |
| `A` | Enter Insert mode (end of line) |
| `o` | Open new line below and enter Insert |
| `O` | Open new line above and enter Insert |
| `v` | Enter Visual mode (character) |
| `V` | Enter Visual mode (line) |
| `Ctrl+V` | Enter Visual Block mode (column) |
| `R` | Enter Replace mode (overtype) |
| `Esc` / `Ctrl+[` | Return to Normal mode |

---

## Movement

### By Character / Line

| Key | Action |
|-----|--------|
| `h` | Left |
| `j` | Down |
| `k` | Up |
| `l` | Right |
| `0` | Start of line (column 0) |
| `^` | First non-blank character of line |
| `$` | End of line |
| `g_` | Last non-blank character of line |
| `+` | First non-blank of next line |
| `-` | First non-blank of previous line |

### By Word

| Key | Action |
|-----|--------|
| `w` | Forward to start of next word |
| `W` | Forward to start of next WORD (space-delimited) |
| `b` | Backward to start of word |
| `B` | Backward to start of WORD |
| `e` | Forward to end of word |
| `E` | Forward to end of WORD |
| `ge` | Backward to end of previous word |
| `gE` | Backward to end of previous WORD |

> **word** = letters, digits, underscores. **WORD** = anything separated by whitespace.
> Example: `my-var` is 3 words (`my`, `-`, `var`) but 1 WORD.

### By Paragraph / Sentence / Section

| Key | Action |
|-----|--------|
| `{` | Previous blank line (paragraph up) |
| `}` | Next blank line (paragraph down) |
| `(` | Previous sentence |
| `)` | Next sentence |
| `[[` | Previous section / top-level `{` |
| `]]` | Next section / top-level `{` |

### By Screen

| Key | Action |
|-----|--------|
| `Ctrl+F` | Page down (full screen) |
| `Ctrl+B` | Page up (full screen) |
| `Ctrl+D` | Half page down |
| `Ctrl+U` | Half page up |
| `Ctrl+E` | Scroll down one line (cursor stays) |
| `Ctrl+Y` | Scroll up one line (cursor stays) |
| `zz` | Center current line on screen |
| `zt` | Current line to top of screen |
| `zb` | Current line to bottom of screen |

### By Character (Find on Line)

| Key | Action |
|-----|--------|
| `f<char>` | Jump to next `<char>` on line |
| `F<char>` | Jump to previous `<char>` on line |
| `t<char>` | Jump to just before next `<char>` |
| `T<char>` | Jump to just after previous `<char>` |
| `;` | Repeat last f/F/t/T forward |
| `,` | Repeat last f/F/t/T backward |

### Jump History

| Key | Action |
|-----|--------|
| `Ctrl+O` | Jump back (older position) |
| `Ctrl+I` | Jump forward (newer position) |
| `''` | Jump to position before last jump |
| `` `. `` | Jump to last edit position |
| `g;` | Go to older change position |
| `g,` | Go to newer change position |
| `gi` | Go to last insert position and enter Insert mode |

### Marks

| Key | Action |
|-----|--------|
| `m<a-z>` | Set local mark (buffer-local) |
| `m<A-Z>` | Set global mark (across files) |
| `'<mark>` | Jump to mark (first non-blank of line) |
| `` `<mark> `` | Jump to mark (exact position) |
| `:marks` | List all marks |
| `'0` | Position when last exited Neovim |

---

## Yank (Copy), Delete, Put (Paste)

| Key | Action |
|-----|--------|
| `y` | Yank (copy) -- use with motion |
| `yy` | Yank entire line |
| `Y` | Yank to end of line |
| `yw` | Yank word (from cursor to start of next word) |
| `yiw` | Yank inner word (whole word under cursor) |
| `yi"` | Yank inside double quotes |
| `yi(` | Yank inside parentheses |
| `yi{` | Yank inside braces |
| `y$` | Yank to end of line |
| `y0` | Yank to start of line |
| `yG` | Yank to end of file |
| `ygg` | Yank to start of file |
| `d` | Delete -- use with motion |
| `dd` | Delete entire line |
| `D` | Delete to end of line |
| `dw` | Delete word |
| `diw` | Delete inner word |
| `di"` | Delete inside double quotes |
| `di(` | Delete inside parentheses |
| `di{` | Delete inside braces |
| `d$` | Delete to end of line |
| `d0` | Delete to start of line |
| `dG` | Delete to end of file |
| `dgg` | Delete to start of file |
| `x` | Delete character under cursor |
| `X` | Delete character before cursor (backspace) |
| `p` | Put (paste) after cursor |
| `P` | Put (paste) before cursor |
| `]p` | Paste and auto-indent to match |
| `gp` | Paste and move cursor after pasted text |

> Everything you delete with `d` or `x` goes into a register (clipboard).
> Use `"_d` to delete to the black-hole register (truly delete, no clipboard).

---

## Registers (Clipboards)

| Key | Action |
|-----|--------|
| `"<reg>y` | Yank into register `<reg>` |
| `"<reg>p` | Paste from register `<reg>` |
| `"+y` | Yank to system clipboard |
| `"+p` | Paste from system clipboard |
| `"0p` | Paste last yank (not delete) |
| `"1p` - `"9p` | Paste from delete history |
| `:reg` | Show all registers |

> Common registers: `"` (default), `+` (system clipboard), `0` (last yank),
> `1`-`9` (delete history), `_` (black hole), `/` (last search).

---

## Change (Delete + Enter Insert Mode)

| Key | Action |
|-----|--------|
| `c` | Change -- use with motion |
| `cc` | Change entire line |
| `C` | Change to end of line |
| `cw` | Change word (from cursor) |
| `ciw` | Change inner word |
| `ci"` | Change inside double quotes |
| `ci(` | Change inside parentheses |
| `ci{` | Change inside braces |
| `ct<char>` | Change up to `<char>` |
| `cl` | Substitute character (delete + insert) |

> NOTE: `s` is remapped to Flash in LazyVim. Use `cl` for substitute.

---

## Visual Mode Operations

| Key | Action |
|-----|--------|
| `v` | Start character visual selection |
| `V` | Start line visual selection |
| `Ctrl+V` | Start block (column) visual selection |
| `gv` | Reselect last visual selection |
| `o` | Move to other end of selection |
| `O` | Move to other corner (in block mode) |
| `>` | Indent selection |
| `<` | Unindent selection |
| `=` | Auto-indent selection |
| `~` | Toggle case of selection |
| `U` | Uppercase selection |
| `u` | Lowercase selection |
| `y` | Yank selection |
| `d` | Delete selection |
| `c` | Change selection |
| `J` | Join selected lines |
| `:` | Enter command mode for selection |
| `I` | Insert at start of each line (block mode) |
| `A` | Append at end of each line (block mode) |

---

## Text Objects (Use with d, c, y, v)

> Format: `[operator][i/a][object]` -- `i` = inner (inside), `a` = around (including delimiters)

### Word / Sentence / Paragraph

| Object | Inner (`i`) | Around (`a`) |
|--------|-------------|--------------|
| Word | `diw` -- delete word | `daw` -- delete word + surrounding space |
| WORD | `diW` -- delete WORD | `daW` -- delete WORD + space |
| Sentence | `dis` -- delete sentence | `das` -- delete sentence + space |
| Paragraph | `dip` -- delete paragraph | `dap` -- delete paragraph + blank lines |

### Delimiters and Brackets

| Object | Inner (`i`) | Around (`a`) |
|--------|-------------|--------------|
| `"` double quotes | `ci"` -- change inside `"..."` | `ca"` -- change including `"` |
| `'` single quotes | `ci'` -- change inside `'...'` | `ca'` -- change including `'` |
| `` ` `` backticks | `` ci` `` -- change inside | `` ca` `` -- change including |
| `()` parentheses | `di)` or `dib` | `da)` or `dab` |
| `[]` brackets | `di]` | `da]` |
| `{}` braces | `di}` or `diB` | `da}` or `daB` |
| `<>` angle brackets | `di>` | `da>` |
| HTML tag | `dit` -- inside tag | `dat` -- including tag |

### Treesitter Text Objects (from nvim-treesitter-textobjects)

| Object | Inner (`i`) | Around (`a`) |
|--------|-------------|--------------|
| Function | `dif` -- delete function body | `daf` -- delete entire function |
| Class | `dic` -- delete class body | `dac` -- delete entire class |
| Argument | `dia` -- delete argument | `daa` -- delete argument + comma |

### Common Text Object Combos

| Command | What It Does |
|---------|--------------|
| `ciw` | Change the word under cursor |
| `ci"` | Change text inside double quotes |
| `ci(` | Change text inside parentheses |
| `ci{` | Change text inside braces |
| `da"` | Delete text including double quotes |
| `dap` | Delete entire paragraph |
| `vif` | Visually select inside function |
| `yaf` | Yank entire function |
| `>ip` | Indent paragraph |
| `gUiw` | Uppercase word under cursor |
| `guiw` | Lowercase word under cursor |

---

## Indent and Format

| Key | Action |
|-----|--------|
| `>>` | Indent line |
| `<<` | Unindent line |
| `>` + motion | Indent (e.g., `>ip` indent paragraph) |
| `<` + motion | Unindent |
| `==` | Auto-indent current line |
| `=` + motion | Auto-indent (e.g., `=ip` indent paragraph) |
| `gg=G` | Auto-indent entire file |
| `gq` + motion | Format/rewrap text (e.g., `gqip` rewrap paragraph) |
| `gw` + motion | Format text (keep cursor position) |
| `J` | Join current line with next (add space) |
| `gJ` | Join lines without adding space |

---

## Undo / Redo

| Key | Action |
|-----|--------|
| `u` | Undo |
| `Ctrl+R` | Redo |
| `U` | Undo all changes on current line |
| `.` | Repeat last change |
| `@:` | Repeat last command-line command |

---

## Insert Mode Shortcuts

> These work while you are in Insert mode (after pressing `i`, `a`, `o`, etc.)

| Key | Action |
|-----|--------|
| `Ctrl+H` | Delete character before cursor (backspace) |
| `Ctrl+W` | Delete word before cursor |
| `Ctrl+U` | Delete to start of line |
| `Ctrl+T` | Indent current line |
| `Ctrl+D` | Unindent current line |
| `Ctrl+N` | Autocomplete next match |
| `Ctrl+P` | Autocomplete previous match |
| `Ctrl+R "` | Paste from default register |
| `Ctrl+R +` | Paste from system clipboard |
| `Ctrl+R 0` | Paste last yank |
| `Ctrl+O` | Execute one Normal mode command, then return to Insert |
| `Ctrl+A` | Insert last inserted text |
| `Esc` / `Ctrl+[` | Exit Insert mode |

---

## Command-Line Mode Essentials

| Command | Action |
|---------|--------|
| `:w` | Save file |
| `:q` | Quit (fails if unsaved) |
| `:wq` or `:x` | Save and quit |
| `:q!` | Quit without saving |
| `:qa` | Quit all windows |
| `:wa` | Save all buffers |
| `:wqa` | Save all and quit |
| `:e <file>` | Open file |
| `:e!` | Reload file from disk (discard changes) |
| `:bn` / `:bp` | Next / previous buffer |
| `:bd` | Close (delete) buffer |
| `:<n>` | Go to line number |
| `:noh` | Clear search highlight |
| `:set wrap` | Enable line wrapping |
| `:set nowrap` | Disable line wrapping |
| `:set number` | Show line numbers |
| `:set relativenumber` | Show relative line numbers |
| `:sort` | Sort selected lines |
| `:sort!` | Reverse sort |
| `:sort u` | Sort and remove duplicates |

---

## Macros

| Key | Action |
|-----|--------|
| `q<letter>` | Start recording macro into register `<letter>` |
| `q` | Stop recording |
| `@<letter>` | Play macro from register `<letter>` |
| `@@` | Replay last macro |
| `5@a` | Play macro `a` five times |

---

## Surround (mini.pairs)

> LazyVim includes mini.pairs for auto-closing brackets.

| Key | Action |
|-----|--------|
| Auto-close | Type `(`, `[`, `{`, `"`, `'` and closing pair is inserted |
| `gsa` | Add surrounding (e.g., `gsaiw"` surrounds word with `"`) |
| `gsd` | Delete surrounding (e.g., `gsd"` deletes surrounding `"`) |
| `gsr` | Replace surrounding (e.g., `gsr"'` changes `"` to `'`) |

---

## Repeat and Counts

| Key | Action |
|-----|--------|
| `.` | Repeat last change |
| `5j` | Move 5 lines down |
| `3dd` | Delete 3 lines |
| `10w` | Move 10 words forward |
| `2yy` | Yank 2 lines |
| `3p` | Paste 3 times |
| `5>>` | Indent 5 lines |

> Almost every command can be prefixed with a count number.

---

## Quick Lookup Table (GoLand/PyCharm -> LazyVim)

| GoLand/PyCharm | LazyVim |
|----------------|---------|
| Cmd+Shift+O (find file) | `<leader>ff` |
| Cmd+Shift+F (find in path) | `<leader>/` or `<leader>sg` |
| Cmd+Shift+R (replace in path) | `<leader>sr` |
| Cmd+B (go to definition) | `gd` |
| Cmd+Alt+B (implementations) | `gri` |
| Alt+F7 (find usages) | `grr` |
| Shift+F6 (rename) | `grn` |
| Alt+Enter (quick fix) | `gra` |
| Cmd+F12 (file structure) | `<leader>ss` |
| Cmd+Alt+Shift+N (symbol) | `<leader>sS` |
| F2 (next error) | `]d` |
| Shift+F2 (prev error) | `[d` |
| Cmd+/ (comment) | `gcc` |
| Cmd+L (go to line) | `:<number>` or `<number>G` |
| Cmd+E (recent files) | `<leader>fr` |
| Ctrl+Tab (switch tab) | `<leader>,` |
| Cmd+1 (project panel) | `<leader>e` |
| Alt+6 (problems panel) | `<leader>xx` |
| Cmd+F8 (breakpoint) | `<leader>db` |
| F9 (debug) | `<leader>dc` |
| F7 (step into) | `<leader>di` |
| F8 (step over) | `<leader>dO` |
| Shift+F8 (step out) | `<leader>do` |
| Cmd+F2 (stop debug) | `<leader>dt` |
| Run Configuration (Go) | `<leader>dga` / `<leader>dgw` / `<leader>dgi` |
| Ctrl+W (extend selection) | `gnn` then `grn` |
| Ctrl+Shift+W (shrink) | `grm` |
| File > Open Recent Project | `<leader>pp` |
| File > Recent Projects | `<leader>ph` |
| Cmd+. (fold toggle) | `za` |
| Cmd+Shift++ (unfold all) | `zR` |
| Cmd+Shift+- (fold all) | `zM` |
| Ctrl+Q (quick doc) | `K` |

---

## Illuminate (Word Highlighting)

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `]]` | Next reference (under cursor) | Ctrl+G (next occurrence) |
| `[[` | Previous reference (under cursor) | -- |
| `<leader>ux` | Toggle illuminate | -- |

---

## Indent Blankline (Indent Guides)

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `<leader>ug` | Toggle indentation guides | Settings > Editor > Indent |

---

## Mini Surround

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `gsa` | Add surrounding (normal/visual) | -- |
| `gsd` | Delete surrounding | -- |
| `gsr` | Replace surrounding | -- |
| `gsf` | Find surrounding (right) | -- |
| `gsF` | Find surrounding (left) | -- |
| `gsh` | Highlight surrounding | -- |
| `gsn` | Update `n_lines` | -- |

> In visual mode, select text then `gsa` + char to wrap. In normal mode, `gsa` then motion + char.
> Example: `gsaiw"` = surround inner word with quotes. `gsd"` = delete surrounding quotes.

---

## Mini Animate

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `<leader>ua` | Toggle animations | Settings > Smooth scrolling |

> Smooth scroll, cursor movement, and window resize animations. Disabled for mouse scroll.

---

## Aerial (Symbol Browser)

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `<leader>cs` | Toggle aerial (symbols sidebar) | Cmd+F12 (File Structure) |
| `<leader>ss` | Search symbols (Aerial via picker) | Cmd+Alt+Shift+N |

> Shows a sidebar with functions, classes, methods etc. Navigate with `j`/`k`, press Enter to jump.

---

## Refactoring

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `<leader>rs` | Refactor picker (all refactors) | Ctrl+T (Refactor This) |
| `<leader>ri` | Inline variable | Ctrl+Alt+N |
| `<leader>rf` | Extract function | Ctrl+Alt+M |
| `<leader>rF` | Extract function to file | -- |
| `<leader>rx` | Extract variable | Ctrl+Alt+V |
| `<leader>rb` | Extract block | -- |
| `<leader>rP` | Debug print (above) | -- |
| `<leader>rp` | Debug print variable | -- |
| `<leader>rc` | Debug cleanup (remove prints) | -- |

> Works in both normal and visual mode. Select code first for extract operations.

---

## Testing (Neotest)

| Keybinding | Action | JetBrains Equivalent |
|------------|--------|----------------------|
| `<leader>tr` | Run nearest test | Ctrl+Shift+R (run at cursor) |
| `<leader>tt` | Run file tests | -- |
| `<leader>tT` | Run all tests | Ctrl+Shift+R (all) |
| `<leader>tl` | Run last test | -- |
| `<leader>ts` | Toggle test summary | -- |
| `<leader>to` | Show test output | -- |
| `<leader>tO` | Toggle output panel | -- |
| `<leader>tS` | Stop running test | -- |
| `<leader>tw` | Toggle watch mode | -- |
| `<leader>ta` | Attach to test | -- |
| `<leader>td` | Debug nearest test | Shift+F9 (debug test) |

> Neotest uses adapters per language: `neotest-golang` for Go, `neotest-python` for Python.
> Tests are discovered automatically from test files.

---

## Navic (Breadcrumbs)

> No keybindings -- navic shows a breadcrumb trail in the winbar/statusline automatically.
> Shows: File > Module > Class > Function as you navigate code. Powered by LSP.

---

## Language Extras Reference

| Extra | LSP | Linter | Formatter | Treesitter |
|-------|-----|--------|-----------|------------|
| `lang.go` | gopls | golangci-lint | gofumpt, goimports | go |
| `lang.python` | pyright | ruff | ruff | python |
| `lang.json` | json-lsp | -- | -- | json, json5 |
| `lang.yaml` | yaml-ls | -- | -- | yaml |
| `lang.docker` | docker-lsp, compose-lsp | hadolint | -- | dockerfile |
| `lang.terraform` | terraform-ls | tflint | -- | terraform, hcl |
| `lang.helm` | helm-ls | -- | -- | helm |
| `lang.markdown` | marksman | markdownlint | -- | markdown |
| `lang.git` | -- | -- | -- | gitcommit, gitignore, etc. |
