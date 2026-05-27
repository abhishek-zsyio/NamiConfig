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

          -- Exclude any Snacks picker windows (in case they are splits)
          local w = vim.w[win]
          if w and (w.snacks_picker_preview or w.snacks_picker_list or w.snacks_picker_input) then
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
    },
    config = function(_, opts)
      require("dropbar").setup(opts)

      -- Fix Dropbar / Winbar theme issues across all colorschemes
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          local function clear_bg(group)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
            if ok and hl then
              hl.bg = nil
              vim.api.nvim_set_hl(0, group, hl)
            end
          end
          
          -- Clear backgrounds so it perfectly blends into the editor
          clear_bg("WinBar")
          clear_bg("WinBarNC")
          clear_bg("DropBarMenuNormalFloat")
          
          -- Ensure the separators match the theme's subtle colors
          vim.api.nvim_set_hl(0, "DropBarIconUIIndicator", { link = "Comment" })
        end,
      })

      -- Globally hide Dropbar on all underlying windows when Snacks Picker is open
      vim.api.nvim_create_autocmd({ "WinEnter", "FileType" }, {
        pattern = "*",
        callback = function()
          local ft = vim.bo.filetype
          if ft and ft:match("^snacks_picker") then
            for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              pcall(vim.api.nvim_set_option_value, "winbar", "", { win = w })
            end
          end
        end,
      })
    end
  }
}
