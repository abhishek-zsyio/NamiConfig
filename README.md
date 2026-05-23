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
| 🌳 **Syntax** | Treesitter for 20+ languages |
| 🐛 **Debugging** | nvim-dap + UI (Python, Go extra, Rust extra) |
| 🔀 **Git** | Gitsigns · LazyGit · Diffview · inline blame |
| 🤖 **AI** | Supermaven inline completions |
| 📦 **Extras** | Opt-in packs for Go, Rust, SQL, Testing |
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

Everything you need is in **`lua/settings.lua`**. No Lua knowledge required.

```lua
return {
  theme                = "catppuccin",  -- 14 themes available
  background           = "solid",       -- "solid" or "transparent"
  format_on_save       = false,         -- auto-format on :w
  tab_size             = 2,
  enable_linting       = true,          -- async linting
  enable_project_config = true,         -- .neoconf.json support
  show_hidden_files    = true,

  -- Opt-in to extra language/feature packs:
  extras = {
    -- "plugins.extras.lang.go",
    -- "plugins.extras.lang.rust",
    -- "plugins.extras.lang.sql",
    -- "plugins.extras.testing.neotest",
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

---

## 🚀 Installation

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.bak

# Clone
git clone <your-repo-url> ~/.config/nvim

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

- **Neovim** 0.10+
- **Git**
- **Node.js** (for TypeScript, Prettier, ESLint)
- **Python 3** (for Python LSP + DAP)
- A **Nerd Font** (e.g., JetBrainsMono Nerd Font)
- `make` (for fzf-native compilation)
- `ripgrep` (for Telescope live grep)

---

*NamiConfig — built with [lazy.nvim](https://github.com/folke/lazy.nvim)*
