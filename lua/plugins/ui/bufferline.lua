-- Bufferline: polished modern tab bar
return {
  {
    "akinsho/bufferline.nvim",
    version      = "*",
    lazy         = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "catppuccin/nvim",
    },
    config = function()
      local ok, settings = pcall(require, "settings")
      if not ok then settings = {} end

      require("bufferline").setup({
        options = {
          mode            = "buffers",
          numbers         = "none",
          close_command   = function(n) require("mini.bufremove").delete(n, false) end,
          right_mouse_command = "vertical sbuffer %d",
          indicator       = { style = "none" },  -- Minimal: no bold underline
          buffer_close_icon = "󰅖",
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
          show_buffer_close_icons = false, -- Minimal: hide close icons per buffer
          show_close_icon   = false,
          show_tab_indicators = true,
          separator_style   = "thin",  -- Added a thin divider between tabs
          always_show_bufferline = settings.hide_empty_tabline == false,  -- Hide tabline if no files (or only 1) are open
          custom_filter = function(buf_number)
            -- Filter out completely empty/unnamed buffers
            if vim.api.nvim_buf_get_name(buf_number) == "" then
              return false
            end
            return true
          end,
          hover = { enabled = true, delay = 150, reveal = { "close" } },
          offsets = {
            {
              filetype   = "NvimTree",
              text       = "",
              separator  = false,
            },
          },
        },
      })
    end,
  },
}
