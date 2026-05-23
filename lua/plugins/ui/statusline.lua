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
          theme                = "auto",   -- Dynamically match the current Neovim theme
          globalstatus         = true,     -- Single bar across all windows (VS Code style)
          always_divide_middle = true,
          -- Remove all bubbles and powerline separators for a flat, modern VS Code look
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          disabled_filetypes   = { statusline = { "dashboard", "alpha" } },
        },
        sections = {
          -- Left Side: Mode, Branch, Diagnostics (Errors/Warnings)
          lualine_a = {
            { "mode", fmt = function(str) return " " .. str .. " " end },
          },
          lualine_b = {
            { "branch", icon = "" },
            {
              "diagnostics",
              sources = { "nvim_lsp" },
              symbols = { error = " ", warn = " ", hint = " ", info = " " },
            },
          },
          -- Middle: Filename
          lualine_c = {
            {
              "filename",
              path    = 1,
              symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
            },
          },
          -- Right Side: Encoding, Format, Language, Line/Col
          lualine_x = {
            { "encoding" },
            { "fileformat" },
            { "filetype", icon_only = false },
          },
          lualine_y = {
            -- Format location to look exactly like VS Code: "Ln X, Col Y"
            { "location", fmt = function(str)
                local line = vim.fn.line(".")
                local col = vim.fn.col(".")
                return string.format("Ln %d, Col %d", line, col)
              end 
            }
          },
          lualine_z = {}, -- Empty like VS Code
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
