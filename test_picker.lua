local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local themes = { "catppuccin", "onedark", "tokyonight", "gruvbox" }
local current_theme = vim.g.colors_name or "catppuccin"

pickers.new({}, {
  prompt_title = "Select Theme",
  finder = finders.new_table({ results = themes }),
  sorter = conf.generic_sorter({}),
  attach_mappings = function(prompt_bufnr, map)
    local function live_preview()
      local selection = action_state.get_selected_entry()
      if selection then
        pcall(vim.cmd.colorscheme, selection[1])
      end
    end

    map("i", "<C-j>", function()
      actions.move_selection_next(prompt_bufnr)
      live_preview()
    end)
    map("i", "<C-k>", function()
      actions.move_selection_previous(prompt_bufnr)
      live_preview()
    end)

    map("i", "<Esc>", function()
      pcall(vim.cmd.colorscheme, current_theme)
      actions.close(prompt_bufnr)
    end)

    actions.select_default:replace(function()
      actions.close(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      if selection then
        print("Selected", selection[1])
      end
    end)

    return true
  end,
}):find()
