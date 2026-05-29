-- ─────────────────────────────────────────────────────────────────────────────
-- core/theme_registry.lua
-- Single source of truth for every supported theme.
-- Add a new theme here and it automatically appears in the picker + lazy-loader.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Setup factories ───────────────────────────────────────────────────────────

local function catppuccin_setup(flavour)
  return function(transparent)
    vim.o.background = flavour == "latte" and "light" or "dark"
    require("catppuccin").setup({
      flavour                = flavour,
      transparent_background = transparent,
      show_end_of_buffer     = false,
      term_colors            = true,
      dim_inactive           = { enabled = false, shade = "dark", percentage = 0.15 },
      styles = {
        comments     = { "italic" },
        conditionals = { "italic" },
        keywords     = { "bold" },
        functions    = { "bold" },
        booleans     = { "bold", "italic" },
        types        = { "bold" },
        strings      = {}, variables = {}, numbers = {}, properties = {}, operators = {},
      },
      integrations = {
        cmp              = true, blink_cmp  = true, gitsigns   = true,
        nvimtree         = true, snacks     = true, treesitter = true,
        notify           = true, noice      = true, which_key  = true,
        mason            = true, lsp_trouble= true, neotest    = true,
        dashboard        = true, diffview   = true,
        telescope        = { enabled = true, style = "nvchad" },
        indent_blankline = { enabled = true, colored_indent_levels = false },
        native_lsp = {
          enabled      = true,
          virtual_text = { errors={"italic"}, hints={"italic"}, warnings={"italic"}, information={"italic"} },
          underlines   = { errors={"underline"}, hints={"underline"}, warnings={"underline"}, information={"underline"} },
          inlay_hints  = { background = true },
        },
      },
      custom_highlights = function(C)
        return {
          NormalFloat              = { bg = C.mantle },
          FloatBorder              = { bg = C.mantle, fg = C.surface1 },
          WinSeparator             = { fg = C.surface1, bg = "NONE" },
          CursorLine               = { bg = C.surface0 },
          CursorLineNr             = { fg = C.lavender, bold = true },
          LineNr                   = { fg = C.surface1, italic = true },
          Pmenu                    = { bg = C.mantle },
          PmenuSel                 = { bg = C.surface1, fg = C.text, bold = true },
          PmenuSbar                = { bg = C.surface0 },
          PmenuThumb               = { bg = C.overlay0 },
          SnacksIndent             = { fg = C.surface1 },
          SnacksIndentScope        = { fg = C.lavender },
          SnacksIndentChunk        = { fg = C.lavender },
          SnacksPickerTree         = { fg = C.surface1 },
          SnacksDashboardHeader    = { fg = C.lavender, bold = true },
          SnacksDashboardDesc      = { fg = C.subtext0 },
          SnacksDashboardKey       = { fg = C.peach, bold = true },
          SnacksDashboardIcon      = { fg = C.blue },
          SnacksDashboardFooter    = { fg = C.surface1, italic = true },
          WinBar                   = { bg = C.mantle, fg = C.subtext1 },
          WinBarNC                 = { bg = C.mantle, fg = C.surface2 },
          MatchParen               = { fg = C.peach, bold = true, underline = true, sp = C.peach },
          Folded                   = { bg = C.surface0, fg = C.subtext0, italic = true },
          TreesitterContext         = { bg = C.surface0 },
          TreesitterContextLineNumber = { fg = C.lavender, bold = true },
          TreesitterContextSeparator  = { fg = C.surface1 },
        }
      end,
    })
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
    require("kanagawa").setup({ transparent = transparent, theme = theme })
  end
end

local function onedark_setup(style)
  return function(transparent)
    vim.o.background = style == "light" and "light" or "dark"
    require("onedark").setup({ style = style, transparent = transparent, term_colors = true, ending_tildes = false })
    require("onedark").load()
  end
end

local function nightfox_setup(scheme, bg)
  return function(transparent)
    vim.o.background = bg or "dark"
    require("nightfox").setup({ options = { transparent = transparent } })
  end
end

local function github_setup(scheme, bg)
  return function(transparent)
    vim.o.background = bg or "dark"
    require("github-theme").setup({ options = { transparent = transparent } })
  end
end

local function ayu_setup(variant, mirage)
  local bg = variant == "light" and "light" or "dark"
  return function(transparent)
    vim.o.background = bg
    require("ayu").setup({
      mirage    = mirage or false,
      overrides = transparent and {
        Normal     = { bg = "None" },
        NormalNC   = { bg = "None" },
        SignColumn = { bg = "None" },
      } or {},
    })
  end
end

local function material_setup(style, bg)
  return function(transparent)
    vim.o.background = bg or "dark"
    vim.g.material_style = style
    require("material").setup({ disable = { background = transparent } })
  end
end

local function cyberdream_setup(variant)
  return function(transparent)
    vim.o.background = variant == "light" and "light" or "dark"
    require("cyberdream").setup({ transparent = transparent, theme = { variant = variant == "light" and "light" or "default" } })
  end
end

-- ── Registry ──────────────────────────────────────────────────────────────────
-- Fields:
--   id          (required) unique key used in settings.lua
--   plugin      (required) lazy.nvim repo slug
--   icon        (required) nerd-font glyph shown in picker
--   ghostty     (required) Ghostty theme name  ← ALL entries must have this
--   colorscheme (optional) if vim.cmd.colorscheme arg differs from id
--   setup       (optional) function(transparent) called before colorscheme load
--   light       (optional, bool) set true for light themes so picker can categorise

return {
  -- ── Catppuccin ──────────────────────────────────────────────────────────────
  { id="catppuccin-mocha",    plugin="catppuccin/nvim", icon="󰄛 ", ghostty="Catppuccin Mocha",    setup=catppuccin_setup("mocha") },
  { id="catppuccin-macchiato",plugin="catppuccin/nvim", icon="󰄛 ", ghostty="Catppuccin Macchiato",setup=catppuccin_setup("macchiato") },
  { id="catppuccin-frappe",   plugin="catppuccin/nvim", icon="󰄛 ", ghostty="Catppuccin Frappe",   setup=catppuccin_setup("frappe") },
  { id="catppuccin-latte",    plugin="catppuccin/nvim", icon="󰄛 ", ghostty="Catppuccin Latte",    setup=catppuccin_setup("latte"),  light=true },

  -- ── TokyoNight ──────────────────────────────────────────────────────────────
  { id="tokyonight-night", plugin="folke/tokyonight.nvim", icon="󰖔 ", ghostty="TokyoNight",       setup=tokyonight_setup("night") },
  { id="tokyonight-storm", plugin="folke/tokyonight.nvim", icon="󰖔 ", ghostty="TokyoNight Storm", setup=tokyonight_setup("storm") },
  { id="tokyonight-moon",  plugin="folke/tokyonight.nvim", icon="󰖔 ", ghostty="TokyoNight Moon",  setup=tokyonight_setup("moon")  },
  { id="tokyonight-day",   plugin="folke/tokyonight.nvim", icon="󰖔 ", ghostty="TokyoNight Day",   setup=tokyonight_setup("day"),   light=true },

  -- ── Rose Pine ───────────────────────────────────────────────────────────────
  { id="rose-pine-main", plugin="rose-pine/neovim", icon="󰐀 ", ghostty="Rose Pine",      setup=rosepine_setup("main") },
  { id="rose-pine-moon", plugin="rose-pine/neovim", icon="󰐀 ", ghostty="Rose Pine Moon", setup=rosepine_setup("moon") },
  { id="rose-pine-dawn", plugin="rose-pine/neovim", icon="󰐀 ", ghostty="Rose Pine Dawn", setup=rosepine_setup("dawn"), light=true },

  -- ── Kanagawa ────────────────────────────────────────────────────────────────
  { id="kanagawa-wave",   plugin="rebelot/kanagawa.nvim", icon="󰗚 ", ghostty="Kanagawa Wave",   setup=kanagawa_setup("wave") },
  { id="kanagawa-dragon", plugin="rebelot/kanagawa.nvim", icon="󰗚 ", ghostty="Kanagawa Dragon", setup=kanagawa_setup("dragon") },
  { id="kanagawa-lotus",  plugin="rebelot/kanagawa.nvim", icon="󰗚 ", ghostty="Kanagawa Lotus",  setup=kanagawa_setup("lotus"), light=true },

  -- ── GitHub ──────────────────────────────────────────────────────────────────
  { id="github_dark",        plugin="projekt0n/github-nvim-theme", icon="󰊤 ", ghostty="GitHub Dark Default",  setup=github_setup("github_dark",        "dark")  },
  { id="github_dark_dimmed", plugin="projekt0n/github-nvim-theme", icon="󰊤 ", ghostty="GitHub Dark Dimmed",   setup=github_setup("github_dark_dimmed",  "dark")  },
  { id="github_light",       plugin="projekt0n/github-nvim-theme", icon="󰊤 ", ghostty="GitHub Light Default", setup=github_setup("github_light",        "light"), light=true },

  -- ── Nightfox ────────────────────────────────────────────────────────────────
  { id="nightfox",   plugin="EdenEast/nightfox.nvim", icon="󰊆 ", ghostty="Nightfox",   setup=nightfox_setup("nightfox",   "dark") },
  { id="duskfox",    plugin="EdenEast/nightfox.nvim", icon="󰊆 ", ghostty="Duskfox",    setup=nightfox_setup("duskfox",    "dark") },
  { id="nordfox",    plugin="EdenEast/nightfox.nvim", icon="󰊆 ", ghostty="Nordfox",    setup=nightfox_setup("nordfox",    "dark") },
  { id="terafox",    plugin="EdenEast/nightfox.nvim", icon="󰊆 ", ghostty="Terafox",    setup=nightfox_setup("terafox",    "dark") },
  { id="carbonfox",  plugin="EdenEast/nightfox.nvim", icon="󰊆 ", ghostty="Carbonfox",  setup=nightfox_setup("carbonfox",  "dark") },
  { id="dayfox",     plugin="EdenEast/nightfox.nvim", icon="󰊆 ", ghostty="Dayfox",     setup=nightfox_setup("dayfox",     "light"), light=true },

  -- ── OneDark ─────────────────────────────────────────────────────────────────
  { id="onedark-dark",   colorscheme="onedark", plugin="navarasu/onedark.nvim", icon="󰏘 ", ghostty="Atom One Dark",  setup=onedark_setup("dark")   },
  { id="onedark-darker", colorscheme="onedark", plugin="navarasu/onedark.nvim", icon="󰏘 ", ghostty="Atom One Dark",  setup=onedark_setup("darker") },
  { id="onedark-cool",   colorscheme="onedark", plugin="navarasu/onedark.nvim", icon="󰏘 ", ghostty="Atom One Dark",  setup=onedark_setup("cool")   },
  { id="onedark-deep",   colorscheme="onedark", plugin="navarasu/onedark.nvim", icon="󰏘 ", ghostty="Atom One Dark",  setup=onedark_setup("deep")   },
  { id="onedark-warm",   colorscheme="onedark", plugin="navarasu/onedark.nvim", icon="󰏘 ", ghostty="Atom One Dark",  setup=onedark_setup("warm")   },
  { id="onedark-warmer", colorscheme="onedark", plugin="navarasu/onedark.nvim", icon="󰏘 ", ghostty="Atom One Dark",  setup=onedark_setup("warmer") },
  { id="onedark-light",  colorscheme="onedark", plugin="navarasu/onedark.nvim", icon="󰏘 ", ghostty="Atom One Light", setup=onedark_setup("light"), light=true },

  -- ── Ayu ─────────────────────────────────────────────────────────────────────
  { id="ayu-dark",   colorscheme="ayu-dark",   plugin="Shatur/neovim-ayu", icon="󰏘 ", ghostty="Ayu",        setup=ayu_setup("dark")          },
  { id="ayu-mirage", colorscheme="ayu-mirage", plugin="Shatur/neovim-ayu", icon="󰏘 ", ghostty="Ayu Mirage", setup=ayu_setup("dark",  true)   },
  { id="ayu-light",  colorscheme="ayu-light",  plugin="Shatur/neovim-ayu", icon="󰏘 ", ghostty="Ayu Light",  setup=ayu_setup("light"), light=true },

  -- ── Material ────────────────────────────────────────────────────────────────
  { id="material-darker",   colorscheme="material", plugin="marko-cerovac/material.nvim", icon="󰏘 ", ghostty="Material Darker", setup=material_setup("darker",   "dark")  },
  { id="material-oceanic",  colorscheme="material", plugin="marko-cerovac/material.nvim", icon="󰏘 ", ghostty="Material Ocean",  setup=material_setup("oceanic",  "dark")  },
  { id="material-lighter",  colorscheme="material", plugin="marko-cerovac/material.nvim", icon="󰏘 ", ghostty="Material",        setup=material_setup("lighter",  "light"), light=true },

  -- ── Cyberdream ──────────────────────────────────────────────────────────────
  { id="cyberdream-dark",  colorscheme="cyberdream", plugin="scottmckendry/cyberdream.nvim", icon="󰏗 ", ghostty="Matte Black",    setup=cyberdream_setup("dark")         },
  { id="cyberdream-light", colorscheme="cyberdream", plugin="scottmckendry/cyberdream.nvim", icon="󰏗 ", ghostty="One Half Light", setup=cyberdream_setup("light"), light=true },

  -- ── Gruvbox ─────────────────────────────────────────────────────────────────
  { id="gruvbox", plugin="ellisonleao/gruvbox.nvim", icon="󰟆 ", ghostty="Gruvbox Dark",
    setup=function(t) vim.o.background="dark"; require("gruvbox").setup({transparent_mode=t, contrast="hard"}) end },
  { id="gruvbox-material", plugin="sainnhe/gruvbox-material", icon="󰟆 ", ghostty="Gruvbox Material Dark",
    setup=function(t) vim.o.background="dark"; vim.g.gruvbox_material_transparent_background=t and 1 or 0 end },

  -- ── Everforest & Bamboo ─────────────────────────────────────────────────────
  { id="everforest", plugin="sainnhe/everforest", icon="󰔎 ", ghostty="Everforest Dark Hard",
    setup=function(t) vim.o.background="dark"; vim.g.everforest_background="hard"; vim.g.everforest_better_performance=1; vim.g.everforest_transparent_background=t and 1 or 0 end },
  { id="bamboo", plugin="ribru17/bamboo.nvim", icon="󰏘 ", ghostty="Everforest Dark Hard",
    setup=function(t) vim.o.background="dark"; require("bamboo").setup({transparent=t}) end },

  -- ── Misc dark themes ────────────────────────────────────────────────────────
  { id="nord", plugin="shaunsingh/nord.nvim", icon="󰇉 ", ghostty="Nord",
    setup=function(t) vim.o.background="dark"; vim.g.nord_disable_background=t and true or false end },
  { id="dracula", plugin="Mofiqul/dracula.nvim", icon="󰎆 ", ghostty="Dracula",
    setup=function(t) vim.o.background="dark"; require("dracula").setup({transparent_bg=t}) end },
  { id="sonokai", plugin="sainnhe/sonokai", icon="󰔎 ", ghostty="Sonokai",
    setup=function(t) vim.o.background="dark"; vim.g.sonokai_transparent_background=t and 1 or 0 end },
  { id="poimandres", plugin="olivercederborg/poimandres.nvim", icon="󰖔 ", ghostty="Poimandres",
    setup=function(t) vim.o.background="dark"; require("poimandres").setup({disable_background=t, disable_float_background=t}) end },
  { id="monokai", plugin="tanvirtin/monokai.nvim", icon="󰏘 ", ghostty="Monokai Classic",
    setup=function(t) vim.o.background="dark"; require("monokai").setup({transparent_background=t}) end },
  { id="nightfly", plugin="bluz71/vim-nightfly-colors", icon="󰖔 ", ghostty="Nightfly",
    setup=function(t) vim.o.background="dark"; vim.g.nightflyTransparent=t and 1 or 0 end },
  { id="moonfly", plugin="bluz71/vim-moonfly-colors", icon="󰖔 ", ghostty="Moonfly",
    setup=function(t) vim.o.background="dark"; vim.g.moonflyTransparent=t and 1 or 0 end },
  { id="oxocarbon", plugin="nyoom-engineering/oxocarbon.nvim", icon="󰏗 ", ghostty="Oxocarbon",
    setup=function(t)
      vim.o.background="dark"
      if t then
        -- Transparent overrides must fire after the colorscheme loads
        vim.api.nvim_create_autocmd("ColorScheme", {
          pattern = "oxocarbon", once = true,
          callback = function()
            for _, g in ipairs({"Normal","NormalNC","SignColumn"}) do
              vim.api.nvim_set_hl(0, g, { bg="none" })
            end
          end,
        })
      end
    end },
  { id="solarized-osaka", plugin="craftzdog/solarized-osaka.nvim", icon="󰏘 ", ghostty="Solarized Osaka Night",
    setup=function(t) vim.o.background="dark"; require("solarized-osaka").setup({transparent=t}) end },
  { id="night-owl", plugin="oxfist/night-owl.nvim", icon="󰏘 ", ghostty="Night Owl",
    setup=function(t) vim.o.background="dark"; require("night-owl").setup({transparent=t}) end },
  { id="mellifluous", plugin="ramojus/mellifluous.nvim", icon="󰏘 ", ghostty="Mellifluous",
    setup=function(t) vim.o.background="dark"; require("mellifluous").setup({transparent_background={enabled=t}}) end },
}