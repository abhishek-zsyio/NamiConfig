-- Centralized Theme Registry
-- To add a new theme, simply add a new entry to this list!

local function catppuccin_setup(flavour)
  return function(transparent)
    vim.o.background = flavour == "latte" and "light" or "dark"
    require("catppuccin").setup({
      flavour                = flavour,
      transparent_background = transparent,
      show_end_of_buffer     = false,
      term_colors            = true,
      dim_inactive = {
        enabled    = false,
        shade      = "dark",
        percentage = 0.15,
      },
      styles = {
        comments     = { "italic" },
        conditionals = { "italic" },
        keywords     = { "bold" },
        functions    = { "bold" },
        strings      = {},
        variables    = {},
        numbers      = {},
        booleans     = { "bold", "italic" },
        properties   = {},
        types        = { "bold" },
        operators    = {},
      },
      integrations = {
        cmp              = true,
        blink_cmp        = true,
        gitsigns         = true,
        nvimtree         = true,
        snacks           = true,
        treesitter       = true,
        notify           = true,
        noice            = true,
        which_key        = true,
        mason            = true,
        lsp_trouble      = true,
        neotest          = true,
        dashboard        = true,
        diffview         = true,
        telescope        = { enabled = true, style = "nvchad" },
        indent_blankline = { enabled = true, colored_indent_levels = false },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors      = { "italic" },
            hints       = { "italic" },
            warnings    = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors      = { "underline" },
            hints       = { "underline" },
            warnings    = { "underline" },
            information = { "underline" },
          },
          inlay_hints = { background = true },
        },
      },
      custom_highlights = function(C)
        return {
          -- Editor chrome
          NormalFloat  = { bg = C.mantle },
          FloatBorder  = { bg = C.mantle, fg = C.surface1 },
          WinSeparator = { fg = C.surface1, bg = "NONE" },

          -- Cursor & line
          CursorLine   = { bg = C.surface0 },
          CursorLineNr = { fg = C.lavender, bold = true },
          LineNr       = { fg = C.surface1, italic = true },

          -- Pmenu / autocomplete
          Pmenu      = { bg = C.mantle },
          PmenuSel   = { bg = C.surface1, fg = C.text, bold = true },
          PmenuSbar  = { bg = C.surface0 },
          PmenuThumb = { bg = C.overlay0 },

          -- Snacks indent guides
          SnacksIndent      = { fg = C.surface1 },
          SnacksIndentScope = { fg = C.lavender },
          SnacksIndentChunk = { fg = C.lavender },
          SnacksPickerTree  = { fg = C.surface1 },

          -- Dashboard highlights
          SnacksDashboardHeader = { fg = C.lavender, bold = true },
          SnacksDashboardDesc   = { fg = C.subtext0 },
          SnacksDashboardKey    = { fg = C.peach,    bold = true },
          SnacksDashboardIcon   = { fg = C.blue },
          SnacksDashboardFooter = { fg = C.surface1,  italic = true },

          -- Dropbar breadcrumbs
          WinBar   = { bg = C.mantle, fg = C.subtext1 },
          WinBarNC = { bg = C.mantle, fg = C.surface2 },

          -- Match paren: subtle underline instead of jarring bg
          MatchParen = { fg = C.peach, bold = true, underline = true, sp = C.peach },

          -- Fold
          Folded = { bg = C.surface0, fg = C.subtext0, italic = true },

          -- Treesitter context sticky header
          TreesitterContext           = { bg = C.surface0 },
          TreesitterContextLineNumber = { fg = C.lavender, bold = true },
          TreesitterContextSeparator  = { fg = C.surface1 },
        }
      end,
    })
  end
end

local function onedark_setup(style)
  return function(transparent)
    vim.o.background = style == "light" and "light" or "dark"
    require('onedark').setup {
      style = style, transparent = transparent, term_colors = true, ending_tildes = false,
    }
    require('onedark').load()
  end
end

local function tokyonight_setup(style)
  return function(transparent)
    vim.o.background = style == "day" and "light" or "dark"
    require("tokyonight").setup({ style = style, transparent = transparent })
  end
end

local function rosepine_setup(variant)
  return function(transparent)
    vim.o.background = variant == "dawn" and "light" or "dark"
    require("rose-pine").setup({ variant = variant, styles = { transparency = transparent } })
  end
end

local function kanagawa_setup(theme)
  return function(transparent)
    vim.o.background = theme == "lotus" and "light" or "dark"
    require("kanagawa").setup({ 
      transparent = transparent,
      theme = theme,
    }) 
  end
end

return {
  -- Catppuccin
  { id = "catppuccin-mocha", plugin = "catppuccin/nvim", icon = "󰄛 ", ghostty = "Catppuccin Mocha", setup = catppuccin_setup("mocha") },
  { id = "catppuccin-latte", plugin = "catppuccin/nvim", icon = "󰄛 ", ghostty = "Catppuccin Latte", setup = catppuccin_setup("latte") },
  { id = "catppuccin-frappe", plugin = "catppuccin/nvim", icon = "󰄛 ", ghostty = "Catppuccin Frappe", setup = catppuccin_setup("frappe") },
  { id = "catppuccin-macchiato", plugin = "catppuccin/nvim", icon = "󰄛 ", ghostty = "Catppuccin Macchiato", setup = catppuccin_setup("macchiato") },

  -- TokyoNight
  { id = "tokyonight-day", plugin = "folke/tokyonight.nvim", icon = "󰖔 ", ghostty = "TokyoNight Day", setup = tokyonight_setup("day") },
  { id = "tokyonight-night", plugin = "folke/tokyonight.nvim", icon = "󰖔 ", ghostty = "TokyoNight", setup = tokyonight_setup("night") },
  { id = "tokyonight-storm", plugin = "folke/tokyonight.nvim", icon = "󰖔 ", ghostty = "TokyoNight Storm", setup = tokyonight_setup("storm") },
  { id = "tokyonight-moon", plugin = "folke/tokyonight.nvim", icon = "󰖔 ", ghostty = "TokyoNight Moon", setup = tokyonight_setup("moon") },

  -- Rose Pine
  { id = "rose-pine-dawn", plugin = "rose-pine/neovim", icon = "󰐀 ", ghostty = "Rose Pine Dawn", setup = rosepine_setup("dawn") },
  { id = "rose-pine-main", plugin = "rose-pine/neovim", icon = "󰐀 ", ghostty = "Rose Pine", setup = rosepine_setup("main") },
  { id = "rose-pine-moon", plugin = "rose-pine/neovim", icon = "󰐀 ", ghostty = "Rose Pine Moon", setup = rosepine_setup("moon") },

  -- Kanagawa
  { id = "kanagawa-lotus", plugin = "rebelot/kanagawa.nvim", icon = "󰗚 ", ghostty = "Kanagawa Lotus", setup = kanagawa_setup("lotus") },
  { id = "kanagawa-wave", plugin = "rebelot/kanagawa.nvim", icon = "󰗚 ", ghostty = "Kanagawa Wave", setup = kanagawa_setup("wave") },
  { id = "kanagawa-dragon", plugin = "rebelot/kanagawa.nvim", icon = "󰗚 ", ghostty = "Kanagawa Dragon", setup = kanagawa_setup("dragon") },

  -- GitHub
  { id = "github_light", plugin = "projekt0n/github-nvim-theme", icon = "󰊤 ", ghostty = "GitHub Light Default", setup = function(t) vim.o.background="light"; require("github-theme").setup({options={transparent=t}}) end },
  { id = "github_dark", plugin = "projekt0n/github-nvim-theme", icon = "󰊤 ", ghostty = "GitHub Dark Default", setup = function(t) vim.o.background="dark"; require("github-theme").setup({options={transparent=t}}) end },
  { id = "github_dark_dimmed", plugin = "projekt0n/github-nvim-theme", icon = "󰊤 ", ghostty = "GitHub Dark Dimmed", setup = function(t) vim.o.background="dark"; require("github-theme").setup({options={transparent=t}}) end },

  -- Nightfox
  { id = "dayfox", plugin = "EdenEast/nightfox.nvim", icon = "󰊆 ", ghostty = "Dayfox", setup = function(t) vim.o.background="light"; require("nightfox").setup({options={transparent=t}}) end },
  { id = "nightfox", plugin = "EdenEast/nightfox.nvim", icon = "󰊆 ", ghostty = "Nightfox", setup = function(t) vim.o.background="dark"; require("nightfox").setup({options={transparent=t}}) end },
  { id = "duskfox", plugin = "EdenEast/nightfox.nvim", icon = "󰊆 ", ghostty = "Duskfox", setup = function(t) vim.o.background="dark"; require("nightfox").setup({options={transparent=t}}) end },
  { id = "nordfox", plugin = "EdenEast/nightfox.nvim", icon = "󰊆 ", ghostty = "Nordfox", setup = function(t) vim.o.background="dark"; require("nightfox").setup({options={transparent=t}}) end },
  { id = "terafox", plugin = "EdenEast/nightfox.nvim", icon = "󰊆 ", ghostty = "Terafox", setup = function(t) vim.o.background="dark"; require("nightfox").setup({options={transparent=t}}) end },
  { id = "carbonfox", plugin = "EdenEast/nightfox.nvim", icon = "󰊆 ", ghostty = "Carbonfox", setup = function(t) vim.o.background="dark"; require("nightfox").setup({options={transparent=t}}) end },

  -- OneDark
  { id = "onedark-light", colorscheme = "onedark", plugin = "navarasu/onedark.nvim", icon = "󰏘 ", ghostty = "Atom One Light", setup = onedark_setup("light") },
  { id = "onedark-dark", colorscheme = "onedark", plugin = "navarasu/onedark.nvim", icon = "󰏘 ", ghostty = "Atom One Dark", setup = onedark_setup("dark") },
  { id = "onedark-darker", colorscheme = "onedark", plugin = "navarasu/onedark.nvim", icon = "󰏘 ", ghostty = "Atom One Dark", setup = onedark_setup("darker") },
  { id = "onedark-cool", colorscheme = "onedark", plugin = "navarasu/onedark.nvim", icon = "󰏘 ", ghostty = "Atom One Dark", setup = onedark_setup("cool") },
  { id = "onedark-deep", colorscheme = "onedark", plugin = "navarasu/onedark.nvim", icon = "󰏘 ", ghostty = "Atom One Dark", setup = onedark_setup("deep") },
  { id = "onedark-warm", colorscheme = "onedark", plugin = "navarasu/onedark.nvim", icon = "󰏘 ", ghostty = "Atom One Dark", setup = onedark_setup("warm") },
  { id = "onedark-warmer", colorscheme = "onedark", plugin = "navarasu/onedark.nvim", icon = "󰏘 ", ghostty = "Atom One Dark", setup = onedark_setup("warmer") },

  -- Gruvbox
  { id = "gruvbox", plugin = "ellisonleao/gruvbox.nvim", icon = "󰟆 ", ghostty = "Gruvbox Dark", setup = function(t) vim.o.background="dark"; require("gruvbox").setup({transparent_mode=t, contrast="hard"}) end },

  -- Others
  { id = "nord", plugin = "shaunsingh/nord.nvim", icon = "󰇉 ", ghostty = "Nord", setup = function(t) vim.o.background="dark"; vim.g.nord_disable_background = t and true or false end },
  { id = "dracula", plugin = "Mofiqul/dracula.nvim", icon = "󰎆 ", ghostty = "Dracula", setup = function(t) vim.o.background="dark"; require("dracula").setup({transparent_bg=t}) end },
  { id = "sonokai", plugin = "sainnhe/sonokai", icon = "󰔎 ", ghostty = "Sonokai", setup = function(t) vim.o.background="dark"; vim.g.sonokai_transparent_background = t and 1 or 0 end },
  { id = "oxocarbon", plugin = "nyoom-engineering/oxocarbon.nvim", icon = "󰏗 ", ghostty = "Oxocarbon", setup = function(t)
    vim.o.background = "dark"
    if t then
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "oxocarbon",
        callback = function()
          vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
          vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
          vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
        end,
      })
    end
  end },
  { id = "monokai", plugin = "tanvirtin/monokai.nvim", icon = "󰏘 ", ghostty = "Monokai Classic", setup = function(t)
    vim.o.background = "dark"
    require("monokai").setup({ transparent_background = t })
  end },
  { id = "everforest", plugin = "sainnhe/everforest", icon = "󰔎 ", ghostty = "Everforest Dark Hard", setup = function(t) vim.o.background="dark"; vim.g.everforest_background="hard"; vim.g.everforest_better_performance=1; vim.g.everforest_transparent_background = t and 1 or 0 end },
  { id = "gruvbox-material", plugin = "sainnhe/gruvbox-material", icon = "󰟆 ", ghostty = "Gruvbox Material Dark", setup = function(t) vim.o.background="dark"; vim.g.gruvbox_material_transparent_background = t and 1 or 0 end },
  { id = "poimandres", plugin = "olivercederborg/poimandres.nvim", icon = "󰖔 ", ghostty = "Poimandres", setup = function(t) vim.o.background="dark"; require('poimandres').setup{disable_background=t, disable_float_background=t} end },

  -- Ayu
  { id = "ayu-light", colorscheme = "ayu-light", plugin = "Shatur/neovim-ayu", icon = "󰏘 ", ghostty = "Ayu Light", setup = function(t)
    vim.o.background = "light"
    require("ayu").setup({
      mirage = false,
      overrides = t and {
        Normal = { bg = "None" },
        NormalNC = { bg = "None" },
        SignColumn = { bg = "None" },
      } or {}
    })
  end },
  { id = "ayu-dark", colorscheme = "ayu-dark", plugin = "Shatur/neovim-ayu", icon = "󰏘 ", ghostty = "Ayu", setup = function(t)
    vim.o.background = "dark"
    require("ayu").setup({
      mirage = false,
      overrides = t and {
        Normal = { bg = "None" },
        NormalNC = { bg = "None" },
        SignColumn = { bg = "None" },
      } or {}
    })
  end },
  { id = "ayu-mirage", colorscheme = "ayu-mirage", plugin = "Shatur/neovim-ayu", icon = "󰏘 ", ghostty = "Ayu Mirage", setup = function(t)
    vim.o.background = "dark"
    require("ayu").setup({
      mirage = true,
      overrides = t and {
        Normal = { bg = "None" },
        NormalNC = { bg = "None" },
        SignColumn = { bg = "None" },
      } or {}
    })
  end },

  -- Cyberdream
  { id = "cyberdream-light", colorscheme = "cyberdream", plugin = "scottmckendry/cyberdream.nvim", icon = "󰏗 ", ghostty = "One Half Light", setup = function(t) vim.o.background="light"; require("cyberdream").setup({transparent=t, theme={variant="light"}}) end },
  { id = "cyberdream-dark", colorscheme = "cyberdream", plugin = "scottmckendry/cyberdream.nvim", icon = "󰏗 ", ghostty = "Matte Black", setup = function(t) vim.o.background="dark"; require("cyberdream").setup({transparent=t, theme={variant="default"}}) end },

  -- Material
  { id = "material-lighter", colorscheme = "material", plugin = "marko-cerovac/material.nvim", icon = "󰏘 ", ghostty = "Material", setup = function(t) vim.o.background="light"; vim.g.material_style="lighter"; require("material").setup({disable={background=t}}) end },
  { id = "material-darker", colorscheme = "material", plugin = "marko-cerovac/material.nvim", icon = "󰏘 ", ghostty = "Material Darker", setup = function(t) vim.o.background="dark"; vim.g.material_style="darker"; require("material").setup({disable={background=t}}) end },
  { id = "material-oceanic", colorscheme = "material", plugin = "marko-cerovac/material.nvim", icon = "󰏘 ", ghostty = "Material Ocean", setup = function(t) vim.o.background="dark"; vim.g.material_style="oceanic"; require("material").setup({disable={background=t}}) end },

  -- Nightfly & Moonfly
  { id = "nightfly", plugin = "bluz71/vim-nightfly-colors", icon = "󰖔 ", ghostty = "Nightfly", setup = function(t) vim.o.background="dark"; vim.g.nightflyTransparent=t and 1 or 0 end },
  { id = "moonfly", plugin = "bluz71/vim-moonfly-colors", icon = "󰖔 ", ghostty = "Moonfly", setup = function(t) vim.o.background="dark"; vim.g.moonflyTransparent=t and 1 or 0 end },

  -- Community Favorites
  { id = "solarized-osaka", plugin = "craftzdog/solarized-osaka.nvim", icon = "󰏘 ", ghostty = "Solarized Osaka Night", setup = function(t) vim.o.background="dark"; require("solarized-osaka").setup({transparent=t}) end },
  { id = "night-owl", plugin = "oxfist/night-owl.nvim", icon = "󰏘 ", ghostty = "Night Owl", setup = function(t) vim.o.background="dark"; require("night-owl").setup({transparent=t}) end },
  { id = "mellifluous", plugin = "ramojus/mellifluous.nvim", icon = "󰏘 ", ghostty = "Mellifluous", setup = function(t) vim.o.background="dark"; require("mellifluous").setup({transparent_background={enabled=t}}) end },
  { id = "bamboo", plugin = "ribru17/bamboo.nvim", icon = "󰏘 ", ghostty = "Everforest Dark Hard", setup = function(t) vim.o.background="dark"; require("bamboo").setup({transparent=t}) end },
}
