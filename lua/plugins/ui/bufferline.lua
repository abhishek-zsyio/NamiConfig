-- Bufferline: polished modern tab bar
return {
  {
    "akinsho/bufferline.nvim",
    version      = "*",
    lazy         = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      -- theme registry loads theme configurations independently
    },
    config = function()
      local ok, settings = pcall(require, "settings")
      if not ok then settings = {} end

      require("bufferline").setup({
        options = {
          mode            = settings.tab_buffer_style or "buffers",
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
          diagnostics       = settings.tab_buffer_diagnostics or "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local icons = { error = " ", warning = " ", info = " " }
            return (icons[level] or "") .. count
          end,
          color_icons       = settings.tab_buffer_show_icons ~= false,
          show_buffer_icons = settings.tab_buffer_show_icons ~= false,
          show_buffer_close_icons = settings.tab_buffer_show_close == true,
          show_close_icon   = settings.tab_buffer_show_close == true,
          show_tab_indicators = false,
          separator_style   = (function()
            if settings.tab_buffer_transparent_dividers == true then
              return { "", "" }
            end
            local s = settings.tab_divider_style or "slope"
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

      -- Sync Bufferline background and separators with the StatusLine background color
      local function sync_bufferline_bg()
        -- Defer slightly to ensure highlights have settled after colorscheme change
        vim.defer_fn(function()
          -- 1. Try to get TabLineFill background (actual tab bar background)
          local ok_tl, tl_hl = pcall(vim.api.nvim_get_hl, 0, { name = "TabLineFill", link = false })
          local bg = (ok_tl and tl_hl and tl_hl.bg) or nil

          -- 2. Fall back to StatusLine background
          if not bg then
            local ok_sl, sl_hl = pcall(vim.api.nvim_get_hl, 0, { name = "StatusLine", link = false })
            bg = (ok_sl and sl_hl and sl_hl.bg) or nil
          end

          -- 3. Fall back to Normal background
          if not bg then
            local ok_nor, nor_hl = pcall(vim.api.nvim_get_hl, 0, { name = "Normal", link = false })
            bg = (ok_nor and nor_hl and nor_hl.bg) or nil
          end

          -- 4. Absolute fallback
          if not bg then
            bg = 2040629 -- Hex #1f2335 in decimal
          end

          -- Get the actual background color of the active tab
          local ok_sel, sel_hl = pcall(vim.api.nvim_get_hl, 0, { name = "BufferLineBufferSelected", link = false })
          local active_bg = (ok_sel and sel_hl and sel_hl.bg) or nil
          
          if not active_bg then
            local ok_nor, nor_hl = pcall(vim.api.nvim_get_hl, 0, { name = "Normal", link = false })
            active_bg = (ok_nor and nor_hl and nor_hl.bg) or nil
          end

          if not active_bg then
            active_bg = bg
          end

          local function update_hl(group, new_fg, new_bg)
            local ok2, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
            if ok2 and hl then
              if new_fg ~= nil then
                hl.fg = new_fg
              end
              if new_bg ~= nil then
                hl.bg = new_bg
              end
              vim.api.nvim_set_hl(0, group, hl)
            end
          end

          -- Apply to all BufferLine highlight groups and the tab fill
          local hls = vim.fn.getcompletion("BufferLine", "highlight")
          for _, hl_name in ipairs(hls) do
            if hl_name:find("Separator") then
              if settings.tab_buffer_transparent_dividers ~= false then
                -- Make all separators (active/inactive/selected) completely transparent and invisible
                update_hl(hl_name, bg or "NONE", bg or "NONE")
              else
                -- Traditional dividers: active separator gets active color, others blend or default
                if hl_name:find("SeparatorSelected$") or hl_name == "BufferLineSeparatorSelected" then
                  update_hl(hl_name, active_bg, bg or "NONE")
                else
                  update_hl(hl_name, nil, bg or "NONE")
                end
              end
            elseif hl_name:find("Selected") then
              -- Keep selected highlights untouched
            else
              -- Inactive background elements match StatusLine bg
              update_hl(hl_name, nil, bg or "NONE")
            end
          end
          
          -- Sync main TabLineFill
          update_hl("TabLineFill", nil, bg)
        end, 50)
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = sync_bufferline_bg,
      })
      -- Also apply immediately on first load
      sync_bufferline_bg()
    end,
  },
}
