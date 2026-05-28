-- bufferline.lua – layout-aware tab bar using bufferline's native highlights API
return {
  {
    "akinsho/bufferline.nvim",
    version      = "*",
    lazy         = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
      local ok, settings = pcall(require, "settings")
      if not ok then settings = {} end

      local layout_name = (settings.ui and settings.ui.tab_buffer_layout) or "minimal"

      -- ── Color helpers ────────────────────────────────────────────────────
      local function get_hl(name)
        local s, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        return (s and hl) or {}
      end

      local function hex(n)
        if not n then return nil end
        return string.format("#%06x", n)
      end

      local function resolve_colors()
        local bar_bg
        for _, g in ipairs({ "TabLineFill", "StatusLine", "Normal" }) do
          bar_bg = get_hl(g).bg; if bar_bg then break end
        end
        bar_bg = hex(bar_bg) or "#1f2335"

        local active_bg
        for _, g in ipairs({ "CursorLine", "PmenuSel", "Visual" }) do
          active_bg = get_hl(g).bg; if active_bg then break end
        end
        if not active_bg then active_bg = get_hl("Normal").bg end
        active_bg = hex(active_bg) or "#24283b"

        local normal_fg   = hex(get_hl("Normal").fg)          or "#c0caf5"
        local inactive_fg = hex(get_hl("Comment").fg)         or "#565f89"
        local modified_fg = hex(get_hl("String").fg)          or "#9ece6a"
        local error_fg    = hex(get_hl("DiagnosticError").fg) or "#f7768e"
        local warn_fg     = hex(get_hl("DiagnosticWarn").fg)  or "#e0af68"
        local info_fg     = hex(get_hl("DiagnosticInfo").fg)  or "#7aa2f7"

        local accent_fg
        for _, g in ipairs({ "Function", "Keyword", "Statement", "Directory" }) do
          accent_fg = get_hl(g).fg; if accent_fg then break end
        end
        accent_fg = hex(accent_fg) or "#7aa2f7"

        return {
          bar_bg      = bar_bg,
          active_bg   = active_bg,
          normal_fg   = normal_fg,
          inactive_fg = inactive_fg,
          modified_fg = modified_fg,
          accent_fg   = accent_fg,
          error_fg    = error_fg,
          warn_fg     = warn_fg,
          info_fg     = info_fg,
        }
      end

      -- ── Layout definitions ───────────────────────────────────────────────
      -- Each layout returns:
      --   options   – merged into base_options
      --   hl_patch  – function(c, hl) that mutates the highlights table
      local layouts = {

        minimal = {
          options = { separator_style = { "", "" }, tab_size = 22, indicator = { icon = "", style = "none" } },
          hl_patch = function(c, hl)
            -- plain: active tab just has a different background
          end,
        },

        underline = {
          options = { separator_style = { "", "" }, tab_size = 22, indicator = { icon = "", style = "none" } },
          hl_patch = function(c, hl)
            hl.buffer_selected = vim.tbl_extend("force", hl.buffer_selected, {
              underline = true, sp = c.accent_fg,
            })
          end,
        },

        top_accent = {
          options = { separator_style = { "", "" }, tab_size = 22, indicator = { icon = "", style = "none" } },
          hl_patch = function(c, hl)
            hl.buffer_selected = vim.tbl_extend("force", hl.buffer_selected, {
              overline = true, sp = c.accent_fg,
            })
          end,
        },

        theme_accent = {
          options = { separator_style = { "", "" }, tab_size = 22, indicator = { icon = "", style = "none" } },
          hl_patch = function(c, hl)
            hl.buffer_selected = vim.tbl_extend("force", hl.buffer_selected, {
              underline = true, overline = false, sp = c.accent_fg,
            })
            hl.indicator_selected = { fg = c.accent_fg, bg = c.active_bg }
          end,
        },

        slant = {
          options = { separator_style = "slant", tab_size = 22, indicator = { style = "none" } },
          hl_patch = function(c, hl)
            hl.separator          = { fg = c.bar_bg,    bg = c.bar_bg }
            hl.separator_selected = { fg = c.bar_bg,    bg = c.active_bg }
            hl.separator_visible  = { fg = c.bar_bg,    bg = c.bar_bg }
          end,
        },

        bubble = {
          options = { separator_style = { "▎", "▎" }, tab_size = 20, indicator = { style = "none" } },
          hl_patch = function(c, hl)
            local bubble_bg = hex(get_hl("CursorLine").bg) or c.active_bg
            hl.buffer_selected    = vim.tbl_extend("force", hl.buffer_selected, { bg = bubble_bg })
            hl.separator          = { fg = c.bar_bg, bg = c.bar_bg }
            hl.separator_selected = { fg = c.bar_bg, bg = bubble_bg }
            -- also fix all _selected backgrounds for icons
            hl.modified_selected  = { fg = hl.modified_fg, bg = bubble_bg }
            hl.close_button_selected = { fg = hl.close_button_selected and hl.close_button_selected.fg or c.accent_fg, bg = bubble_bg }
          end,
        },

        bordered = {
          options = { separator_style = { "▎", "▎" }, tab_size = 20, indicator = { style = "none" } },
          hl_patch = function(c, hl)
            local border_fg = hex(get_hl("Comment").fg) or "#414868"
            hl.separator          = { fg = border_fg, bg = c.bar_bg }
            hl.separator_selected = { fg = border_fg, bg = c.active_bg }
            hl.separator_visible  = { fg = border_fg, bg = c.bar_bg }
          end,
        },

        compact = {
          options = {
            separator_style = { "", "" }, tab_size = 14, max_name_length = 12,
            max_prefix_length = 8, truncate_names = true,
            color_icons = false, show_buffer_icons = false,
            show_buffer_close_icons = false, indicator = { icon = "", style = "none" },
          },
          hl_patch = function(c, hl)
            hl.buffer_selected = vim.tbl_extend("force", hl.buffer_selected, {
              underline = true, sp = c.accent_fg,
            })
          end,
        },

        centered = {
          options = { separator_style = { "", "" }, tab_size = 32, max_name_length = 24, indicator = { icon = "", style = "none" } },
          hl_patch = function(c, hl)
            hl.buffer_selected = vim.tbl_extend("force", hl.buffer_selected, {
              overline = true, sp = c.accent_fg,
            })
          end,
        },

        diagnostic_gutter = {
          options = {
            separator_style = { "", "" }, tab_size = 22,
            indicator = { icon = "", style = "none" }, show_tab_indicators = true,
          },
          hl_patch = function(c, hl)
            hl.buffer_selected = vim.tbl_extend("force", hl.buffer_selected, {
              underline = true, sp = c.accent_fg,
            })
          end,
        },

        devicon_showcase = {
          options = {
            separator_style = { "", "" }, tab_size = 22,
            color_icons = true, show_buffer_icons = true,
            indicator = { icon = "", style = "none" },
          },
          hl_patch = function(c, hl)
            -- Icons get color from nvim-web-devicons; just ensure bgs are right
          end,
        },
      }

      local selected = layouts[layout_name] or layouts.minimal

      -- ── Settings ─────────────────────────────────────────────────────────
      local ui         = settings.ui or {}
      local show_icons = ui.tab_buffer_show_icons ~= false
      local show_close = ui.tab_buffer_show_close == true
      local hide_empty = ui.hide_empty_tabline == true

      -- ── Build and apply ───────────────────────────────────────────────────
      local function apply_setup()
        local c = resolve_colors()

        -- Base highlights (every variant: _selected, _visible, inactive)
        local hl = {
          fill                   = { bg = c.bar_bg },

          background             = { fg = c.inactive_fg, bg = c.bar_bg },
          buffer_selected        = { fg = c.accent_fg,   bg = c.active_bg, bold = true },
          buffer_visible         = { fg = c.normal_fg,   bg = c.bar_bg },

          separator              = { fg = c.bar_bg,    bg = c.bar_bg },
          separator_selected     = { fg = c.active_bg, bg = c.active_bg },
          separator_visible      = { fg = c.bar_bg,    bg = c.bar_bg },

          tab                    = { fg = c.inactive_fg, bg = c.bar_bg },
          tab_selected           = { fg = c.accent_fg,   bg = c.active_bg, bold = true },
          tab_separator          = { fg = c.bar_bg,    bg = c.bar_bg },
          tab_separator_selected = { fg = c.active_bg, bg = c.active_bg },
          tab_close              = { fg = c.inactive_fg, bg = c.bar_bg },

          close_button           = { fg = c.inactive_fg, bg = c.bar_bg },
          close_button_selected  = { fg = c.accent_fg,   bg = c.active_bg },
          close_button_visible   = { fg = c.normal_fg,   bg = c.bar_bg },

          modified               = { fg = c.modified_fg, bg = c.bar_bg },
          modified_selected      = { fg = c.modified_fg, bg = c.active_bg },
          modified_visible       = { fg = c.modified_fg, bg = c.bar_bg },

          duplicate              = { fg = c.inactive_fg, bg = c.bar_bg,    italic = true },
          duplicate_selected     = { fg = c.accent_fg,   bg = c.active_bg, italic = true },
          duplicate_visible      = { fg = c.inactive_fg, bg = c.bar_bg,    italic = true },

          trunc_marker           = { fg = c.inactive_fg, bg = c.bar_bg },

          indicator_selected     = { fg = c.active_bg,  bg = c.active_bg },
          indicator_visible      = { fg = c.bar_bg,     bg = c.bar_bg },

          numbers                = { fg = c.inactive_fg, bg = c.bar_bg },
          numbers_selected       = { fg = c.accent_fg,   bg = c.active_bg, bold = true },
          numbers_visible        = { fg = c.normal_fg,   bg = c.bar_bg },

          pick                   = { fg = c.warn_fg, bg = c.bar_bg,    bold = true },
          pick_selected          = { fg = c.warn_fg, bg = c.active_bg, bold = true },
          pick_visible           = { fg = c.warn_fg, bg = c.bar_bg,    bold = true },

          offset_separator       = { fg = c.bar_bg, bg = c.bar_bg },

          -- Diagnostics
          diagnostic             = { fg = c.inactive_fg, bg = c.bar_bg },
          diagnostic_selected    = { fg = c.normal_fg,   bg = c.active_bg },
          diagnostic_visible     = { fg = c.inactive_fg, bg = c.bar_bg },

          error                  = { fg = c.error_fg, bg = c.bar_bg },
          error_selected         = { fg = c.error_fg, bg = c.active_bg, bold = true },
          error_visible          = { fg = c.error_fg, bg = c.bar_bg },

          warning                = { fg = c.warn_fg, bg = c.bar_bg },
          warning_selected       = { fg = c.warn_fg, bg = c.active_bg, bold = true },
          warning_visible        = { fg = c.warn_fg, bg = c.bar_bg },

          info                   = { fg = c.info_fg, bg = c.bar_bg },
          info_selected          = { fg = c.info_fg, bg = c.active_bg, bold = true },
          info_visible           = { fg = c.info_fg, bg = c.bar_bg },

          hint                   = { fg = c.info_fg, bg = c.bar_bg },
          hint_selected          = { fg = c.info_fg, bg = c.active_bg, bold = true },
          hint_visible           = { fg = c.info_fg, bg = c.bar_bg },

          error_diagnostic           = { fg = c.error_fg, bg = c.bar_bg },
          error_diagnostic_selected  = { fg = c.error_fg, bg = c.active_bg },
          warning_diagnostic         = { fg = c.warn_fg, bg = c.bar_bg },
          warning_diagnostic_selected= { fg = c.warn_fg, bg = c.active_bg },
          info_diagnostic            = { fg = c.info_fg, bg = c.bar_bg },
          info_diagnostic_selected   = { fg = c.info_fg, bg = c.active_bg },
          hint_diagnostic            = { fg = c.info_fg, bg = c.bar_bg },
          hint_diagnostic_selected   = { fg = c.info_fg, bg = c.active_bg },
        }

        -- Let the layout mutate highlights
        selected.hl_patch(c, hl)

        -- Base options
        local base_options = {
          mode    = settings.tab_buffer_style or "buffers",
          numbers = "none",

          close_command       = function(n) Snacks.bufdelete(n) end,
          right_mouse_command = function(n) Snacks.bufdelete(n) end,

          color_icons             = show_icons,
          show_buffer_icons       = show_icons,
          show_buffer_close_icons = show_close,
          show_close_icon         = show_close,
          show_tab_indicators     = false,
          buffer_close_icon       = "",
          modified_icon           = "●",
          close_icon              = "",
          left_trunc_marker       = "",
          right_trunc_marker      = "",

          tab_size          = 22,
          max_name_length   = 18,
          max_prefix_length = 13,
          truncate_names    = true,

          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local icons = { error = " ", warning = " ", info = " " }
            return (icons[level] or "") .. count
          end,

          always_show_bufferline = not hide_empty,

          custom_filter = function(bufnr)
            if vim.api.nvim_buf_get_name(bufnr) == "" then return false end
            local ft = vim.bo[bufnr].filetype
            local bt = vim.bo[bufnr].buftype
            if ft == "toggleterm" or bt == "terminal" then return false end
            if ft:find("snacks") then return false end
            return true
          end,

          hover = { enabled = true, delay = 200, reveal = { "close" } },

          offsets = {
            { filetype = "NvimTree",           text = " Files", text_align = "left", separator = false },
            { filetype = "neo-tree",            text = " Files", text_align = "left", separator = false },
            { filetype = "snacks_layout_box",   text = "",       separator = false },
            { filetype = "snacks_picker_list",  text = "",       separator = false },
          },
        }

        local options = vim.tbl_deep_extend("force", base_options, selected.options or {})

        require("bufferline").setup({ highlights = hl, options = options })

        -- Keep TabLineFill in sync (Neovim draws this outside bufferline)
        local bar_int = tonumber(c.bar_bg:sub(2), 16)
        if bar_int then vim.api.nvim_set_hl(0, "TabLineFill", { bg = bar_int }) end
      end

      apply_setup()

      vim.api.nvim_create_autocmd("ColorScheme", {
        group    = vim.api.nvim_create_augroup("BufferlineThemeSync", { clear = true }),
        pattern  = "*",
        callback = function() vim.defer_fn(apply_setup, 50) end,
      })
    end,
  },
}