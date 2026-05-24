# NamiConfig — Neovim Configuration Wiki

> A modular, registry-driven Neovim config built on `lazy.nvim`. Designed for
> web, Python, and full-stack development — extensible to Go, Rust, SQL, and beyond
> via opt-in extras.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Directory Structure](#directory-structure)
3. [settings.lua Reference](#settingslua-reference)
4. [Extras — Opt-in Language Packs](#extras--opt-in-language-packs)
5. [Language Registry](#language-registry)
6. [Plugins Reference](#plugins-reference)
   - [UI](#ui)
   - [Editor](#editor)
   - [LSP & Intelligence](#lsp--intelligence)
   - [Formatting & Linting](#formatting--linting)
   - [Git](#git)
   - [AI](#ai)
   - [Debugging (DAP)](#debugging-dap)
7. [Keymaps Cheat Sheet](#keymaps-cheat-sheet)
8. [Project-Local Config (neoconf)](#project-local-config-neoconf)
9. [How to Add a New Language](#how-to-add-a-new-language)
10. [How to Add a New Plugin](#how-to-add-a-new-plugin)
11. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

```
init.lua
├── core/options.lua       → Neovim option settings (reads from settings.lua)
├── core/keymaps.lua       → All global keymaps
├── core/autocmds.lua      → Autocommands (yank highlight, cursor restore, etc.)
├── core/lang_registry.lua → 🗂 Single source of truth for all language tooling
├── core/theme_registry.lua→ 🎨 Centralized list of themes (syncs w/ Ghostty)
└── plugins/               → lazy.nvim plugin specs (auto-discovered)
    ├── ui/                → Theme, statusline, bufferline, telescope, terminal...
    ├── editor/            → Treesitter, completion, autopairs, indent, neoconf
    ├── lsp/               → mason, lspconfig, DAP
    ├── formatting/        → conform.nvim
    ├── linting/           → nvim-lint
    ├── git/               → gitsigns, lazygit, diffview
    ├── ai/                → supermaven
    ├── lang/              → Django HTML integration
    └── extras/            → Opt-in language & feature packs
        ├── lang/go.lua
        ├── lang/rust.lua
        ├── lang/sql.lua
        └── testing/neotest.lua
```

### Key Architectural Principles

| Principle | Implementation |
|-----------|---------------|
| **Single source of truth** | `lang_registry.lua` drives Mason, LSP, conform, and nvim-lint |
| **Zero-friction new languages** | Add to `lang_registry.lua` → everything auto-wires |
| **Opt-in extras** | Heavy packs (Go, Rust, testing) only load if enabled in `settings.lua` |
| **User-friendly config** | `settings.lua` exposes all common toggles — no Lua needed |
| **Performance** | All plugins lazy-loaded by default; 40+ built-in plugins disabled |
| **Project-local overrides** | `.neoconf.json` per project root for per-project LSP settings |

---

## Directory Structure

```
~/.config/nvim/
├── init.lua                          # Entry point — bootstraps lazy.nvim + extras
├── lazy-lock.json                    # Plugin version lockfile
├── lua/
│   ├── settings.lua                  # ← Your main config file. Edit this!
│   ├── core/
│   │   ├── options.lua               # vim.opt settings (reads settings.lua)
│   │   ├── keymaps.lua               # Global keybindings
│   │   ├── autocmds.lua              # Autocommands
│   │   ├── lang_registry.lua         # Language → tools mapping
│   │   └── theme_registry.lua        # Centralized theme definitions
│   └── plugins/
│       ├── init.lua                  # Master plugin import list
│       ├── ai/supermaven.lua
│       ├── editor/
│       │   ├── autopairs.lua
│       │   ├── cmp.lua
│       │   ├── comment.lua
│       │   ├── indent.lua
│       │   ├── neoconf.lua           # Project-local config
│       │   ├── treesitter.lua
│       │   └── utils.lua
│       ├── extras/
│       │   ├── lang/go.lua
│       │   ├── lang/rust.lua
│       │   ├── lang/sql.lua
│       │   └── testing/neotest.lua
│       ├── formatting/conform.lua
│       ├── git/
│       │   ├── diffview.lua
│       │   ├── gitsigns.lua
│       │   └── lazygit.lua
│       ├── lang/django.lua
│       ├── linting/lint.lua
│       ├── lsp/
│       │   ├── dap.lua
│       │   ├── lspconfig.lua
│       │   └── mason.lua
│       └── ui/
│           ├── alpha.lua
│           ├── bufferline.lua
│           ├── filetree.lua
│           ├── misc.lua
│           ├── noice.lua
│           ├── statusline.lua
│           ├── telescope.lua
│           ├── terminal.lua
│           └── theme.lua
```

---

## settings.lua Reference

`lua/settings.lua` is the **only file you need to edit** for common customizations.

### UI & Aesthetics

| Setting | Default | Description |
|---------|---------|-------------|
| `theme` | `"catppuccin"` | Active colorscheme |
| `background` | `"solid"` | `"transparent"` or `"solid"` |
| `hide_empty_tabline` | `true` | Hide buffer bar when only 1 file is open |
| `show_indent_guides` | `true` | Vertical indentation guide lines |
| `smooth_scroll` | `true` | Smooth scrolling animations |
| `dim_inactive` | `false` | Dim unfocused windows |

**Available themes:**
`catppuccin` · `onedark` · `tokyonight` · `gruvbox` · `rose-pine` · `nord` · `dracula` · `kanagawa` · `nightfox` · `sonokai` · `material` · `oxocarbon` · `monokai` · `everforest` · `gruvbox-material` · `poimandres` · `github_dark`

### Editor Behavior

| Setting | Default | Description |
|---------|---------|-------------|
| `highlight_current_line` | `true` | Cursorline highlight |
| `show_line_numbers` | `true` | Line numbers in gutter |
| `relative_line_numbers` | `false` | Relative line numbers (`5j`, `4k`) |
| `format_on_save` | `false` | Auto-format on save via conform.nvim |
| `tab_size` | `2` | Spaces per indent level |
| `mouse_support` | `true` | Enable mouse in all modes |
| `wrap_lines` | `true` | Wrap long lines |
| `scrolloff` | `8` | Lines kept visible above/below cursor |
| `auto_save` | `false` | Auto-save on focus loss |
| `blink_cursor` | `true` | Blinking cursor |
| `color_column` | `"80"` | Vertical ruler (`""` to disable) |
| `split_below` | `true` | Horizontal splits open below |
| `split_right` | `true` | Vertical splits open to the right |
| `ignore_case_search` | `true` | Case-insensitive search (capital = case-sensitive) |

### Code Intelligence

| Setting | Default | Description |
|---------|---------|-------------|
| `enable_inlay_hints` | `true` | Inline type/parameter hints from LSP |
| `show_inline_errors` | `true` | Inline diagnostics at end of line |

### File Explorer

| Setting | Default | Description |
|---------|---------|-------------|
| `show_hidden_files` | `true` | Show dotfiles in nvim-tree |

### Linting

| Setting | Default | Description |
|---------|---------|-------------|
| `enable_linting` | `true` | Enable async linting via nvim-lint |

### Project-Local Config

| Setting | Default | Description |
|---------|---------|-------------|
| `enable_project_config` | `true` | Load `.neoconf.json` from project roots |

### Extras

```lua
extras = {
  -- "plugins.extras.lang.go",           -- Go (gopls, delve, go.nvim)
  -- "plugins.extras.lang.rust",         -- Rust (rustaceanvim, codelldb)
  -- "plugins.extras.lang.sql",          -- SQL (dadbod, DB UI)
  -- "plugins.extras.testing.neotest",   -- Tests (pytest, jest, vitest)
},
```

Uncomment any line to activate that feature pack. Plugins, LSPs, formatters, linters, and debuggers all install automatically.

### Custom Tools

If you just want to install a server or formatter without building a full language registry entry, you can add them to these lists in `settings.lua`:

```lua
  lsp_servers = {
    -- "clangd",
    -- "tailwindcss",
  },
  mason_tools = {
    -- "prettier",
    -- "stylua",
  },
```
Servers added to `lsp_servers` will be installed by Mason and automatically booted by lspconfig.

---

## Extras — Opt-in Language Packs

Extras live in `lua/plugins/extras/`. They are **not loaded by default**.

### `plugins.extras.lang.go`

| Component | Tool |
|-----------|------|
| LSP | gopls |
| Tooling | go.nvim (fill struct, import mgmt, run/test) |
| Debugger | nvim-dap-go (Delve) |
| Treesitter | go, gomod, gowork, gosum |

Extra keymaps (Go files):

| Key | Action |
|-----|--------|
| `<leader>gr` | GoRun |
| `<leader>gt` | GoTest |
| `<leader>gi` | GoImport |
| `<leader>gfs` | GoFillStruct |

### `plugins.extras.lang.rust`

| Component | Tool |
|-----------|------|
| LSP | rust-analyzer (via rustaceanvim) |
| Debugger | codelldb |
| Treesitter | rust, toml |

Extra keymaps (Rust files):

| Key | Action |
|-----|--------|
| `<leader>rr` | Rust Runnables |
| `<leader>rt` | Rust Testables |
| `<leader>re` | Expand Macro |
| `<leader>rc` | Open Cargo.toml |

### `plugins.extras.lang.sql`

| Component | Tool |
|-----------|------|
| DB engine | vim-dadbod (Postgres, MySQL, SQLite, Redis…) |
| DB UI | vim-dadbod-ui |
| Completion | vim-dadbod-completion |
| Treesitter | sql |

| Key | Action |
|-----|--------|
| `<leader>Du` | Toggle DB UI |
| `<leader>Da` | Add DB connection |
| `<leader>Df` | Find DB buffer |

### `plugins.extras.testing.neotest`

| Component | Tool |
|-----------|------|
| Runner | neotest |
| Python | neotest-python (pytest, auto-detects venv) |
| JavaScript | neotest-jest |
| TypeScript | neotest-vitest |

| Key | Action |
|-----|--------|
| `<leader>Tr` | Run nearest test |
| `<leader>Tf` | Run all tests in file |
| `<leader>Ta` | Run full test suite |
| `<leader>Td` | Debug nearest test (requires DAP) |
| `<leader>Ts` | Stop tests |
| `<leader>To` | Open test output |
| `<leader>TS` | Toggle test summary panel |
| `<leader>Tw` | Watch file for changes |

---

## Language Registry

`lua/core/lang_registry.lua` is the **single source of truth** for all language tooling.

### How It Works

Each entry maps a filetype to its tools:

```lua
python = {
  lsp        = "pyright",            -- lspconfig server name
  mason      = { "black", "ruff" },  -- extra Mason packages
  formatters = { "black" },          -- conform.nvim formatters
  linters    = { "ruff" },           -- nvim-lint linters
  lsp_opts   = { ... },              -- merged into lspconfig.setup()
},
```

Adding this entry automatically:
1. Tells `mason-lspconfig` to install `pyright`
2. Tells `mason-tool-installer` to install `black` and `ruff`
3. Boots `pyright` via `lspconfig` with `on_attach` and capabilities
4. Configures `conform.nvim` to format Python files with `black`
5. Configures `nvim-lint` to lint Python files with `ruff`

### Supported Languages

| Language | LSP | Formatter | Linter |
|----------|-----|-----------|--------|
| HTML | html | prettier | — |
| CSS/SCSS | cssls | prettier | stylelint |
| JavaScript | ts_ls | prettier | eslint_d |
| TypeScript | ts_ls | prettier | eslint_d |
| JSX / TSX | ts_ls | prettier | eslint_d |
| JSON | jsonls | prettier | — |
| YAML | yamlls | prettier | — |
| Vue | volar | prettier | eslint_d |
| Lua | lua_ls | stylua | luacheck |
| Bash | bashls | shfmt | shellcheck |
| TOML | taplo | — | — |
| Python | pyright | black | ruff |
| Markdown | marksman | prettier | markdownlint |
| Dockerfile | dockerls | — | hadolint |

### Extra Servers (Not in Registry)

These servers are set up directly in `lspconfig.lua` because they don't map 1:1 to a single filetype:

- `tailwindcss` — CSS utility classes in HTML/JSX/TSX
- `eslint` — ESLint language server
- `unocss` — UnoCSS support
- `sqls` — SQL server
- `texlab` — LaTeX
- `gopls` — Go (also activated by the Go extra)
- `docker_compose_language_service` — Docker Compose
- `emmet_language_server` — Emmet expansion
- `volar` — Vue 3

---

## Plugins Reference

### UI

#### Dashboard (`alpha-nvim`)
- **NamiConfig** ASCII art header on startup
- Quick access: Find file · New file · Recent files · Settings · Theme · Quit

#### Theme System
- `<leader>th` — Interactive picker, hot-reloads theme and **syncs Ghostty terminal** automatically
- All themes are dynamically loaded from `lua/core/theme_registry.lua`
- Only contains 100% native 1-to-1 matching profiles for Ghostty terminal
- Theme saved permanently to `settings.lua`

#### Statusline (`lualine`)
- Global single bar (VS Code style, no powerline arrows)
- Left: Mode · Git branch · LSP error/warn counts
- Center: Filename (relative path) + modified indicator
- Right: Encoding · File format · Filetype · `Ln X, Col Y`

#### Buffer Tabs (`bufferline.nvim`)
- LSP diagnostic counts shown per tab
- Hides when `hide_empty_tabline = true` and only 1 buffer is open
- Close with `<leader>x` (preserves window layout)

#### File Explorer (`nvim-tree`)
- `<C-n>` or `<leader>e` to toggle
- Shows hidden files, respects `.gitignore`

#### Fuzzy Finder (`telescope.nvim`)
- fzf-native backend for ultra-fast sorting
- `telescope-ui-select` patches `vim.ui.select` globally (used by LSP code actions, theme picker)
- `<C-j>` / `<C-k>` to navigate results, `<Esc>` to close

#### Notifications & Command Line (`noice.nvim`)
- Command line → centered floating popup
- LSP progress → mini notification
- Noise filtered: written file messages, search counts, lazy.nvim reload spam, etc.
- Long output → split window instead of popup
- `<leader>cn` — dismiss current notification

#### Terminal (`toggleterm.nvim`)
- Three layouts: floating (85% screen), horizontal (15 lines), vertical (40% width)
- Persists between toggles, auto-enters insert mode on open

| Key | Action |
|-----|--------|
| `<A-i>` | Float terminal |
| `<A-h>` | Horizontal terminal |
| `<A-v>` | Vertical terminal |
| `<Esc><Esc>` | Exit terminal insert mode |
| `q` | Close (normal mode inside terminal) |

#### Color Preview (`nvim-highlight-colors`)
- Inline colored squares for `#hex`, `rgb()`, `hsl()`, Tailwind classes
- Also shown in completion popup for color values

#### Markdown Preview (`peek.nvim`)
- `<leader>op` — Toggle live browser preview

#### Code Screenshot (`nvim-silicon`)
- `<leader>sc` (visual) — Render selection as styled image → clipboard + `~/Pictures/Screenshots/code.png`

#### Discord Presence (`neocord`)
- Shows current file and project in Discord status automatically

#### Which-Key (`which-key.nvim`)
- Press `<leader>` and pause — popup shows all keymaps with group icons

---

### Editor

#### Completion (`nvim-cmp`)

Sources (priority order): LSP → LuaSnip → Neovim Lua API → Buffer → Path

| Key | Action |
|-----|--------|
| `<Tab>` | Accept AI suggestion / Next item / Expand snippet |
| `<S-Tab>` | Previous item / Jump back in snippet |
| `<CR>` | Confirm selection |
| `<C-Space>` | Force open completion menu |
| `<C-e>` | Abort |
| `<C-b>` / `<C-f>` | Scroll documentation window |

#### Snippets (`LuaSnip` + `friendly-snippets`)
- VS Code-compatible format with hundreds of built-in snippets

#### Treesitter
- Syntax highlighting + smart indentation
- Parsers: vim, lua, html, css, js, ts, tsx, json, python, htmldjango, markdown, bash, yaml, toml, dockerfile, vue
- Extra parsers added by language extras (go, rust, sql)

#### Autopairs
- Auto-closes `()`, `[]`, `{}`, `""`, `''`, `` ` ``
- Smart: doesn't double-close

#### Comments (`Comment.nvim`)

| Key | Mode | Action |
|-----|------|--------|
| `gcc` | Normal | Toggle line comment |
| `gc` | Visual | Toggle block comment |
| `<leader>/` | Normal/Visual | Toggle comment |

#### Auto-Save
- `auto_save = true` in settings.lua
- Triggers on: `BufLeave`, `FocusLost`, `InsertLeave`, `TextChanged`
- 1-second debounce
- `:ASToggle` to toggle per-session

#### Python Venv (`venv-selector.nvim`)
- `<leader>vs` — pick active virtualenv, notifies pyright automatically

---

### LSP & Intelligence

#### Mason (Tool Installer)

| Command | Action |
|---------|--------|
| `:Mason` | Open Mason UI |
| `:MasonInstall <name>` | Install a tool |
| `:MasonUpdate` | Update all installed tools |

All tools required by the lang registry are auto-installed on startup via `mason-tool-installer`.

#### LSP (`lspconfig`)

All servers boot from the lang registry loop. Diagnostic config: rounded floats, severity-sorted, no updates during insert.

**LSP Keymaps** (available when LSP is attached):

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | List references |
| `K` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>ra` | Rename symbol |
| `<leader>fm` | Format buffer (async) |
| `<leader>ds` | Diagnostics list (Telescope) |
| `[d` / `]d` | Prev / Next diagnostic |

**Diagnostic Icons:** Error: ` ` · Warn: ` ` · Hint: `󰝶 ` · Info: ` `

---

### Formatting & Linting

#### Formatting (`conform.nvim`)

- Reads `formatters_by_ft` from lang registry
- `<leader>cf` — format current buffer (always works)
- `format_on_save` toggle in `settings.lua`
- `:ConformInfo` — inspect active formatters

#### Linting (`nvim-lint`)

- Reads `linters_by_ft` from lang registry
- Runs on: buffer read, write, insert leave
- Skips special buffers

| Key | Action |
|-----|--------|
| `<leader>cl` | Lint now |
| `<leader>tl` | Toggle linting (session-only) |

---

### Git

#### Gitsigns

Sign column indicators: `│` added/changed · `` deleted · `‾` topdelete · `~` changedelete · `┆` untracked

| Key | Action |
|-----|--------|
| `]h` / `[h` | Next / Prev hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` | Diff this |
| `<leader>hp` | Preview hunk |

#### Git Blame (`git-blame.nvim`)
- End-of-line virtual text: `<summary> • <date> • <author>`
- `:GitBlameToggle` to toggle

#### LazyGit

| Key | Action |
|-----|--------|
| `<leader>gg` | Open LazyGit |
| `<leader>gf` | LazyGit current file log |

#### Diffview

| Key | Action |
|-----|--------|
| `<leader>gd` | Toggle Diffview |

- 2-panel horizontal diff · 3-panel layout for merge conflicts

---

### AI

#### Supermaven
- AI ghost-text inline completions
- `<Tab>` to accept (integrated into nvim-cmp)
- `:SupermavenUseFree` to activate free tier

---

### Debugging (DAP)

#### Core
- `nvim-dap` + `nvim-dap-ui` — UI opens/closes automatically with debug sessions

#### Python
- Adapter: `debugpy` via Mason
- Path: `~/.local/share/nvim/mason/packages/debugpy/venv/bin/python`

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / Start |
| `<leader>dso` | Step over |
| `<leader>dsi` | Step into |
| `<leader>dt` | Terminate |

#### Go (extra) — Delve via `nvim-dap-go`
#### Rust (extra) — codelldb via `nvim-dap`

---

## Keymaps Cheat Sheet

### General

| Key | Mode | Action |
|-----|------|--------|
| `jk` | Insert | Escape to normal mode |
| `;` | Normal | Command mode |
| `<Esc>` | Normal | Clear search highlights |
| `<C-s>` | Normal | Save file |
| `<C-q>` | Normal | Quit |

### Navigation

| Key | Mode | Action |
|-----|------|--------|
| `<C-h/j/k/l>` | Normal | Move between windows |
| `<C-h/j/k/l>` | Terminal | Move out of terminal |
| `<Tab>` | Normal | Next buffer |
| `<S-Tab>` | Normal | Previous buffer |
| `<leader>x` | Normal | Close buffer |
| `<A-j/k>` | N/I/V | Move line / selection |
| `<` / `>` | Visual | Indent (stays in visual) |
| `<C-h/j/k/l>` | Insert | Move cursor |

### Find

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fw` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Help tags |
| `<leader>fo` | Recent files |
| `<leader>fz` | Fuzzy in buffer |
| `<leader>ma` | Find marks |

### Git

| Key | Action |
|-----|--------|
| `<leader>gg` | LazyGit |
| `<leader>gf` | LazyGit current file |
| `<leader>gd` | Toggle Diffview |
| `<leader>gt` | Git status (Telescope) |
| `<leader>gc` | Git commits (Telescope) |
| `]h` / `[h` | Next / Prev hunk |
| `<leader>hs/hr/hb/hd/hp` | Stage/Reset/Blame/Diff/Preview hunk |

### Code / LSP

| Key | Action |
|-----|--------|
| `gd/gD/gi/gr` | Definition / Declaration / Implementation / References |
| `K` | Hover docs |
| `<leader>ca` | Code action |
| `<leader>ra` | Rename symbol |
| `<leader>fm` | LSP format |
| `<leader>cf` | Conform format |
| `<leader>cl` | Lint now |
| `<leader>ds` | Diagnostics list |
| `[d` / `]d` | Prev / Next diagnostic |

### Toggles

| Key | Action |
|-----|--------|
| `<leader>th` | Theme picker |
| `<leader>tl` | Toggle linting |
| `<leader>n` | Toggle line numbers |
| `<leader>rn` | Toggle relative numbers |
| `<leader>cn` | Dismiss notification |

### Debugging

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | DAP continue |
| `<leader>dso` | Step over |
| `<leader>dsi` | Step into |
| `<leader>dt` | Terminate |

### Misc

| Key | Mode | Action |
|-----|------|--------|
| `<C-n>` / `<leader>e` | Normal | Toggle file tree |
| `<leader>vs` | Normal | Select Python venv |
| `<leader>op` | Normal | Toggle Markdown preview |
| `<leader>sc` | Visual | Screenshot code |
| `<leader>/` | Normal/Visual | Toggle comment |

> **Note:** Arrow keys are **intentionally disabled** in normal and insert modes
> to enforce Vim motion habits. Use `h/j/k/l` instead.

---

## Project-Local Config (neoconf)

Drop a `.neoconf.json` in any project root to override LSP settings for that project only.

### Example: Strict Python type checking

```json
{
  "pyright": {
    "python.analysis.typeCheckingMode": "strict",
    "python.analysis.autoImportCompletions": true
  }
}
```

### Example: Suppress Lua diagnostics

```json
{
  "lua_ls": {
    "Lua.diagnostics.disable": ["missing-fields", "undefined-global"]
  }
}
```

### VSCode import

If a project has `.vscode/settings.json`, neoconf imports compatible settings automatically.

### Toggle

```lua
-- settings.lua
enable_project_config = false
```

---

## How to Add a New Language

**Step 1:** Open `lua/core/lang_registry.lua` and add an entry:

```lua
kotlin = {
  lsp        = "kotlin_language_server",
  mason      = { "ktlint" },
  formatters = { "ktlint" },
  linters    = { "ktlint" },
},
```

**Step 2:** That's it. On next Neovim startup, Mason installs the tools, lspconfig boots the server, conform formats, and nvim-lint lints automatically.

**For heavy language support** (debugger, test runner, special tooling), create an extras file:

1. Create `lua/plugins/extras/lang/kotlin.lua`
2. Optionally enable it in `settings.lua`:
   ```lua
   extras = { "plugins.extras.lang.kotlin" }
   ```

---

## How to Add a New Theme

**Step 1:** Open `lua/core/theme_registry.lua` and add an entry:

```lua
  {
    id = "newtheme",
    plugin = "author/newtheme.nvim",
    icon = "󰏘 ",
    ghostty = "Ghostty Profile Name",
    setup = function(transparent)
      -- Optional setup logic
    end
  },
```

**Step 2:** That's it! 
- The theme is automatically installed by `lazy.nvim`.
- The theme instantly appears in the `<leader>th` Theme Switcher.
- It will automatically sync to your Ghostty terminal when selected.

---

## How to Add a New Plugin

### Option A — Add to existing category

Open a file like `lua/plugins/editor/utils.lua` and append:

```lua
{
  "author/plugin-name",
  event = "VeryLazy",
  opts  = { key = "value" },
},
```

### Option B — New file

1. Create `lua/plugins/<category>/myplugin.lua`
2. Add `{ import = "plugins.<category>.myplugin" }` to `lua/plugins/init.lua`

### Option C — Opt-in extra

1. Create `lua/plugins/extras/<area>/myplugin.lua`
2. Enable in `settings.lua`:
   ```lua
   extras = { "plugins.extras.area.myplugin" }
   ```

---

## Troubleshooting

### Neovim won't start

```bash
nvim --headless "+Lazy sync" +qa
```

Run `:Lazy` to see which plugins failed and why.

### LSP not starting

1. `:LspInfo` — shows attached servers and errors
2. `:Mason` — verify the server is installed
3. `:lua print(vim.bo.filetype)` — confirm filetype is detected correctly

### Formatter not running

1. `:ConformInfo` — shows active formatters for current buffer
2. Verify `format_on_save = true` in `settings.lua`, or use `<leader>cf`
3. Check the formatter binary is installed via `:Mason`

### Linter not showing diagnostics

1. Verify `enable_linting = true` in `settings.lua`
2. `:lua print(vim.inspect(require("lint").linters_by_ft))` — inspect active linters
3. Trigger manually: `<leader>cl`
4. Ensure the linter binary is installed via `:Mason`

### Theme not saving after restart

The theme picker writes directly to `settings.lua`. Check it's writable:

```bash
ls -la ~/.config/nvim/lua/settings.lua
```

### Extras not loading

Uncomment the extra in `settings.lua` (remove the leading `--`), then run `:Lazy sync`:

```lua
extras = {
  "plugins.extras.lang.go",   -- ✅ active
},
```

---

*NamiConfig · Built with lazy.nvim · Requires Neovim 0.10+*
