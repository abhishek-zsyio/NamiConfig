return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local dashboard = require("alpha.themes.dashboard")

      -- Premium Custom Header for NamiConfig
      dashboard.section.header.val = {
        [[                                                               ]],
        [[    _   __               _ ______           _____          ]],
        [[   / | / /___ _____ ___  (_) ____/___  ____  / __/(_)___ _   ]],
        [[  /  |/ / __ `/ __ `__ \/ / /   / __ \/ __ \/ /_/ / / __ `/  ]],
        [[ / /|  / /_/ / / / / / / / /___/ /_/ / / / / __/ / / /_/ /   ]],
        [[/_/ |_/\__,_/_/ /_/ /_/_/\____/\____/_/ /_/_/ /_/_/\__, /    ]],
        [[                                                  /____/     ]],
        [[                                                               ]]
      }

      -- Clean, centered buttons with NamiConfig specific shortcuts
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file",       ":Telescope find_files<CR>"),
        dashboard.button("n", "  New file",        ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", "  Recent files",    ":Telescope oldfiles<CR>"),
        dashboard.button("s", "  Settings",        ":e ~/.config/nvim/lua/settings.lua<CR>"),
        dashboard.button("t", "  Change Theme",    ":lua vim.api.nvim_feedkeys(' th', 'm', false)<CR>"),
        dashboard.button("q", "  Quit",            ":qa<CR>"),
      }

      -- Styling
      dashboard.section.header.opts.hl = "Keyword"
      dashboard.section.buttons.opts.hl = "Function"
      dashboard.section.footer.opts.hl = "Comment"

      -- Footer text
      local version = vim.version()
      local v_string = "NamiConfig ⚡ NVIM v" .. version.major .. "." .. version.minor .. "." .. version.patch
      dashboard.section.footer.val = { "", "", v_string }

      require("alpha").setup(dashboard.opts)
    end,
  }
}
