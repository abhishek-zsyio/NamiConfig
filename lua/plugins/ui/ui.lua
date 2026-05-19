return {
  -- Markdown Rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {},
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  },

  -- Discord Rich Presence
  {
    "IogaMaster/neocord",
    event = "VeryLazy",
    opts = {
      logo = "auto",
      main_image = "language",
      show_time = true,
      global_timer = false,
      editing_text = "Editing %s",
      file_explorer_text = "Browsing %s",
      git_commit_text = "Committing changes",
      plugin_manager_text = "Managing plugins",
      reading_text = "Reading %s",
      workspace_text = "Working on %s",
    },
  },

  -- Code Screenshot Utility
  {
    "michaelrommel/nvim-silicon",
    lazy = true,
    cmd = "Silicon",
    config = function()
      require("silicon").setup {
        font         = "JetBrainsMono NFM=15;Noto Color Emoji=15",
        theme        = "gruvbox-dark",
        to_clipboard = true,
        background   = "#8D6479",
        output       = "~/Pictures/Screenshots/code.png",
        window_title = function()
          return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":t")
        end,
      }
    end,
  },
}
