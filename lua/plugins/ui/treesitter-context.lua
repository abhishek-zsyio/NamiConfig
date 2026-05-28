-- Treesitter Context: Sticky headers for functions and classes
return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      enable = true,
      max_lines = 3,            -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 20, -- Maximum number of lines to show for a single context
      trim_scope = "outer",     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = "cursor",          -- Line used to calculate context. Choices: 'cursor', 'topline'
      separator = "─",          -- visible rule between context and code
      zindex = 20,              -- The Z-index of the context window
      on_attach = nil,          -- (fun(buf: integer): boolean) return false to disable attaching
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)
      
      -- Sleek custom highlights for the context bar so it pops elegantly
      vim.api.nvim_set_hl(0, "TreesitterContext", { link = "CursorLine" })
      vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { link = "CursorLineNr" })
      vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { link = "FloatBorder" })

      -- Re-apply on colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "TreesitterContext", { link = "CursorLine" })
          vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { link = "CursorLineNr" })
          vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { link = "FloatBorder" })
        end,
      })
    end,
  },
}
