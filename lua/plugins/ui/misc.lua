-- Misc UI: icons, devicons, inline colors, markdown render, discord, code screenshot
return {
  -- Core icon sets
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "echasnovski/mini.icons", version = false },

  -- Inline color highlighting
  {
    "norcalli/nvim-colorizer.lua",
    event  = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        "*",                  -- apply to all filetypes
        css    = { rgb_fn = true, hsl_fn = true, names = true },
        html   = { names = true },
        javascript = { names = false },
        typescript = { names = false },
      }, { mode = "background" })
    end,
  },

  -- Markdown rendering inside Neovim
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft           = { "markdown", "norg", "rmd", "org" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts         = {},
  },

  -- Code screenshot
  {
    "michaelrommel/nvim-silicon",
    lazy = true,
    cmd  = "Silicon",
    config = function()
      require("silicon").setup({
        font          = "JetBrainsMono NFM=15;Noto Color Emoji=15",
        theme         = "gruvbox-dark",
        to_clipboard  = true,
        background    = "#8D6479",
        output        = "~/Pictures/Screenshots/code.png",
        window_title  = function()
          return vim.fn.fnamemodify(
            vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":t"
          )
        end,
      })
    end,
  },

  -- Discord rich presence
  {
    "IogaMaster/neocord",
    event = "VeryLazy",
    opts  = {
      logo            = "auto",
      main_image      = "language",
      show_time       = true,
      global_timer    = false,
      editing_text    = "Editing %s",
      file_explorer_text = "Browsing %s",
      workspace_text  = "Working on %s",
    },
  },

  -- Markdown preview
  {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    keys  = {
      {
        "<leader>op",
        function()
          local peek = require("peek")
          if peek.is_open() then peek.close() else peek.open() end
        end,
        desc = "Toggle Markdown Preview",
      },
    },
    opts = { theme = "dark" },
  },

  -- Buffer delete without closing windows (required for <leader>x)
  {
    "echasnovski/mini.bufremove",
    version = false,
    lazy    = true,
  },

  -- Which-key: show keybinding hints on leader press
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = {
      plugins = { spelling = { enabled = true, suggestions = 20 } },
      win  = { border = "rounded" },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>f",  group = "Find/Files" },
        { "<leader>g",  group = "Git" },
        { "<leader>l",  group = "LSP" },
        { "<leader>d",  group = "Debug/DAP" },
        { "<leader>u",  group = "UI" },
      })
    end,
  },
}
