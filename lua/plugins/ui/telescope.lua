-- Telescope: borderless vertical layout (matching NvChad's style)
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd          = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond  = function() return vim.fn.executable("make") == 1 end,
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions   = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix    = "   ",
          selection_caret  = "  ",
          entry_prefix     = "   ",
          initial_mode     = "insert",
          selection_strategy = "reset",
          sorting_strategy   = "ascending",
          layout_strategy    = "horizontal",
          layout_config = {
            vertical = {
              prompt_position = "top",
              mirror          = true,
              width           = 0.87,
              height          = 0.80,
              preview_cutoff  = 40,
            },
            horizontal = {
              prompt_position = "top",
              width           = 0.87,
              height          = 0.80,
              preview_width   = 0.55,
            },
          },
          border           = {},
          borderchars      = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          color_devicons   = true,
          file_ignore_patterns = { "node_modules", ".git/" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = {
            hidden     = true,
            find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
          },
        },
        extensions = {
          fzf = {
            fuzzy                   = true,
            override_generic_sorter = true,
            override_file_sorter    = true,
            case_mode               = "smart_case",
          },
        },
      })

      pcall(telescope.load_extension, "fzf")
    end,
  },
}
