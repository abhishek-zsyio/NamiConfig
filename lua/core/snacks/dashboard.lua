-- Snacks Dashboard — Catppuccin Mocha optimized
local ok, settings = pcall(require, "settings")
local current_theme = ok and settings.ui and settings.ui.theme or "catppuccin-mocha"

return {
  preset = {
    header = [[

  ██████╗ ███████╗██╗   ██╗
  ██╔══██╗██╔════╝██║   ██║
  ██║  ██║█████╗  ██║   ██║
  ██║  ██║██╔══╝  ╚██╗ ██╔╝
  ██████╔╝███████╗ ╚████╔╝
  ╚═════╝ ╚══════╝  ╚═══╝

  ✦  Precision. Performance. Flow.  ✦
    ]],

    keys = {
      { icon = "󰍉 ", key = "f", desc = "Find File",       action = ":lua Snacks.picker.files()" },
      { icon = "󰝒 ", key = "n", desc = "New File",        action = ":ene | startinsert" },
      { icon = "󰊄 ", key = "g", desc = "Live Grep",       action = ":lua Snacks.picker.grep()" },
      { icon = "󱋡 ", key = "r", desc = "Recent Files",    action = ":lua Snacks.picker.recent()" },
      { icon = "󰦛 ", key = "p", desc = "Restore Session", action = ":lua require('persistence').load()" },
      { icon = "󰒓 ", key = "s", desc = "Settings",        action = ":e " .. vim.fn.stdpath("config") .. "/lua/settings.lua" },
      { icon = "󰩈 ", key = "q", desc = "Quit",            action = ":qa" },
    },
  },

  formats = {
    footer = { "%s", align = "center" },
    header = { "%s", align = "center" },
    key    = { "%s", hl = "SnacksDashboardKey" },
  },

  sections = {
    { section = "header" },
    { section = "keys", gap = 1, padding = 1 },
    {
      section = "terminal",
      cmd     = string.format(
        "echo '  Neovim %s  ·  %s plugins  ·  %s'",
        vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch,
        #vim.tbl_keys(require("lazy").plugins()),
        current_theme
      ),
      hl      = "SnacksDashboardFooter",
      padding = 1,
      indent  = 6,
    },
  },
}
