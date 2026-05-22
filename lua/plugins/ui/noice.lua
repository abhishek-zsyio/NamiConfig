-- Noice: polished UI with aggressive filtering of annoying messages
return {
  {
    "folke/noice.nvim",
    event        = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      {
        "rcarriga/nvim-notify",
        opts = {
          timeout    = 2000,
          max_height = function() return math.floor(vim.o.lines * 0.75) end,
          max_width  = function() return math.floor(vim.o.columns * 0.75) end,
          on_open    = function(win)
            vim.api.nvim_win_set_config(win, { zindex = 100 })
          end,
          background_colour = "#000000",
          render  = "wrapped-compact",
          stages  = "fade",
          icons   = { ERROR = " ", WARN = " ", INFO = " " },
          -- Minimum level to show — hide WARN and below from noisy sources
          minimum_width = 10,
          top_down = false,   -- show newest at bottom (less intrusive)
        },
      },
    },
    opts = {
      cmdline = {
        enabled  = true,
        view     = "cmdline_popup",
      },
      messages = { enabled = true },
      popupmenu = { enabled = true, backend = "nui" },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"]                = true,
          ["cmp.entry.get_documentation"]                  = true,
        },
        progress = {
          enabled = true,
          format  = "lsp_progress",
          format_done = "lsp_progress_done",
          throttle    = 1000 / 30,
          view        = "mini",
        },
      },
      -- ── Route filters: silence common noise ──────────────────────────────
      routes = {
        -- Skip written/read file messages ("14L, 42B")
        { filter = { event = "msg_show", find = "%d+L, %d+B" },           opts = { skip = true } },
        { filter = { event = "msg_show", find = "; after #%d+" },          opts = { skip = true } },
        { filter = { event = "msg_show", find = "; before #%d+" },         opts = { skip = true } },
        { filter = { event = "msg_show", find = "%d fewer lines" },         opts = { skip = true } },
        { filter = { event = "msg_show", find = "%d more lines" },          opts = { skip = true } },
        { filter = { event = "msg_show", find = "already at newest change" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "^/" },                    opts = { skip = true } }, -- search count
        -- Silence lazy.nvim "Config Change Detected / Reloading" spam
        { filter = { event = "notify", find = "Config Change Detected" },  opts = { skip = true } },
        { filter = { event = "notify", find = "Reloading" },               opts = { skip = true } },
        -- Silence lualine notices
        { filter = { event = "notify", find = "lualine" },                 opts = { skip = true } },
        -- Silence mason-lspconfig warnings about server names
        { filter = { event = "notify", find = "mason%-lspconfig" },        opts = { skip = true } },
        -- Silence nvim-tree deprecation warnings
        { filter = { event = "notify", find = "NvimTree" },                opts = { skip = true } },
        -- Send long messages to split instead of popup
        {
          filter = { event = "msg_show", min_height = 5 },
          view   = "split",
        },
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
