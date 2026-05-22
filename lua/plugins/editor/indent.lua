-- Indent Blankline: Minimal VS Code style
return {
  {
    "lukas-reineke/indent-blankline.nvim",
    event        = { "BufReadPost", "BufNewFile" },
    main         = "ibl",
    dependencies = { "catppuccin/nvim" },
    config = function()
      local hooks = require("ibl.hooks")
      -- Define a custom vibrant blue highlight for the active scope (like in the image)
      -- We must use a hook so the color isn't erased when you switch themes!
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "IblActiveScope", { fg = "#3b82f6", bold = true })
      end)

      require("ibl").setup({
        indent = {
          char       = "│",  -- Prominent vertical line for all indents
          tab_char   = "│",
        },
        scope = {
          enabled     = true,
          show_start  = false,
          show_end    = false,
          char        = "│",  -- Same prominent vertical line for the active scope
          highlight   = "IblActiveScope", -- Vibrant blue color to match the image exactly
        },
        exclude = {
          filetypes = {
            "help", "dashboard", "NvimTree", "Trouble",
            "lazy", "mason", "notify", "toggleterm", "lazyterm",
          },
        },
      })
    end,
  },
}
