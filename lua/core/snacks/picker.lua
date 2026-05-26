local settings = require("settings")

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
  enabled = true,
  ui_select = true, -- Automatically override vim.ui.select (code actions, etc.)
  win = {
    input = {
      keys = {
        ["<Esc>"] = "close", -- Standard ESC to close
      },
      border = b,
    },
    list = { border = b },
    preview = { border = b },
  },
  layout = l,
  sources = {
    explorer = {
      layout = { preset = "sidebar", width = 40, hidden = { "input" } },
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
}
