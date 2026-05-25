return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- Modules
      dashboard = { enabled = true },
      zen = { enabled = true },
      dim = { enabled = true },
      picker = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      bufdelete = { enabled = true },
      scroll = { enabled = true },
      scratch = { enabled = true },
      notifier = { enabled = true },
      words = { enabled = true },
      image = { 
        enabled = true,
        force = true, -- Force rendering for Ghostty (useful if inside tmux or detection fails)
      },

      picker = {
        enabled = true,
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["<C-n>"] = "close",
                }
              }
            }
          }
        }
      },

      -- Custom Dashboard config
      dashboard = {
        preset = {
          header = [[
   _   __               _         
  / | / /___ _____ ___ (_)____    
 /  |/ / __ `/ __ `__ \/ / __ \   
/ /|  / /_/ / / / / / / / / / /   
/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/    
                                  
   Ultimate Dev Environment
          ]],
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
            { icon = " ", key = "p", desc = "Restore Session", action = ":lua require('persistence').load()" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
    keys = {
      -- UI / Toggles
      { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },

      -- Buffers
      { "<leader>x", function() Snacks.bufdelete() end, desc = "Delete Buffer" },

      -- Explorer
      { "<leader>e", function() 
          local explorer = Snacks.picker.get({ source = "explorer" })[1]
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
      { "<leader>gt", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gc", function() Snacks.picker.git_log() end, desc = "Git Commits" },

      -- Diagnostics
      { "<leader>ds", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    },
  }
}
