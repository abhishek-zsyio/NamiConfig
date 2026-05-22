-- Lualine: NvChad-style statusline — always visible, catppuccin-coloured
return {
  {
    "nvim-lualine/lualine.nvim",
    lazy         = false,          -- load immediately so bar shows from start
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "catppuccin/nvim",
    },
    config = function()
      require("lualine").setup({
        options = {
          theme                = "catppuccin-mocha",
          globalstatus         = true,   -- single bar across all windows
          always_divide_middle = true,
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          -- only hide statusline for the dashboard, NOT NvimTree
          disabled_filetypes   = { statusline = { "dashboard", "alpha" } },
        },
        sections = {
          lualine_a = {
            { "mode", fmt = function(str) return " " .. str end },
          },
          lualine_b = {
            { "branch", icon = "" },
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
              diff_color = {
                added    = { fg = "#a6e3a1" },
                modified = { fg = "#f9e2af" },
                removed  = { fg = "#f38ba8" },
              },
            },
          },
          lualine_c = {
            {
              "filename",
              path    = 1,
              symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
            },
          },
          lualine_x = {
            {
              "diagnostics",
              sources = { "nvim_lsp" },
              symbols = { error = " ", warn = " ", hint = " ", info = " " },
            },
            { "filetype", icon_only = false },
            { "encoding" },
          },
          lualine_y = { { "progress" } },
          lualine_z = { { "location" } },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "lazy", "mason" },
      })
    end,
  },
}
