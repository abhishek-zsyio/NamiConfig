# Neovim Config — NvChad-Clone (Without NvChad)

A fully hand-crafted Neovim setup that replicates the NvChad experience without depending on NvChad. Built on vanilla [lazy.nvim](https://github.com/folke/lazy.nvim) with clean, modular Lua.

## Features

- 🎨 **Catppuccin Mocha** theme with **transparent background**
- 📁 **NvimTree** file explorer (`<C-n>` to toggle)
- 📊 **Lualine** statusline (NvChad block-separator style)
- 📑 **Bufferline** tabufline (slant separators, LSP diagnostics)
- 🔭 **Telescope** — borderless vertical layout with fzf-native
- 🌈 **Rainbow indent guides** (indent-blankline with Catppuccin palette)
- 💬 **Comment.nvim** — `gcc` / `gc` for line/block comments
- 🔗 **Autopairs** — bracket/quote auto-close with treesitter support
- ⌨️ **Which-key** — shows keybinding hints on `<Space>`
- 📍 **Gitsigns** — inline git diff + hunk navigation
- 💾 **Auto-save** on InsertLeave / FocusLost
- 🐛 **DAP** — Python debugging with nvim-dap-ui
- ✨ **Noice** — beautiful command-line and notifications

## Structure

```
~/.config/nvim/
├── init.lua
└── lua/
    ├── core/
    │   ├── options.lua      ← all vim.opt settings
    │   ├── keymaps.lua      ← all keybindings
    │   └── autocmds.lua     ← all autocommands
    └── plugins/
        ├── ui/              ← theme, statusline, bufferline, filetree, telescope, noice, misc
        ├── editor/          ← treesitter, cmp, autopairs, comment, indent, utils
        ├── git/             ← gitsigns, lazygit
        ├── lsp/             ← mason, lspconfig, dap
        ├── formatting/      ← conform
        └── lang/            ← django
```

## Key Mappings

| Key | Action |
|-----|--------|
| `<C-n>` | Toggle NvimTree |
| `<leader>e` | Focus NvimTree |
| `<leader>ff` | Telescope: find files |
| `<leader>fw` | Telescope: live grep |
| `<leader>fb` | Telescope: buffers |
| `<leader>fo` | Telescope: recent files |
| `<Tab>` / `<S-Tab>` | Next / Prev buffer |
| `<leader>x` | Close buffer |
| `<leader>/` | Toggle comment |
| `<leader>gg` | Open LazyGit |
| `<leader>fm` | Format file (LSP) |
| `<leader>ca` | LSP code action |
| `<leader>ra` | LSP rename |
| `<leader>db` | DAP toggle breakpoint |
| `<leader>dc` | DAP continue |
| `<A-j>` / `<A-k>` | Move line up/down |
| `jk` | Exit insert mode |

## Language Support

- **Web**: HTML, CSS, TypeScript, React, Vue, Tailwind, Emmet
- **Python**: pyright LSP, black formatter, debugpy (DAP), venv-selector
- **Django**: htmldjango filetype, vim-jinja, django-plus
- **Lua, Bash, YAML, TOML, Docker, Go, SQL**: full LSP + formatting

## Installation

```bash
# Backup existing config if needed
mv ~/.config/nvim ~/.config/nvim.bak

# Clone this config
git clone <your-repo> ~/.config/nvim

# Start Neovim — lazy.nvim will auto-install all plugins
nvim
```
