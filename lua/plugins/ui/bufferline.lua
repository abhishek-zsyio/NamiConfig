-- Bufferline: polished modern tab bar
return {
  {
    "akinsho/bufferline.nvim",
    version      = "*",
    lazy         = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      -- catppuccin/nvim not needed here; theme system loads it independently
    },
    config = function()
      local ok, settings = pcall(require, "settings")
      if not ok then settings = {} end

      require("bufferline").setup({
        options = {
          mode            = "buffers",
          numbers         = "none",
          close_command   = function(n) Snacks.bufdelete(n) end,
          right_mouse_command = function(n) Snacks.bufdelete(n) end,
          indicator       = { style = "none" },
          buffer_close_icon = "",
          modified_icon     = "●",
          close_icon        = "",
          left_trunc_marker  = "",
          right_trunc_marker = "",
          max_name_length   = 18,
          max_prefix_length = 15,
          truncate_names    = true,
          tab_size          = 18,
          diagnostics       = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local icons = { error = " ", warning = " ", info = " " }
            return (icons[level] or "") .. count
          end,
          color_icons       = true,
          show_buffer_icons = true,
          show_buffer_close_icons = false,
          show_close_icon   = true,
          show_tab_indicators = false,
          separator_style   = (function()
            local s = settings.tab_divider_style or "thin"
            if s == "none" then return { "", "" } end
            if s == "dotted" then return { "·", "·" } end
            return s
          end)(),
          always_show_bufferline = settings.hide_empty_tabline == false,
          custom_filter = function(buf_number)
            if vim.api.nvim_buf_get_name(buf_number) == "" then return false end
            local ft = vim.bo[buf_number].filetype
            local bt = vim.bo[buf_number].buftype
            if ft == "toggleterm" or bt == "terminal" or ft:match("snacks") then
              return false
            end
            return true
          end,
          hover = { enabled = true, delay = 150, reveal = { "close" } },
          offsets = {
            {
              filetype   = "snacks_layout_box",
              text       = "",
              separator  = true,
            },
            {
              filetype   = "snacks_picker_list",
              text       = "",
              separator  = true,
            },
            {
              filetype   = "snacks_picker_input",
              text       = "",
              separator  = true,
            }
          },
        },
      })

      -- Ensure Bufferline respects transparent backgrounds across all themes
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          -- Defer slightly to ensure Bufferline has already reacted and generated its highlights
          vim.defer_fn(function()
            local function clear_bg(group)
              local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
              if ok and hl then
                hl.bg = nil
                vim.api.nvim_set_hl(0, group, hl)
              end
            end
            
            -- Clear backgrounds of all BufferLine components to make it completely transparent
            local hls = vim.fn.getcompletion("BufferLine", "highlight")
            for _, hl_name in ipairs(hls) do
              clear_bg(hl_name)
            end
            clear_bg("TabLineFill")
          end, 50)
        end,
      })
    end,
  },
}
