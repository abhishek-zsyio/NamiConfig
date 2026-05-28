# NamiConfig - Neovim Configuration Context

This file provides a structured overview of the `NamiConfig` Neovim setup. It is intended to be used as context for AI assistants when modifying or debugging the configuration.

## 📂 Directory Structure

```text
.
├── init.lua                  (Main entry point, bootstrap lazy.nvim)
├── lazy-lock.json            (Plugin version lockfile)
├── lua
│   ├── core                  (Core editor setup)
│   │   ├── autocmds.lua      (Global autocommands)
│   │   ├── keymaps.lua       (Global keymaps)
│   │   ├── lang_registry.lua (Language specifics)
│   │   ├── options.lua       (Vim options like tabstop, numbers)
│   │   ├── settings_loader.lua (Parses user settings.lua)
│   │   ├── snacks            (Internal snacks config components)
│   │   └── theme_registry.lua(Theme definitions)
│   ├── plugins               (Lazy plugin specifications)
│   │   ├── ai                (AI assistants like supermaven)
│   │   ├── editor            (Treesitter, cmp, utils, etc)
│   │   ├── extras            (Opt-in language/tool modules)
│   │   ├── formatting        (Conform)
│   │   ├── git               (Gitsigns, Diffview)
│   │   ├── init.lua          (Plugin loader index)
│   │   ├── lang              (Language specific plugins)
│   │   ├── linting           (Nvim-lint)
│   │   ├── lsp               (Lspconfig, Mason)
│   │   └── ui                (Statusline, Bufferline, Snacks, etc)
│   └── settings.lua          (User-facing declarative configuration)
├── README.md
├── setup.sh                  (Installation script)
└── wiki.md                   (Documentation)
```

## ⚙️ Core Philosophy
- **Declarative User Settings**: Users primarily interact with `lua/settings.lua` to change themes, behaviors, and opt-in extras.
- **Lazy Loading**: `folke/lazy.nvim` is used. Plugin specs are in `lua/plugins/` and are automatically imported via `lua/plugins/init.lua`.
- **Modern UI**: Driven by `snacks.nvim` (pickers, explorer, dashboard) and tailored components like a custom statusline, `bufferline.nvim`, and `dropbar`.
- **Modularity**: Core Vim settings (`lua/core/options.lua`) are separate from user toggles (`lua/settings.lua`).

## 📄 Key Files

### `lua/settings.lua` (User Configuration)
Contains the `M` table with grouped options like `ui`, `editor`, `lsp`, `explorer`, `extras`, etc. It handles mapping flat legacy settings to structured groups internally.

### `init.lua` (Bootstrap)
Pre-loads `core.settings_loader`, sets up Leader keys, loads `core.options`, bootstraps `lazy.nvim`, and finally schedules `core.keymaps` and `core.autocmds`.

### `lua/plugins/init.lua` (Plugin Index)
Imports plugin specs from the subdirectories:
```lua
return {
  -- UI
  { import = "plugins.ui.theme" },
  { import = "plugins.ui.bufferline" },
  { import = "plugins.ui.statusline" },
  { import = "plugins.ui.noice" },
  -- ... other imports
}
```
