return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = (function()
      local opts = require("nami.snacks.opts")
      opts.picker = require("nami.snacks.picker")
      opts.dashboard = require("nami.snacks.dashboard")
      return opts
    end)(),
    keys = {
      -- Terminal
      { "<C-`>", function() Snacks.terminal(nil, { count = 1, win = { position = "float" } }) end, mode = { "n", "t" }, desc = "Toggle Terminal" },
      { "<A-h>", function() Snacks.terminal(nil, { count = 2, win = { position = "bottom", height = 15 } }) end, mode = { "n", "t" }, desc = "Toggle Terminal (Bottom)" },
      { "<A-v>", function() Snacks.terminal(nil, { count = 3, win = { position = "right", width = 0.4 } }) end, mode = { "n", "t" }, desc = "Toggle Terminal (Right)" },

      -- UI / Toggles
      { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>cn", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },

      -- Buffers
      { "<leader>x", function() Snacks.bufdelete() end, desc = "Delete Buffer" },

      -- Explorer
      { "<leader>e", function()
          local explorers = Snacks.picker.get({ source = "explorer" }) or {}
          local explorer = explorers[1]
          if explorer then
            explorer:focus()
          else
            Snacks.explorer()
          end
        end, desc = "Open Explorer" },
      { "<C-n>", function() Snacks.explorer() end, desc = "Toggle Explorer" },

      -- Picker (Replacing Telescope)
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>fw", function() Snacks.picker.grep() end, desc = "Live Grep" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Find Buffers" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>fo", function() Snacks.picker.recent() end, desc = "Recent Files" },
      { "<leader>fz", function() Snacks.picker.lines() end, desc = "Fuzzy in Buffer" },
      { "<leader>ma", function() Snacks.picker.marks() end, desc = "Find Marks" },
      
      -- Git
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File" },
      { "<leader>gt", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gc", function() Snacks.picker.git_log() end, desc = "Git Commits" },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diffs" },
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
      { "<leader>gB", function() Snacks.gitbrowse() end, mode = { "n", "x" }, desc = "Git Browse (GitHub/GitLab)" },

      -- Diagnostics
      { "<leader>ds", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    },
  }
}
