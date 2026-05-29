-- plugins/ui/bufferline.lua
-- ── Concept: matches the "Sentence Bar" statusline ───────────────────────
-- • Flat bg throughout — same Normal bg as statusline
-- • Active tab: accent underline (not a pill, not a full bg swap)
-- • Separator style "none" — no glyphs between tabs, breathing room via padding
-- • All highlights are theme-sourced at runtime, zero hardcoded hex
-- ─────────────────────────────────────────────────────────────────────────
return {
  {
    "akinsho/bufferline.nvim",
    version      = "*",
    lazy         = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()

      -- ── Runtime colour helper ────────────────────────────────────────────
      local function get_hl(name)
        local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        return ok and h or {}
      end
      local function hex(name, attr)
        local v = get_hl(name)[attr]
        return v and ("#%06x"):format(v) or nil
      end

      -- ── Style flag ───────────────────────────────────────────────────────
      local ok_s, settings = pcall(require, "settings")
      local style    = (ok_s and settings.ui and settings.ui.bufferline_style) or "underline"
      local is_solid = (style == "solid")

      -- ── Setup ────────────────────────────────────────────────────────────
      require("bufferline").setup({

        -- ── Options ──────────────────────────────────────────────────────
        options = {
          mode    = "buffers",
          numbers = "none",

          close_command        = "bdelete! %d",
          right_mouse_command  = "bdelete! %d",
          left_mouse_command   = "buffer %d",
          middle_mouse_command = nil,

          -- Icons
          color_icons              = true,
          show_buffer_icons        = true,
          show_buffer_close_icons  = true,
          show_close_icon          = false,
          show_tab_indicators      = true,
          show_buffer_default_icon = true,

          modified_icon      = "\u{25cf}",   -- ● unsaved dot
          close_icon         = "\u{f00d}",   -- ✕
          left_trunc_marker  = "\u{f0141}",  -- 󰅁
          right_trunc_marker = "\u{f0142}",  -- 󰅂
          truncate_names     = true,

          -- Underline accent on active tab — the one unique visual signal
          indicator = {
            style = is_solid and "icon" or "underline",
            icon  = "\u{258f}",  -- ▏ (used only in solid mode)
          },

          -- No glyphs between tabs — padding does the work
          separator_style = "thin",
          tab_size        = 18,
          max_name_length = 22,
          padding         = 1,

          -- LSP diagnostics
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local sym = { error = " ", warning = " ", info = " " }
            return (sym[level] or "") .. count
          end,

          always_show_bufferline = true,

          -- Filter: hide unnamed, terminal, snacks internals
          custom_filter = function(bufnr)
            if vim.api.nvim_buf_get_name(bufnr) == "" then return false end
            local ft = vim.bo[bufnr].filetype
            local bt = vim.bo[bufnr].buftype
            if bt == "terminal" or ft == "toggleterm" then return false end
            if ft:find("snacks") then return false end
            return true
          end,

          hover = { enabled = true, delay = 150, reveal = { "close" } },

          -- Explorer offsets — text removed, just blank space
          offsets = {
            {
              filetype   = "snacks_picker_list",
              text       = "",
              separator  = false,
              padding    = 1,
            },
            {
              filetype   = "snacks_layout_box",
              text       = "",
              separator  = false,
              padding    = 1,
            },
            {
              filetype   = "snacks_explorer",
              text       = "",
              separator  = false,
              padding    = 1,
            },
            {
              filetype   = "neo-tree",
              text       = "",
              separator  = false,
              padding    = 1,
            },
          },
        },

        -- ── Highlights ───────────────────────────────────────────────────
        -- Strategy:
        --   inactive  → Normal bg,  Comment fg  (recedes)
        --   visible   → Normal bg,  TabLine fg  (visible but not active)
        --   selected  → Normal bg,  Normal fg, bold  (pops via text weight + underline)
        --   fill      → TabLine bg  (the bar behind everything)
        --
        -- All colours are { attribute, highlight } refs — resolved at render time.
        -- sp (special/underline colour) uses Function fg for the accent line.
        highlights = {

          fill = {
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          -- ── Inactive ────────────────────────────────────────────────────
          background = {
            fg = { attribute = "fg", highlight = "Comment" },
            bg = { attribute = "bg", highlight = "Normal"  },
          },

          -- ── Visible (in another split, not focused) ──────────────────────
          buffer_visible = {
            fg = { attribute = "fg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "Normal"  },
          },

          -- ── Selected (active) ────────────────────────────────────────────
          buffer_selected = {
            fg   = { attribute = "fg", highlight = "Normal"   },
            bg   = { attribute = "bg", highlight = "Normal"   },
            sp   = { attribute = "fg", highlight = "Function" },  -- underline colour
            bold = true,
          },

          -- ── Indicator ────────────────────────────────────────────────────
          indicator_selected = {
            fg = { attribute = "fg", highlight = "Function" },
            bg = { attribute = "bg", highlight = "Normal"   },
            sp = { attribute = "fg", highlight = "Function" },
          },
          indicator_visible = {
            fg = { attribute = "bg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "Normal" },
          },

          -- ── Separators ───────────────────────────────────────────────────
          -- Invisible — same colour as bg so they vanish
          separator = {
            fg = { attribute = "bg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "Normal" },
          },
          separator_selected = {
            fg = { attribute = "bg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "Normal" },
          },
          separator_visible = {
            fg = { attribute = "bg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "Normal" },
          },

          -- ── Modified dot ─────────────────────────────────────────────────
          modified = {
            fg = { attribute = "fg", highlight = "String"  },
            bg = { attribute = "bg", highlight = "Normal"  },
          },
          modified_selected = {
            fg = { attribute = "fg", highlight = "String"  },
            bg = { attribute = "bg", highlight = "Normal"  },
            sp = { attribute = "fg", highlight = "Function" },
          },
          modified_visible = {
            fg = { attribute = "fg", highlight = "String"  },
            bg = { attribute = "bg", highlight = "Normal"  },
          },

          -- ── Close button ─────────────────────────────────────────────────
          close_button = {
            fg = { attribute = "fg", highlight = "Comment" },
            bg = { attribute = "bg", highlight = "Normal"  },
          },
          close_button_selected = {
            fg = { attribute = "fg", highlight = "ErrorMsg" },
            bg = { attribute = "bg", highlight = "Normal"   },
            sp = { attribute = "fg", highlight = "Function" },
          },
          close_button_visible = {
            fg = { attribute = "fg", highlight = "Comment" },
            bg = { attribute = "bg", highlight = "Normal"  },
          },

          -- ── Duplicate names ───────────────────────────────────────────────
          duplicate = {
            fg     = { attribute = "fg", highlight = "Comment" },
            bg     = { attribute = "bg", highlight = "Normal"  },
            italic = true,
          },
          duplicate_selected = {
            fg     = { attribute = "fg", highlight = "Function" },
            bg     = { attribute = "bg", highlight = "Normal"   },
            sp     = { attribute = "fg", highlight = "Function" },
            italic = true,
          },
          duplicate_visible = {
            fg     = { attribute = "fg", highlight = "Comment" },
            bg     = { attribute = "bg", highlight = "Normal"  },
            italic = true,
          },

          -- ── Trunc markers ─────────────────────────────────────────────────
          trunc_marker = {
            fg = { attribute = "fg", highlight = "Comment" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          -- ── Numbers ───────────────────────────────────────────────────────
          numbers = {
            fg = { attribute = "fg", highlight = "Comment" },
            bg = { attribute = "bg", highlight = "Normal"  },
          },
          numbers_selected = {
            fg   = { attribute = "fg", highlight = "Function" },
            bg   = { attribute = "bg", highlight = "Normal"   },
            sp   = { attribute = "fg", highlight = "Function" },
            bold = true,
          },
          numbers_visible = {
            fg = { attribute = "fg", highlight = "Comment" },
            bg = { attribute = "bg", highlight = "Normal"  },
          },

          -- ── Tab (vim tabs, not buffers) ───────────────────────────────────
          tab = {
            fg = { attribute = "fg", highlight = "Comment" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          tab_selected = {
            fg   = { attribute = "fg", highlight = "Normal"   },
            bg   = { attribute = "bg", highlight = "Normal"   },
            sp   = { attribute = "fg", highlight = "Function" },
            bold = true,
          },
          tab_separator = {
            fg = { attribute = "bg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          tab_separator_selected = {
            fg = { attribute = "bg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "Normal" },
          },
          tab_close = {
            fg = { attribute = "fg", highlight = "Comment" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          -- ── Diagnostics ───────────────────────────────────────────────────
          error = {
            fg = { attribute = "fg", highlight = "DiagnosticError" },
            bg = { attribute = "bg", highlight = "Normal"          },
          },
          error_selected = {
            fg   = { attribute = "fg", highlight = "DiagnosticError" },
            bg   = { attribute = "bg", highlight = "Normal"          },
            sp   = { attribute = "fg", highlight = "Function"        },
            bold = true,
          },
          error_visible = {
            fg = { attribute = "fg", highlight = "DiagnosticError" },
            bg = { attribute = "bg", highlight = "Normal"          },
          },
          error_diagnostic = {
            fg = { attribute = "fg", highlight = "DiagnosticError" },
            bg = { attribute = "bg", highlight = "Normal"          },
          },
          error_diagnostic_selected = {
            fg   = { attribute = "fg", highlight = "DiagnosticError" },
            bg   = { attribute = "bg", highlight = "Normal"          },
            sp   = { attribute = "fg", highlight = "Function"        },
            bold = true,
          },
          error_diagnostic_visible = {
            fg = { attribute = "fg", highlight = "DiagnosticError" },
            bg = { attribute = "bg", highlight = "Normal"          },
          },

          warning = {
            fg = { attribute = "fg", highlight = "DiagnosticWarn" },
            bg = { attribute = "bg", highlight = "Normal"         },
          },
          warning_selected = {
            fg   = { attribute = "fg", highlight = "DiagnosticWarn" },
            bg   = { attribute = "bg", highlight = "Normal"         },
            sp   = { attribute = "fg", highlight = "Function"       },
            bold = true,
          },
          warning_visible = {
            fg = { attribute = "fg", highlight = "DiagnosticWarn" },
            bg = { attribute = "bg", highlight = "Normal"         },
          },
          warning_diagnostic = {
            fg = { attribute = "fg", highlight = "DiagnosticWarn" },
            bg = { attribute = "bg", highlight = "Normal"         },
          },
          warning_diagnostic_selected = {
            fg   = { attribute = "fg", highlight = "DiagnosticWarn" },
            bg   = { attribute = "bg", highlight = "Normal"         },
            sp   = { attribute = "fg", highlight = "Function"       },
            bold = true,
          },
          warning_diagnostic_visible = {
            fg = { attribute = "fg", highlight = "DiagnosticWarn" },
            bg = { attribute = "bg", highlight = "Normal"         },
          },

          info = {
            fg = { attribute = "fg", highlight = "DiagnosticInfo" },
            bg = { attribute = "bg", highlight = "Normal"         },
          },
          info_selected = {
            fg   = { attribute = "fg", highlight = "DiagnosticInfo" },
            bg   = { attribute = "bg", highlight = "Normal"         },
            sp   = { attribute = "fg", highlight = "Function"       },
            bold = true,
          },
          info_visible = {
            fg = { attribute = "fg", highlight = "DiagnosticInfo" },
            bg = { attribute = "bg", highlight = "Normal"         },
          },
          info_diagnostic = {
            fg = { attribute = "fg", highlight = "DiagnosticInfo" },
            bg = { attribute = "bg", highlight = "Normal"         },
          },
          info_diagnostic_selected = {
            fg   = { attribute = "fg", highlight = "DiagnosticInfo" },
            bg   = { attribute = "bg", highlight = "Normal"         },
            sp   = { attribute = "fg", highlight = "Function"       },
            bold = true,
          },
          info_diagnostic_visible = {
            fg = { attribute = "fg", highlight = "DiagnosticInfo" },
            bg = { attribute = "bg", highlight = "Normal"         },
          },

          hint = {
            fg = { attribute = "fg", highlight = "DiagnosticHint" },
            bg = { attribute = "bg", highlight = "Normal"         },
          },
          hint_selected = {
            fg   = { attribute = "fg", highlight = "DiagnosticHint" },
            bg   = { attribute = "bg", highlight = "Normal"         },
            sp   = { attribute = "fg", highlight = "Function"       },
            bold = true,
          },
          hint_visible = {
            fg = { attribute = "fg", highlight = "DiagnosticHint" },
            bg = { attribute = "bg", highlight = "Normal"         },
          },
          hint_diagnostic = {
            fg = { attribute = "fg", highlight = "DiagnosticHint" },
            bg = { attribute = "bg", highlight = "Normal"         },
          },
          hint_diagnostic_selected = {
            fg   = { attribute = "fg", highlight = "DiagnosticHint" },
            bg   = { attribute = "bg", highlight = "Normal"         },
            sp   = { attribute = "fg", highlight = "Function"       },
            bold = true,
          },
          hint_diagnostic_visible = {
            fg = { attribute = "fg", highlight = "DiagnosticHint" },
            bg = { attribute = "bg", highlight = "Normal"         },
          },
        },
      })

      -- ── Re-apply on colorscheme change ───────────────────────────────────
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern  = "*",
        callback = function()
          vim.defer_fn(function()
            local ok2, bl = pcall(require, "bufferline")
            if ok2 then bl.setup_commands() end
          end, 10)
        end,
      })
    end,
  },
}