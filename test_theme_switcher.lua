local function test_theme_switcher()
  local ok_telescope, pickers = pcall(require, "telescope.pickers")
  if not ok_telescope then
    vim.notify("Telescope not found!", vim.log.levels.ERROR)
    return
  end
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local themes = { "catppuccin", "onedark", "tokyonight", "gruvbox" }
  local current_theme = vim.g.colors_name or "catppuccin"

  pickers.new({}, {
    prompt_title = "Select Theme",
    finder = finders.new_table({
      results = themes,
      entry_maker = function(entry)
        local icons = { catppuccin = "󰄛 ", onedark = "󰏘 ", tokyonight = "󰖔 ", gruvbox = "󰟆 " }
        return { value = entry, display = (icons[entry] or "󰏘 ") .. " " .. entry, ordinal = entry }
      end
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local function live_preview()
        local selection = action_state.get_selected_entry()
        if selection then pcall(vim.cmd.colorscheme, selection.value) end
      end

      map("i", "<C-j>", function() actions.move_selection_next(prompt_bufnr) live_preview() end)
      map("i", "<C-k>", function() actions.move_selection_previous(prompt_bufnr) live_preview() end)
      map("i", "<Down>", function() actions.move_selection_next(prompt_bufnr) live_preview() end)
      map("i", "<Up>", function() actions.move_selection_previous(prompt_bufnr) live_preview() end)

      local function restore_and_close()
        pcall(vim.cmd.colorscheme, current_theme)
        actions.close(prompt_bufnr)
      end
      map("i", "<Esc>", restore_and_close)
      map("n", "<Esc>", restore_and_close)

      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then print("Selected " .. selection.value) end
      end)
      return true
    end,
  }):find()
end
