-- Lualine: Modern sleek aesthetic
return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- Sleek modern separators
      local separators = { left = '', right = '' }

      require("lualine").setup({
        options = {
          theme = "auto", -- dynamically respects theme perfectly
          globalstatus = true,
          component_separators = '',
          section_separators = separators,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "neo-tree" } },
        },
        sections = {
          lualine_a = {
            { "mode", icon = "", separator = { left = '', right = '' }, right_padding = 2 },
          },
          lualine_b = {
            { "filename", symbols = { modified = " ●", readonly = " " } },
            { "branch", icon = "" },
          },
          lualine_c = {
            {
              "diagnostics",
              sources = { "nvim_lsp" },
              symbols = { error = " ", warn = " ", hint = " ", info = " " },
            },
          },
          lualine_x = {
            { "diff", symbols = { added = " ", modified = " ", removed = " " } },
            {
              function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if next(clients) == nil then return "No LSP" end
                local c = {}
                for _, client in ipairs(clients) do
                  table.insert(c, client.name)
                end
                return " " .. table.concat(c, " • ")
              end,
            },
          },
          lualine_y = {
            { "filetype", icon_only = true },
            { "progress" },
          },
          lualine_z = {
            { "location", separator = { right = '', left = '' }, left_padding = 2 },
          },
        },
        inactive_sections = {
          lualine_a = { 'filename' },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { 'location' },
        },
        extensions = { "lazy", "mason" },
      })
    end,
  },
}
