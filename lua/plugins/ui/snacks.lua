local settings = require("settings")

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- Modules
      zen = { enabled = true },
      dim = { enabled = true },
      explorer = { enabled = true },
      indent = { 
        enabled = true,
        indent = {
          char = "│",
          hl = "SnacksIndent",
        },
        scope = {
          enabled = true,
          char = "┃",
          underline = false,
          only_current = false,
          hl = "SnacksIndentScope",
        },
        chunk = {
          enabled = true,
          char = {
            corner_top = "┌",
            corner_bottom = "└",
            horizontal = "─",
            vertical = "│",
            arrow = "►",
          },
          hl = "SnacksIndentChunk",
        },
        animate = {
          enabled = true,
          style = "out",
          easing = "linear",
          duration = {
            step = 20,
            total = 500,
          },
        },
      },
      bufdelete = { enabled = true },
      scroll = { enabled = true },
      scratch = { enabled = true },
      notifier = { 
        enabled = true,
        timeout = 3000,
        width = { min = 40, max = 0.4 },
        height = { min = 1, max = 0.6 },
        margin = { top = 1, right = 1, bottom = 0 },
        padding = true,
        sort = { "level", "added" },
        level = vim.log.levels.TRACE,
        icons = {
          error = " ",
          warn = " ",
          info = " ",
          debug = " ",
          trace = " ",
        },
        style = "compact",
        top_down = true,
      },
      words = { enabled = true },
      terminal = { 
        enabled = true,
        win = {
          wo = {
            winbar = "",
            statuscolumn = "  ",
          },
        },
      },
      lazygit = { enabled = true },
      gitbrowse = { enabled = true },
      rename = { enabled = true },
      input = { enabled = true },
      quickfile = { enabled = true },
      image = { 
        enabled = true,
        force = true,
        formats = {
          "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic", "avif",
          "mp4", "mov", "avi", "mkv", "webm", "pdf", "icns", "svg"
        },
        convert = { notify = true }, -- Show errors if imagemagick fails
      },

      picker = {
        enabled = true,
        ui_select = true, -- Automatically override vim.ui.select (code actions, etc.)
        win = {
          input = {
            keys = {
              ["<Esc>"] = "close", -- Standard ESC to close
            },
            border = settings.menu_border or "rounded",
          },
          list = { border = settings.menu_border or "rounded" },
          preview = { border = settings.menu_border or "rounded" },
        },
        layout = {
          preset = settings.picker_layout or "telescope",
          width = settings.picker_width or 0.85,
          height = settings.picker_height or 0.8,
        },
        sources = (function()
          local b = settings.menu_border or "rounded"
          local w = {
            input = { border = b },
            list = { border = b },
            preview = { border = b }
          }
          local l = {
            preset = settings.picker_layout or "telescope",
            width = settings.picker_width or 0.85,
            height = settings.picker_height or 0.8,
          }
          return {
            explorer = {
              layout = { preset = "sidebar", width = 40 },
              win = { list = { keys = { ["<C-n>"] = "close" } } }
            },
            files = { layout = l, win = w },
            grep = { layout = l, win = w },
            buffers = { layout = l, win = w },
            help = { layout = l, win = w },
            recent = { layout = l, win = w },
            lines = { layout = l, win = w },
            marks = { layout = l, win = w },
            git_status = { layout = l, win = w },
            git_log = { layout = l, win = w },
            git_diff = { layout = l, win = w },
            git_branches = { layout = l, win = w },
            diagnostics = { layout = l, win = w },
          }
        end)()
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
