# Nami Framework 🌊

> A modular, NvChad-style Neovim framework built on `lazy.nvim`.
> Designed for web, Python, and full-stack development — extensible to Go, Rust,
> SQL, and more via opt-in extras.

---

## ✨ Features

| Category | What's included |
|----------|----------------|
| 🏗 **Architecture** | NvChad-style separation of framework core and user overrides |
| 🎨 **Themes** | 14 colorschemes · live theme switcher that syncs Ghostty |
| 🗂 **File Explorer** | Snacks explorer |
| 🔭 **Fuzzy Finder** | Snacks picker |
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

---

## 🏗 Architecture (NvChad style)

Nami uses a strict separation between the framework code and your personal configuration:

```
~/.config/nvim/
├── init.lua                 ← Bootstraps the framework
├── lua/nami/                ← 🚫 FRAMEWORK CORE (Do not edit)
├── lua/plugins/             ← 🚫 DEFAULT PLUGINS (Do not edit)
└── lua/custom/              ← ✅ YOUR CONFIGURATION (Git-ignored)
    ├── init.lua             ← Entry point for overrides
    ├── settings.lua         ← Your settings (merged over defaults)
    └── plugins/init.lua     ← Your extra plugins
```

### The Settings Engine

The framework defines sensible defaults in `lua/nami/config.lua`. You only need to define what you want to **change** in your `lua/custom/settings.lua`. The framework deep-merges your settings over the defaults.

---

## ⚙️ Configuration

Configure Nami by editing **`lua/custom/settings.lua`**:

```lua
return {
  ui = {
    theme = "catppuccin-mocha",
    transparent = true,
  },
  editor = {
    format_on_save = true,
    tab_size = 2,
  },
  extras = {
    "plugins.extras.lang.go",
    "plugins.extras.lang.rust",
  },
  custom_tools = {
    lsp_servers = { "clangd" },
  },
}
```

**Hot Reloading**: Whenever you save `lua/custom/settings.lua`, Nami will instantly hot-reload the settings, apply theme changes, and update UI options without restarting Neovim!

---

## 🔌 Adding Custom Plugins

Add your own plugins in **`lua/custom/plugins/init.lua`**:

```lua
return {
  { "tpope/vim-surround", event = "VeryLazy" },
  { "wakatime/vim-wakatime", lazy = false },
}
```

---

## 🚀 Commands

| Command | Action |
|---------|--------|
| `:NamiInfo` | Show active theme, framework version, and loaded extras |
| `:NamiUpdate` | Pull the latest framework updates from GitHub |
| `:checkhealth nami` | Verify all dependencies are installed |

---

## 🚀 Installation

```bash
# 1. Clone the framework
git clone git@github.com:abhishek-zsyio/NamiConfig.git ~/.config/nvim

# 2. Start Neovim
nvim
```

On first launch, lazy.nvim installs all plugins, and Mason auto-installs all language servers.

---

*Nami Framework — built with [lazy.nvim](https://github.com/folke/lazy.nvim)*

