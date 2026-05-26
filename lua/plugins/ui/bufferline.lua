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
          separator_style   = "none",
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
    end,
  },
}
