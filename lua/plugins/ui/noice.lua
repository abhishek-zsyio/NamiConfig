-- Noice: polished UI with aggressive filtering of annoying messages
return {
  {
    "folke/noice.nvim",
    event        = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    keys = {
      { "<leader>nh", "<cmd>Noice history<cr>",  desc = "Noice message history" },
      { "<leader>nd", "<cmd>Noice dismiss<cr>",  desc = "Dismiss Noice messages" },
      { "<leader>nl", "<cmd>Noice last<cr>",     desc = "Show last message" },
    },
    opts = {
      cmdline = {
        enabled = true,
        view    = "cmdline_popup",
      },
      messages  = { enabled = true },
      popupmenu = { enabled = true, backend = "nui" },

      views = {
        cmdline_popup = {
          position = { row = "97%", col = "50%" },
          size     = { width = 60, height = "auto" },
          border   = { style = "rounded", padding = { 0, 1 } },
        },
        mini = {
          timeout  = 2000,
          reverse  = false,
          position = { row = -2, col = -2 },
        },
      },

      notify = { enabled = false },   -- Snacks notifier handles notifications

      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"]                = true,
          ["cmp.entry.get_documentation"]                  = true,
        },
        progress = {
          enabled     = true,
          format      = "lsp_progress",
          format_done = "lsp_progress_done",
          throttle    = 1000 / 30,
          view        = "mini",
        },
      },

      -- ── Route filters: silence common noise ────────────────────────────────
      routes = {
        -- Silence Pyright LSP progress spam
        {
          filter = {
            event = "lsp", kind = "progress",
            cond  = function(msg)
              return vim.tbl_get(msg.opts, "progress", "client") == "pyright"
            end,
          },
          opts = { skip = true },
        },
        -- Written/read file byte-count messages
        { filter = { event = "msg_show", find = "%d+L, %d+B" },             opts = { skip = true } },
        { filter = { event = "msg_show", find = "; after #%d+" },           opts = { skip = true } },
        { filter = { event = "msg_show", find = "; before #%d+" },          opts = { skip = true } },
        { filter = { event = "msg_show", find = "%d fewer lines" },          opts = { skip = true } },
        { filter = { event = "msg_show", find = "%d more lines" },           opts = { skip = true } },
        { filter = { event = "msg_show", find = "already at newest change" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "^/" },                      opts = { skip = true } },
        -- Plugin spam
        { filter = { event = "notify",   find = "vim%.notify" },             opts = { skip = true } },
        { filter = { event = "msg_show", find = "vim%.notify" },             opts = { skip = true } },
        { filter = { find  = "overwritten by another plugin" },              opts = { skip = true } },
        { filter = { event = "notify",   find = "Config Change Detected" },  opts = { skip = true } },
        { filter = { event = "notify",   find = "Reloading" },               opts = { skip = true } },
        { filter = { event = "notify",   find = "lualine" },                 opts = { skip = true } },
        { filter = { event = "notify",   find = "mason%-lspconfig" },        opts = { skip = true } },
      },

      presets = {
        bottom_search         = true,
        command_palette       = true,
        long_message_to_split = true,
        inc_rename            = false,
        lsp_doc_border        = true,
      },
    },
  },
}
