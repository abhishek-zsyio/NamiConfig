-- Catppuccin Mocha with transparency — NvChad's theme
return {
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,
    lazy     = false,
    config   = function()
      require("catppuccin").setup({
        flavour              = "mocha",
        transparent_background = true,
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
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
