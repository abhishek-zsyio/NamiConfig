local settings = require("settings")

-- Map settings.picker_layout to Snacks picker presets
local layout_map = {
  horizontal = "default",
  vertical = "vertical",
  telescope = "telescope",
  ivy = "ivy",
  dropdown = "dropdown",
  vscode = "vscode"
}

local preset = layout_map[settings.picker_layout] or settings.picker_layout or "telescope"

local l = {
  preset = preset,
  width = settings.picker_width or 0.85,
  height = settings.picker_height or 0.8,
  -- 60% opacity dark backdrop to make the floating picker pop beautifully
  backdrop = 60,
}

return {
  enabled = true,
  ui_select = true, -- Automatically override vim.ui.select (code actions, etc.)
  win = {
    -- Set the border for layout boxes and default windows
    border = settings.menu_border or "rounded",
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
      layout = {
        preset = "sidebar",
        layout = { position = settings.file_explorer_position or "left" },
        width = 32,
        hidden = { "input" },
      },
      win = {
        list = {
          border = "none",
          winhighlight = "Normal:TabLine,NormalNC:TabLine,FloatBorder:TabLine",
          keys = { ["<C-n>"] = "close" },
        },
      },
      hidden = settings.show_hidden_files ~= false,
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
