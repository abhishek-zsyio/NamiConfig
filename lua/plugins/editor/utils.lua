-- Editor utilities: auto-save, hyprland syntax, Python venv selector
return {
  -- Auto Save
  {
    "okuuva/auto-save.nvim",
    cmd   = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    opts  = {
      enabled      = true,
      trigger_events = {
        immediate_save    = { "BufLeave", "FocusLost" },
        defer_save        = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
      condition          = nil,
      write_all_buffers  = false,
      noautocmd          = false,
      lockmarks          = false,
      debounce_delay     = 1000,
      debug              = false,
    },
  },

  -- Python Virtual Environment Selector
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      "mfussenegger/nvim-dap-python",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("venv-selector").setup({
        options = {
          override_notify = false,
        }
      })
    end,
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<CR>", desc = "Select Python venv" },
    },
  },

  -- Hyprland Syntax Highlighting
  {
    "theRealCarneiro/hyprland-vim-syntax",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = "hypr",
  },
}
