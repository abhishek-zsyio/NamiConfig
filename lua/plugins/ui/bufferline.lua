-- plugins/ui/bufferline.lua
-- ── Design language: flat · no underlines · filename-only · accent via bold+fg ──
-- • Active tab: fg accent + bold — no underline, no pill, no bg swap
-- • Inactive: deeply ghosted (Comment fg) so active pops by contrast alone
-- • Separator: true none — zero glyphs, spacing carries the rhythm
-- • Filename only — no path noise in the tab bar
-- ─────────────────────────────────────────────────────────────────────────────
return {
  {
    "akinsho/bufferline.nvim",
    version      = "*",
    lazy         = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()

      -- ── Runtime colour helper ──────────────────────────────────────────────
      local function get_hl(name)
        local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        return ok and h or {}
      end
      local function hex(name, attr)
        local v = get_hl(name)[attr]
        return v and ("#%06x"):format(v) or nil
      end

      -- ── Name formatter: filename only, no path ─────────────────────────────
      -- bufferline passes a table {name, path, bufnr, tabnr}, not a plain string.
      local function short_name(buf)
        local path = buf.path or buf.name or ""
        if path == "" then return "[No Name]" end
        return vim.fn.fnamemodify(path, ":t")
      end

      -- ── Setup ──────────────────────────────────────────────────────────────
      require("bufferline").setup({

        options = {
          mode    = "buffers",
          numbers = "none",

          name_formatter = short_name,   -- ← filename only

          close_command        = "bdelete! %d",
          right_mouse_command  = "bdelete! %d",
          left_mouse_command   = "buffer %d",
          middle_mouse_command = nil,

          -- Icons
          color_icons              = true,
          show_buffer_icons        = true,
          show_buffer_close_icons  = false,   -- hide ✕ on inactive; reveal on hover
          show_close_icon          = false,
          show_tab_indicators      = true,
          show_buffer_default_icon = true,

          modified_icon      = "●",
          close_icon         = "✕",
          left_trunc_marker  = "‹",
          right_trunc_marker = "›",
          truncate_names     = true,

          -- No underline — indicator is visually silent; active pops by colour alone
          indicator = {
            style = "none",
          },

          -- True separator-free layout — padding breathes for us
          separator_style = "none",
          tab_size        = 14,        -- tighter than before
          max_name_length = 18,
          padding         = 1,

          -- LSP diagnostics
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local sym = { error = " ", warning = " ", info = " " }
            return (sym[level] or "") .. count
          end,

          always_show_bufferline = true,

          -- Hover: reveal close button on mouse-over only
          hover = { enabled = true, delay = 100, reveal = { "close" } },

          -- Filter: hide unnamed, terminal, snacks internals
          custom_filter = function(bufnr)
            if vim.api.nvim_buf_get_name(bufnr) == "" then return false end
            local ft = vim.bo[bufnr].filetype
            local bt = vim.bo[bufnr].buftype
            if bt == "terminal" or ft == "toggleterm" then return false end
            if ft:find("snacks") then return false end
            return true
          end,

          -- Explorer offsets — blank, no labels
          offsets = {
            { filetype = "snacks_picker_list",  text = "", separator = false, padding = 1 },
            { filetype = "snacks_layout_box",   text = "", separator = false, padding = 1 },
            { filetype = "snacks_explorer",     text = "", separator = false, padding = 1 },
            { filetype = "neo-tree",            text = "", separator = false, padding = 1 },
          },
        },

        -- ── Highlights ────────────────────────────────────────────────────────
        -- Strategy:
        --   fill       → TabLine bg (the bar behind everything)
        --   inactive   → Normal bg + Comment fg  (deeply ghosted, recedes)
        --   visible    → Normal bg + TabLine fg  (exists, not demanding)
        --   selected   → Normal bg + Function fg, bold  (pops purely via colour+weight)
        --
        -- NO sp / underline anywhere. Active identity comes from:
        --   1. Function-colour fg (accent) on both the text and icon
        --   2. bold weight
        --   3. Surrounding inactive tabs being visually dim
        highlights = {

          fill = {
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          -- ── Inactive ──────────────────────────────────────────────────────
          background = {
            fg = { attribute = "fg", highlight = "Comment" },
            bg = { attribute = "bg", highlight = "Normal"  },
          },

          -- ── Visible (in split, not focused) ──────────────────────────────
          buffer_visible = {
            fg = { attribute = "fg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "Normal"  },
          },

          -- ── Selected (active) ─────────────────────────────────────────────
          -- Accent via fg colour + bold — no underline, no bg change
          buffer_selected = {
            fg   = { attribute = "fg", highlight = "Function" },
            bg   = { attribute = "bg", highlight = "Normal"   },
            bold = true,
          },

          -- ── Indicator: invisible (style = none) ───────────────────────────
          indicator_selected = {
            fg = { attribute = "bg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "Normal" },
          },
          indicator_visible = {
            fg = { attribute = "bg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "Normal" },
          },

          -- ── Separators: fully invisible ───────────────────────────────────
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

          -- ── Modified dot ──────────────────────────────────────────────────
          modified = {
            fg = { attribute = "fg", highlight = "String" },
            bg = { attribute = "bg", highlight = "Normal" },
          },
          modified_selected = {
            fg   = { attribute = "fg", highlight = "String"   },
            bg   = { attribute = "bg", highlight = "Normal"   },
            bold = true,
          },
          modified_visible = {
            fg = { attribute = "fg", highlight = "String" },
            bg = { attribute = "bg", highlight = "Normal" },
          },

          -- ── Close button ──────────────────────────────────────────────────
          close_button = {
            fg = { attribute = "fg", highlight = "Comment" },
            bg = { attribute = "bg", highlight = "Normal"  },
          },
          close_button_selected = {
            fg   = { attribute = "fg", highlight = "ErrorMsg" },
            bg   = { attribute = "bg", highlight = "Normal"   },
            bold = true,
          },
          close_button_visible = {
            fg = { attribute = "fg", highlight = "Comment" },
            bg = { attribute = "bg", highlight = "Normal"  },
          },

          -- ── Duplicate names ───────────────────────────────────────────────
          duplicate = {
            fg     = { attribute = "fg", highlight = "Comment"  },
            bg     = { attribute = "bg", highlight = "Normal"   },
            italic = true,
          },
          duplicate_selected = {
            fg     = { attribute = "fg", highlight = "Function" },
            bg     = { attribute = "bg", highlight = "Normal"   },
            bold   = true,
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
            bold = true,
          },
          numbers_visible = {
            fg = { attribute = "fg", highlight = "Comment" },
            bg = { attribute = "bg", highlight = "Normal"  },
          },

          -- ── Vim tabs ──────────────────────────────────────────────────────
          tab = {
            fg = { attribute = "fg", highlight = "Comment" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          tab_selected = {
            fg   = { attribute = "fg", highlight = "Function" },
            bg   = { attribute = "bg", highlight = "Normal"   },
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
          -- Pattern: inactive/visible use raw diag colour, selected adds bold
          error                     = { fg = { attribute = "fg", highlight = "DiagnosticError" }, bg = { attribute = "bg", highlight = "Normal" } },
          error_selected            = { fg = { attribute = "fg", highlight = "DiagnosticError" }, bg = { attribute = "bg", highlight = "Normal" }, bold = true },
          error_visible             = { fg = { attribute = "fg", highlight = "DiagnosticError" }, bg = { attribute = "bg", highlight = "Normal" } },
          error_diagnostic          = { fg = { attribute = "fg", highlight = "DiagnosticError" }, bg = { attribute = "bg", highlight = "Normal" } },
          error_diagnostic_selected = { fg = { attribute = "fg", highlight = "DiagnosticError" }, bg = { attribute = "bg", highlight = "Normal" }, bold = true },
          error_diagnostic_visible  = { fg = { attribute = "fg", highlight = "DiagnosticError" }, bg = { attribute = "bg", highlight = "Normal" } },

          warning                     = { fg = { attribute = "fg", highlight = "DiagnosticWarn" }, bg = { attribute = "bg", highlight = "Normal" } },
          warning_selected            = { fg = { attribute = "fg", highlight = "DiagnosticWarn" }, bg = { attribute = "bg", highlight = "Normal" }, bold = true },
          warning_visible             = { fg = { attribute = "fg", highlight = "DiagnosticWarn" }, bg = { attribute = "bg", highlight = "Normal" } },
          warning_diagnostic          = { fg = { attribute = "fg", highlight = "DiagnosticWarn" }, bg = { attribute = "bg", highlight = "Normal" } },
          warning_diagnostic_selected = { fg = { attribute = "fg", highlight = "DiagnosticWarn" }, bg = { attribute = "bg", highlight = "Normal" }, bold = true },
          warning_diagnostic_visible  = { fg = { attribute = "fg", highlight = "DiagnosticWarn" }, bg = { attribute = "bg", highlight = "Normal" } },

          info                     = { fg = { attribute = "fg", highlight = "DiagnosticInfo" }, bg = { attribute = "bg", highlight = "Normal" } },
          info_selected            = { fg = { attribute = "fg", highlight = "DiagnosticInfo" }, bg = { attribute = "bg", highlight = "Normal" }, bold = true },
          info_visible             = { fg = { attribute = "fg", highlight = "DiagnosticInfo" }, bg = { attribute = "bg", highlight = "Normal" } },
          info_diagnostic          = { fg = { attribute = "fg", highlight = "DiagnosticInfo" }, bg = { attribute = "bg", highlight = "Normal" } },
          info_diagnostic_selected = { fg = { attribute = "fg", highlight = "DiagnosticInfo" }, bg = { attribute = "bg", highlight = "Normal" }, bold = true },
          info_diagnostic_visible  = { fg = { attribute = "fg", highlight = "DiagnosticInfo" }, bg = { attribute = "bg", highlight = "Normal" } },

          hint                     = { fg = { attribute = "fg", highlight = "DiagnosticHint" }, bg = { attribute = "bg", highlight = "Normal" } },
          hint_selected            = { fg = { attribute = "fg", highlight = "DiagnosticHint" }, bg = { attribute = "bg", highlight = "Normal" }, bold = true },
          hint_visible             = { fg = { attribute = "fg", highlight = "DiagnosticHint" }, bg = { attribute = "bg", highlight = "Normal" } },
          hint_diagnostic          = { fg = { attribute = "fg", highlight = "DiagnosticHint" }, bg = { attribute = "bg", highlight = "Normal" } },
          hint_diagnostic_selected = { fg = { attribute = "fg", highlight = "DiagnosticHint" }, bg = { attribute = "bg", highlight = "Normal" }, bold = true },
          hint_diagnostic_visible  = { fg = { attribute = "fg", highlight = "DiagnosticHint" }, bg = { attribute = "bg", highlight = "Normal" } },
        },
      })

      -- ── Re-apply on colorscheme change ─────────────────────────────────────
      -- bufferline v3+ refreshes highlights automatically on ColorScheme;
      -- no manual call needed. The autocmd is kept as a safety net only.
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern  = "*",
        callback = function()
          vim.defer_fn(function()
            pcall(function()
              require("bufferline.highlights").reset()
            end)
          end, 10)
        end,
      })
    end,
  },
}