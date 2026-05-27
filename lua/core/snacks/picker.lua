local settings = require("settings")

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
      border = settings.menu_border or "rounded",
    },
    list = { border = settings.menu_border or "rounded" },
    preview = { border = settings.menu_border or "rounded" },
  },
  layout = l,
  sources = {
    explorer = {
      layout = { preset = "sidebar", width = 40, hidden = { "input" } },
      win = { list = { keys = { ["<C-n>"] = "close" } } },
      hidden = true,
    },
    files = { layout = l, hidden = true },
    grep = { layout = l, hidden = true },
    buffers = { layout = l },
    help = { layout = l },
    recent = { layout = l },
    lines = { layout = l },
    marks = { layout = l },
    git_status = { layout = l },
    git_log = { layout = l },
    git_diff = { layout = l },
    git_branches = { layout = l },
    diagnostics = { layout = l },
  }
}
