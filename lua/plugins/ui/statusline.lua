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
          lualine_a = {
            { "mode", icon = "" },
          },
          lualine_b = {
            { "filename", path = 0, symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" } },
            { "branch", icon = "" },
            {
              "diagnostics",
              sources = { "nvim_lsp" },
              symbols = { error = " ", warn = " ", hint = " ", info = " " },
            },
          },
          lualine_c = {},
          lualine_x = {
            { "diff", symbols = { added = " ", modified = " ", removed = " " } },
            { function() return "|" end, color = { fg = "#504945" }, padding = { left = 1, right = 1 } },
            { "location", fmt = function() return string.format("Ln %d, Col %d", vim.fn.line("."), vim.fn.col(".")) end },
            { "encoding" },
            { "filetype", icon_only = false },
            {
              function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if next(clients) == nil then return "" end
                local c = {}
                for _, client in ipairs(clients) do
                  table.insert(c, client.name)
                end
                return " " .. table.concat(c, "|")
              end,
              color = { fg = "#a6e3a1", gui = "bold" }
            },
          },
          lualine_y = {},
          lualine_z = {
            { function() return " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") end },
          },
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
