return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local dashboard = require("alpha.themes.dashboard")

      -- Sleek Minimalist Header
      dashboard.section.header.val = {
        [[                               __                ]],
        [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
        [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
        [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
        [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
        [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
        [[                                                 ]],
      }

      -- Clean, centered buttons with neat spacing
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find File",       ":Telescope find_files<CR>"),
        dashboard.button("n", "  New File",        ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", "  Recent Files",    ":Telescope oldfiles<CR>"),
        dashboard.button("g", "󰊢  Find Text",       ":Telescope live_grep<CR>"),
        dashboard.button("s", "  Settings",        ":e ~/.config/nvim/lua/settings.lua<CR>"),
        dashboard.button("l", "󰒲  Lazy",            ":Lazy<CR>"),
        dashboard.button("q", "  Quit",            ":qa<CR>"),
      }

      -- Modern Highlighting
      dashboard.section.header.opts.hl = "Keyword"
      dashboard.section.buttons.opts.hl = "String"
      dashboard.section.footer.opts.hl = "Comment"

      dashboard.opts.layout = {
        { type = "padding", val = 4 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 2 },
        dashboard.section.footer,
      }

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          local version = vim.version()
          local v_string = "NVIM v" .. version.major .. "." .. version.minor .. "." .. version.patch
          
          dashboard.section.footer.val = {
            "⚡ Neovim loaded " .. stats.loaded .. " plugins in " .. ms .. "ms",
            "",
            v_string,
          }
          pcall(vim.cmd.AlphaRedraw)
        end,
      })

      require("alpha").setup(dashboard.opts)
    end,
  }
}
