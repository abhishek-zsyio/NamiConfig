-- Indent Blankline: Minimal VS Code style
return {
  {
    "lukas-reineke/indent-blankline.nvim",
    event        = { "BufReadPost", "BufNewFile" },
    main         = "ibl",
    dependencies = { "catppuccin/nvim" },
    config = function()
      require("ibl").setup({
        indent = {
          char       = "│",
          tab_char   = "│",
        },
        scope = {
          enabled   = true,
          show_start = false,
          show_end   = false,
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
