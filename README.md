# NamiConfig ⚡

> A modular, registry-driven Neovim configuration built on `lazy.nvim`.
> Designed for web, Python, and full-stack development — extensible to Go, Rust,
> SQL, and more via opt-in extras.

---

## ✨ Features

| Category | What's included |
|----------|----------------|
| 🎨 **Themes** | 14 colorschemes · live theme switcher that syncs Ghostty |
| 🗂 **File Explorer** | nvim-tree with devicons |
| 🔭 **Fuzzy Finder** | Telescope + fzf-native |
| 🧠 **LSP** | All servers auto-installed from a central registry |
| ✍️ **Completion** | nvim-cmp + LuaSnip + Supermaven AI |
| 🎯 **Formatting** | conform.nvim (registry-driven, per-language) |
| 🔎 **Linting** | nvim-lint (async, registry-driven, per-language) |
| 🌳 **Syntax** | Treesitter for 20+ languages · Treesitter Context (sticky headers) |
| 🐛 **Debugging** | nvim-dap + UI (Python, Go extra, Rust extra) |
| 🔀 **Git** | Gitsigns · LazyGit · Diffview · inline blame |
| 🤖 **AI** | Supermaven inline completions |
| 🏆 **LeetCode** | Full native integration · **Git auto-sync to GitHub on save/submit** |
| 📦 **Extras** | Opt-in packs for Go, Rust, Testing |
| 🏠 **Project Config** | Per-project LSP overrides via `.neoconf.json` |

---

## 🏗 Architecture

```
init.lua
├── core/options.lua         vim.opt settings (driven by settings.lua)
├── core/keymaps.lua         All global keymaps
├── core/autocmds.lua        Autocommands
├── core/lang_registry.lua   🗂 Single source of truth for all language tools
└── plugins/
    ├── ui/                  Theme, statusline, bufferline, telescope, terminal…
    ├── editor/              Completion, treesitter, autopairs, neoconf
    ├── lsp/                 mason, lspconfig, DAP
    ├── formatting/          conform.nvim
    ├── linting/             nvim-lint
    ├── git/                 gitsigns, lazygit, diffview
    ├── ai/                  supermaven
    └── extras/              Opt-in language & feature packs
        ├── lang/go.lua
        ├── lang/rust.lua
        ├── lang/sql.lua
        └── testing/neotest.lua
```

### The Language Registry

`lua/core/lang_registry.lua` is the **single source of truth**. Define a language once:

```lua
python = {
  lsp        = "pyright",
  mason      = { "black", "ruff" },
  formatters = { "black" },
  linters    = { "ruff" },
  lsp_opts   = { ... },
}
```

This automatically drives: **Mason install** → **lspconfig setup** → **conform.nvim** → **nvim-lint**. No duplicate config across 4 files.

---

## ⚙️ Configuration

Everything you need is in **`lua/settings.lua`**. No Lua knowledge required. The configuration is organized into logical, nested tables:

```lua
return {
  -- ── UI & Aesthetics ────────────────────────────────────────────────────────
  ui = {
    theme = "rose-pine-main",      -- Sleek themes (catppuccin, rose-pine, etc.)
    background = "dark",           -- "dark" or "light"
    transparent = true,            -- Toggle editor background transparency
    dim_inactive = false,          -- Dim unfocused windows
    show_indent_guides = true,     -- Vertical indent lines
    smooth_scroll = true,          -- Smooth scroll animations
    cmdheight = 0,                 -- 0 for clean modern hidden command line

    -- Buffer Tab Bar (akinsho/bufferline.nvim)
    tab_buffer = {
      enable = true,
      style = "buffers",           -- "buffers" or "tabs"
      show_icons = true,
      show_close = false,
      diagnostics = "nvim_lsp",
      divider_style = "slope",     -- slope, slant, thick, thin, none, dotted
      transparent_dividers = false,
      hide_empty = true,
    },

    -- Pickers & Overlays (snacks.picker)
    picker = {
      layout = "ivy",              -- telescope, ivy, dropdown, vertical, etc.
      width = 0.85,
      height = 0.8,
      border = "rounded",
    },
  },

  -- ── Editor Behavior ────────────────────────────────────────────────────────
  editor = {
    highlight_current_line = true,
    show_line_numbers = true,
    relative_line_numbers = true,
    format_on_save = true,
    tab_size = 2,
    wrap_lines = true,
    mouse_support = false,
  },

  -- ── Extras (Opt-in Language packs) ──────────────────────────────────────────
  extras = {
    "plugins.extras.lang.go",
    "plugins.extras.lang.rust",
    "plugins.extras.lang.sql",
    "plugins.extras.testing.neotest",
  },
}
```

---

## 🌍 Language Support

### Built-in (always active)

| Language | LSP | Formatter | Linter |
|----------|-----|-----------|--------|
| HTML | html | prettier | — |
| CSS/SCSS | cssls | prettier | stylelint |
| JavaScript | ts_ls | prettier | eslint_d |
| TypeScript | ts_ls | prettier | eslint_d |
| JSON | jsonls | prettier | — |
| YAML | yamlls | prettier | — |
| Vue | volar | prettier | eslint_d |
| Lua | lua_ls | stylua | luacheck |
| Bash | bashls | shfmt | shellcheck |
| Python | pyright | black | ruff |
| Markdown | marksman | prettier | markdownlint |
| Dockerfile | dockerls | — | hadolint |

### Extras (opt-in via `settings.lua`)

| Extra | What it adds |
|-------|-------------|
| `lang.go` | gopls · go.nvim · Delve debugger · treesitter |
| `lang.rust` | rustaceanvim (rust-analyzer) · codelldb · treesitter |
| `lang.sql` | vim-dadbod · DB UI explorer · SQL completion |
| `testing.neotest` | pytest · jest · vitest · DAP integration |

---

## ⌨️ Key Keymaps

> `<leader>` is `Space`. Press `<leader>` and wait for the which-key popup.

### Navigation
| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Move between windows |
| `<Tab>` / `<S-Tab>` | Next / Prev buffer |
| `<leader>x` | Close buffer |
| `<C-n>` | Toggle file tree |
| `<A-i/h/v>` | Float / Horizontal / Vertical terminal |

### Find
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fw` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fo` | Recent files |
| `<leader>th` | Theme picker (syncs Ghostty) |

### Code / LSP
| Key | Action |
|-----|--------|
| `gd` / `gr` / `K` | Definition / References / Hover |
| `<leader>ca` | Code action |
| `<leader>ra` | Rename symbol |
| `<leader>cf` | Format buffer |
| `<leader>cl` | Lint file |
| `<leader>tc` | Toggle Treesitter Context |
| `[d` / `]d` | Prev / Next diagnostic |

### Git
| Key | Action |
|-----|--------|
| `<leader>gg` | LazyGit |
| `<leader>gd` | Toggle Diffview |
| `]h` / `[h` | Next / Prev hunk |
| `<leader>hs` | Stage hunk |

### Debug
| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue |
| `<leader>dso` / `dsi` | Step over / in |

### LeetCode
| Key | Action |
|-----|--------|
| `<leader>lc` | Open LeetCode native dashboard |
| `<leader>lr` | Save & asynchronously run test cases |
| `<leader>ls` | Save & asynchronously submit solution |
| `<leader>ld` | Open problem description panel |
| `<leader>li` | Show problem statistics/info |

---

## 🚀 Installation

### One-Command Setup (recommended)

```bash
# 1. Clone the config
git clone git@github.com:abhishek-zsyio/NamiConfig.git ~/.config/nvim

# 2. Run the setup script — installs all dependencies + bootstraps plugins
bash ~/.config/nvim/setup.sh
```

The setup script handles everything:
- Installs **Homebrew** (if not present)
- Installs **Neovim**, **ripgrep**, **fd**, **lazygit**, **Node.js**, **Deno**, **ImageMagick**, **silicon**, and more
- Checks for **Python 3**, **Go**, **Rust** (warns if missing)
- Installs **JetBrainsMono Nerd Font**
- Runs a **headless plugin sync** via lazy.nvim

### Manual Installation

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.bak

# Clone
git clone git@github.com:abhishek-zsyio/NamiConfig.git ~/.config/nvim

# Start Neovim — lazy.nvim auto-installs all plugins
nvim
```

On first launch, lazy.nvim clones all plugins. Then Mason auto-installs all LSP
servers, formatters, and linters defined in the lang registry.

---

## 📖 Full Wiki

See the [wiki](./wiki.md) for the complete documentation including:
- Full plugin reference
- All keymaps
- How to add a new language
- How to add a new plugin
- Troubleshooting guide

---

## 🔧 Requirements

| Tool | Required | Purpose |
|------|----------|---------|
| **Neovim 0.10+** | ✅ Required | Core editor |
| **Git** | ✅ Required | Plugin manager + git features |
| **Node.js / npm** | ✅ Required | ts_ls, prettier, eslint_d, leetcode.nvim |
| **ripgrep** (`rg`) | ✅ Required | Snacks live grep |
| **fd** | ✅ Required | Snacks file finder |
| **lazygit** | ✅ Required | Snacks lazygit TUI |
| **Python 3 + pip** | ✅ Required | pyright LSP, black, ruff, debugpy |
| **Deno** | ✅ Required | peek.nvim markdown preview (build step) |
| **ImageMagick** | ✅ Required | Snacks image rendering |
| **A Nerd Font** | ✅ Required | Icons throughout the UI |
| **silicon** (via cargo) | ⚡ Optional | Code screenshot (`:Silicon`) |
| **Ghostty** | ⚡ Optional | Theme sync (`<leader>th`) |
| **Go** | ⚡ Optional | `plugins.extras.lang.go` |
| **Rust / cargo** | ⚡ Optional | `plugins.extras.lang.rust` + silicon |
| `make` / `clang` | ✅ Required | Treesitter parser compilation |

> **Tip:** Run `bash ~/.config/nvim/setup.sh` and all required tools are installed automatically.

---

*NamiConfig — built with [lazy.nvim](https://github.com/folke/lazy.nvim)*
