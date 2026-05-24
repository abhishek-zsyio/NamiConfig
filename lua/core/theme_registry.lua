-- Centralized Theme Registry
-- To add a new theme, simply add a new entry to this list!
-- Only themes with direct Ghostty terminal equivalents are included.

return {
  {
    id = "catppuccin",
    plugin = "catppuccin/nvim",
    icon = "󰄛 ",
    ghostty = "Catppuccin Mocha",
    setup = function(transparent)
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = transparent,
        show_end_of_buffer = false,
        term_colors = true,
        integrations = {
          cmp = true, gitsigns = true, nvimtree = true,
          telescope = { enabled = true, style = "classic" },
          treesitter = true, notify = true, noice = true, bufferline = true,
          indent_blankline = { enabled = true, colored_indent_levels = false },
          native_lsp = { enabled = true, inlay_hints = { background = true } },
        },
        custom_highlights = function(colors)
          return {
            NormalFloat = { bg = colors.mantle },
            FloatBorder = { bg = colors.mantle, fg = colors.surface1 },
          }
        end,
      })
    end
  },
  {
    id = "onedark",
    plugin = "navarasu/onedark.nvim",
    icon = "󰏘 ",
    ghostty = "Atom One Dark",
    setup = function(transparent)
      require('onedark').setup {
        style = 'darker', transparent = transparent, term_colors = true, ending_tildes = false,
      }
      require('onedark').load()
    end
  },
  {
    id = "tokyonight",
    plugin = "folke/tokyonight.nvim",
    icon = "󰖔 ",
    ghostty = "TokyoNight",
    setup = function(transparent) require("tokyonight").setup({ transparent = transparent }) end
  },
  {
    id = "gruvbox",
    plugin = "ellisonleao/gruvbox.nvim",
    icon = "󰟆 ",
    ghostty = "Gruvbox Dark",
    setup = function(transparent)
      vim.o.background = "dark"
      require("gruvbox").setup({ transparent_mode = transparent, contrast = "hard" })
    end
  },
  {
    id = "rose-pine",
    plugin = "rose-pine/neovim",
    icon = "󰐀 ",
    ghostty = "Rose Pine",
    setup = function(transparent) require("rose-pine").setup({ styles = { transparency = transparent } }) end
  },
  {
    id = "nord",
    plugin = "shaunsingh/nord.nvim",
    icon = "󰇉 ",
    ghostty = "Nord",
    setup = function(transparent)
      if transparent then vim.g.nord_disable_background = true end
    end
  },
  {
    id = "dracula",
    plugin = "Mofiqul/dracula.nvim",
    icon = "󰎆 ",
    ghostty = "Dracula",
    setup = function(transparent) require("dracula").setup({ transparent_bg = transparent }) end
  },
  {
    id = "kanagawa",
    plugin = "rebelot/kanagawa.nvim",
    icon = "󰗚 ",
    ghostty = "Kanagawa Wave",
    setup = function(transparent) 
      require("kanagawa").setup({ 
        transparent = transparent,
        theme = "wave",
        background = { dark = "wave", light = "lotus" },
      }) 
    end
  },
  {
    id = "nightfox",
    plugin = "EdenEast/nightfox.nvim",
    icon = "󰊆 ",
    ghostty = "Nightfox",
    setup = function(transparent) require("nightfox").setup({ options = { transparent = transparent } }) end
  },
  {
    id = "sonokai",
    plugin = "sainnhe/sonokai",
    icon = "󰔎 ",
    ghostty = "Sonokai",
    setup = function(transparent)
      if transparent then vim.g.sonokai_transparent_background = 1 end
    end
  },
  {
    id = "material",
    plugin = "marko-cerovac/material.nvim",
    icon = "󰔉 ",
    ghostty = "Material",
    setup = function(transparent)
      vim.g.material_style = "deep ocean"
      require("material").setup({
        disable = { background = transparent },
        high_visibility = { lighter = false, darker = true },
      })
    end
  },
  {
    id = "oxocarbon",
    plugin = "nyoom-engineering/oxocarbon.nvim",
    icon = "󰏗 ",
    ghostty = "Oxocarbon",
    setup = function(transparent)
      -- Oxocarbon relies mostly on colorscheme application, 
      -- but setting background is needed
      vim.opt.background = "dark"
    end
  },
  {
    id = "monokai",
    plugin = "tanvirtin/monokai.nvim",
    icon = "󰏘 ",
    ghostty = "Monokai Classic",
    setup = function(transparent)
      -- Monokai requires loading via setup if we want options
    end
  },
  {
    id = "everforest",
    plugin = "sainnhe/everforest",
    icon = "󰔎 ",
    ghostty = "Everforest Dark Hard",
    setup = function(transparent)
      vim.g.everforest_background = "hard"
      vim.g.everforest_better_performance = 1
      if transparent then vim.g.everforest_transparent_background = 1 end
    end
  },
  {
    id = "gruvbox-material",
    plugin = "sainnhe/gruvbox-material",
    icon = "󰟆 ",
    ghostty = "Gruvbox Material Dark",
    setup = function(transparent)
      if transparent then vim.g.gruvbox_material_transparent_background = 1 end
    end
  },
  {
    id = "poimandres",
    plugin = "olivercederborg/poimandres.nvim",
    icon = "󰖔 ",
    ghostty = "Poimandres",
    setup = function(transparent)
      require('poimandres').setup {
        disable_background = transparent,
        disable_float_background = transparent,
      }
    end
  },
  {
    id = "github_dark",
    plugin = "projekt0n/github-nvim-theme",
    icon = "󰊤 ",
    ghostty = "GitHub Dark",
    setup = function(transparent) require("github-theme").setup({ options = { transparent = transparent } }) end
  },
}
