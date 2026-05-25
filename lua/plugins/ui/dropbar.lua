return {
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      bar = {
        enable = function(buf, win)
          if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
            return false
          end
          
          -- Natively exclude all floating/popup windows
          local config = vim.api.nvim_win_get_config(win)
          if config.relative ~= "" or config.external then
            return false
          end

          -- Natively exclude non-regular buffers (terminal, prompt, etc.)
          local bt = vim.bo[buf].buftype
          if bt ~= "" then
            return false
          end

          -- Natively exclude empty/unnamed buffers
          if vim.api.nvim_buf_get_name(buf) == "" then
            return false
          end

          -- Exclude filetypes
          local ft = vim.bo[buf].filetype
          local exclude_ft = {
            "snacks_picker_list",
            "snacks_picker_input",
            "snacks_picker_preview",
            "snacks_layout_box",
            "snacks_terminal",
            "alpha",
            "dashboard",
            "NvimTree",
            "neo-tree",
            "Trouble",
            "lazy",
            "mason",
            "notify",
            "qf",
            "help",
            "gitsigns-blame",
          }
          if vim.tbl_contains(exclude_ft, ft) then
            return false
          end
          return true
        end,
      },
      icons = {
        enable = true,
        kinds = {
          dir = "󰉋 ",
          file = "󰈙 ",
          ui = {
            bar = {
              separator = "  ",
              extends = "…",
            },
            menu = {
              separator = " ",
              indicator = " ",
            },
          },
        },
      },
    }
  }
}
