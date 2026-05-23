-- Catppuccin Mocha with transparency — NvChad's theme
return {
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,
    lazy     = false,
    config   = function()
      local ok, settings = pcall(require, "settings")
      if not ok then settings = {} end

      local is_transparent = settings.background == "transparent"

      require("catppuccin").setup({
        flavour              = "mocha",
        transparent_background = is_transparent,
        show_end_of_buffer   = false,
        term_colors          = true,
        dim_inactive = {
          enabled    = false,
          shade      = "dark",
          percentage = 0.15,
        },
        styles = {
          comments    = { "italic" },
          conditionals = { "italic" },
          functions   = {},
          keywords    = {},
          strings     = {},
          variables   = {},
        },
        integrations = {
          cmp          = true,
          gitsigns     = true,
          nvimtree     = true,
          telescope    = { enabled = true, style = "nvchad" },
          treesitter   = true,
          notify       = true,
          noice        = true,
          bufferline   = true,
          lsp_trouble  = false,
          indent_blankline = { enabled = true, scope_color = "lavender", colored_indent_levels = false },
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
        custom_highlights = function(colors)
          return {
            -- Make floating windows opaque so underlying code doesn't bleed through
            NormalFloat = { bg = colors.mantle },
            FloatBorder = { bg = colors.mantle, fg = colors.surface1 },
          }
        end,
      })
      
      -- Only load catppuccin if it is the selected theme
      if settings.theme == "catppuccin" or settings.theme == nil then
        vim.cmd.colorscheme("catppuccin")
      end
    end,
  },
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      if not ok then settings = {} end

      local is_transparent = settings.background == "transparent"

      require('onedark').setup {
        style = 'darker', -- dark, darker, cool, deep, warm, warmer, light
        transparent = is_transparent,
        term_colors = true,
        ending_tildes = false,
        cmp_itemkind_reverse = false,
        -- toggle theme style ---
        toggle_style_key = nil,
        toggle_style_list = {'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'},
        -- plugins
        diagnostics = {
            darker = true, -- darker colors for diagnostic
            undercurl = true,   -- use undercurl instead of underline for diagnostics
            background = true,    -- use background color for virtual text
        },
      }
      
      -- Load onedark if selected
      if settings.theme == "onedark" then
        require('onedark').load()
      end
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      local transparent = ok and settings.background == "transparent"
      require("tokyonight").setup({ transparent = transparent })
      if settings.theme == "tokyonight" then vim.cmd.colorscheme("tokyonight") end
    end,
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      local transparent = ok and settings.background == "transparent"
      vim.o.background = "dark" -- Ensure dark mode is active
      require("gruvbox").setup({
        transparent_mode = transparent,
        contrast = "hard", -- 'hard' contrast provides the darkest gruvbox background
      })
      if settings.theme == "gruvbox" then vim.cmd.colorscheme("gruvbox") end
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      local transparent = ok and settings.background == "transparent"
      require("rose-pine").setup({
        styles = { transparency = transparent }
      })
      if settings.theme == "rose-pine" then vim.cmd.colorscheme("rose-pine") end
    end,
  },
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      if settings.theme == "nord" then
        if ok and settings.background == "transparent" then
          vim.g.nord_disable_background = true
        end
        vim.cmd.colorscheme("nord")
      end
    end,
  },
  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      local transparent = ok and settings.background == "transparent"
      require("dracula").setup({ transparent_bg = transparent })
      if settings.theme == "dracula" then vim.cmd.colorscheme("dracula") end
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      local transparent = ok and settings.background == "transparent"
      require("kanagawa").setup({ transparent = transparent })
      if settings.theme == "kanagawa" then vim.cmd.colorscheme("kanagawa") end
    end,
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      local transparent = ok and settings.background == "transparent"
      require("nightfox").setup({ options = { transparent = transparent } })
      if settings.theme == "nightfox" then vim.cmd.colorscheme("nightfox") end
    end,
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      local transparent = ok and settings.background == "transparent"
      require("cyberdream").setup({ transparent = transparent })
      if settings.theme == "cyberdream" then vim.cmd.colorscheme("cyberdream") end
    end,
  },
  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      if ok and settings.background == "transparent" then
        vim.g.sonokai_transparent_background = 1
      end
      if settings.theme == "sonokai" then vim.cmd.colorscheme("sonokai") end
    end,
  },
  {
    "marko-cerovac/material.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      if settings.theme == "material" then vim.cmd.colorscheme("material") end
    end,
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      if settings.theme == "oxocarbon" then vim.cmd.colorscheme("oxocarbon") end
    end,
  },
  {
    "tanvirtin/monokai.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      if settings.theme == "monokai" then vim.cmd.colorscheme("monokai") end
    end,
  },
  {
    "transparent-override",
    name = "transparent-override",
    dir = "", -- dummy plugin
    virtual = true,
    lazy = false,
    priority = 1001, -- run after themes
    config = function()
      local ok, settings = pcall(require, "settings")
      if ok and settings.background == "transparent" then
        vim.api.nvim_create_autocmd("ColorScheme", {
          pattern = "*",
          callback = function()
            local hl_groups = {
              "Normal", "NormalNC", "Comment", "Constant", "Special", "Identifier",
              "Statement", "PreProc", "Type", "Underlined", "Todo", "String", "Function",
              "Conditional", "Repeat", "Operator", "Structure", "LineNr", "NonText",
              "SignColumn", "CursorLineNr", "EndOfBuffer", "NormalFloat", "FloatBorder",
              "NvimTreeNormal", "NvimTreeNormalNC", "TelescopeNormal", "TelescopeBorder",
            }
            for _, name in ipairs(hl_groups) do
              vim.cmd(string.format("hi %s ctermbg=NONE guibg=NONE", name))
            end
          end,
        })
      end
    end,
  },
}
