return {
  {
    "akinsho/bufferline.nvim",
    version      = "*",
    lazy         = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local ok, settings = pcall(require, "settings")
      local style = (ok and settings.ui and settings.ui.bufferline_style) or "nvchad"
      local is_solid = (style == "solid")

      require("bufferline").setup({
        options = {
          mode    = "buffers",
          numbers = "none",

          close_command       = "bdelete! %d",
          right_mouse_command = "bdelete! %d",

          color_icons             = not is_solid,
          show_buffer_icons       = true,
          show_buffer_close_icons = false,
          show_close_icon         = false,
          show_tab_indicators     = true,

          modified_icon      = "●",
          left_trunc_marker  = "",
          right_trunc_marker = "",

          separator_style = "thin",   -- minimal thin line separators
          tab_size        = 20,
          max_name_length = 20,
          show_buffer_default_icon = true,
          truncate_names  = true,

          indicator = {
            icon = '▎', -- NvChad-like accent bar
            style = 'icon',
          },

          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local icons = { error = " ", warning = " ", info = " " }
            return " " .. (icons[level] or "") .. count
          end,

          always_show_bufferline = true,

          -- Hide unnamed, terminal, and snacks buffers
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
            { filetype = "NvimTree", text = "󰙅 Explorer", highlight = "Directory", padding = 1, text_align = "left", separator = false },
            { filetype = "neo-tree", text = "󰙅 Explorer", highlight = "Directory", padding = 1, text_align = "left", separator = false },
            { filetype = "snacks_picker_list", text = "󰙅 Explorer", highlight = "Directory", padding = 1, text_align = "left", separator = false },
            { filetype = "snacks_layout_box", text = "󰙅 Explorer", highlight = "Directory", padding = 1, text_align = "left", separator = false },
            { filetype = "snacks_explorer", text = "󰙅 Explorer", highlight = "Directory", padding = 1, text_align = "left", separator = false },
          },
        },

        highlights = {
          fill = {
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          background = {
            fg = { attribute = "fg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          buffer_selected = {
            fg = is_solid and { attribute = "bg", highlight = "TabLine" } or { attribute = "fg", highlight = "Directory" },
            bg = is_solid and { attribute = "fg", highlight = "Function" } or { attribute = "bg", highlight = "Normal" },
            bold = true,
            italic = false,
          },
          buffer_visible = {
            fg = { attribute = "fg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          separator = {
            fg = { attribute = "bg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          separator_selected = {
            fg = { attribute = "bg", highlight = "TabLine" },
            bg = is_solid and { attribute = "fg", highlight = "Function" } or { attribute = "bg", highlight = "Normal" },
          },
          separator_visible = {
            fg = { attribute = "bg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          tab = {
            fg = { attribute = "fg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          tab_selected = {
            fg = is_solid and { attribute = "bg", highlight = "TabLine" } or { attribute = "fg", highlight = "Directory" },
            bg = is_solid and { attribute = "fg", highlight = "Function" } or { attribute = "bg", highlight = "Normal" },
            bold = true,
          },
          tab_separator = {
            fg = { attribute = "bg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          tab_separator_selected = {
            fg = { attribute = "bg", highlight = "TabLine" },
            bg = is_solid and { attribute = "fg", highlight = "Function" } or { attribute = "bg", highlight = "Normal" },
          },
          tab_close = {
            fg = { attribute = "fg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          close_button = {
            fg = { attribute = "fg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          close_button_selected = {
            fg = is_solid and { attribute = "bg", highlight = "TabLine" } or { attribute = "fg", highlight = "ErrorMsg" },
            bg = is_solid and { attribute = "fg", highlight = "Function" } or { attribute = "bg", highlight = "Normal" },
          },
          close_button_visible = {
            fg = { attribute = "fg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          modified = {
            fg = { attribute = "fg", highlight = "String" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          modified_selected = {
            fg = is_solid and { attribute = "bg", highlight = "TabLine" } or { attribute = "fg", highlight = "String" },
            bg = is_solid and { attribute = "fg", highlight = "Function" } or { attribute = "bg", highlight = "Normal" },
          },
          modified_visible = {
            fg = { attribute = "fg", highlight = "String" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          duplicate = {
            fg = { attribute = "fg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
            italic = true,
          },
          duplicate_selected = {
            fg = is_solid and { attribute = "bg", highlight = "TabLine" } or { attribute = "fg", highlight = "Directory" },
            bg = is_solid and { attribute = "fg", highlight = "Function" } or { attribute = "bg", highlight = "Normal" },
            italic = true,
          },
          duplicate_visible = {
            fg = { attribute = "fg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
            italic = true,
          },

          indicator_selected = {
            fg = is_solid and { attribute = "bg", highlight = "TabLine" } or { attribute = "fg", highlight = "Directory" },
            bg = is_solid and { attribute = "fg", highlight = "Function" } or { attribute = "bg", highlight = "Normal" },
          },
          indicator_visible = {
            fg = { attribute = "fg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          trunc_marker = {
            fg = { attribute = "fg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          numbers = {
            fg = { attribute = "fg", highlight = "TabLine" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          numbers_selected = {
            fg = is_solid and { attribute = "bg", highlight = "TabLine" } or { attribute = "fg", highlight = "Directory" },
            bg = is_solid and { attribute = "fg", highlight = "Function" } or { attribute = "bg", highlight = "Normal" },
            bold = true,
          },

          error = {
            fg = { attribute = "fg", highlight = "DiagnosticError" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          error_selected = {
            fg = is_solid and { attribute = "bg", highlight = "TabLine" } or { attribute = "fg", highlight = "DiagnosticError" },
            bg = is_solid and { attribute = "fg", highlight = "Function" } or { attribute = "bg", highlight = "Normal" },
            bold = true,
          },
          error_visible = {
            fg = { attribute = "fg", highlight = "DiagnosticError" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          warning = {
            fg = { attribute = "fg", highlight = "DiagnosticWarn" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          warning_selected = {
            fg = is_solid and { attribute = "bg", highlight = "TabLine" } or { attribute = "fg", highlight = "DiagnosticWarn" },
            bg = is_solid and { attribute = "fg", highlight = "Function" } or { attribute = "bg", highlight = "Normal" },
            bold = true,
          },
          warning_visible = {
            fg = { attribute = "fg", highlight = "DiagnosticWarn" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          info = {
            fg = { attribute = "fg", highlight = "DiagnosticInfo" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          info_selected = {
            fg = is_solid and { attribute = "bg", highlight = "TabLine" } or { attribute = "fg", highlight = "DiagnosticInfo" },
            bg = is_solid and { attribute = "fg", highlight = "Function" } or { attribute = "bg", highlight = "Normal" },
            bold = true,
          },
          info_visible = {
            fg = { attribute = "fg", highlight = "DiagnosticInfo" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },

          hint = {
            fg = { attribute = "fg", highlight = "DiagnosticHint" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
          hint_selected = {
            fg = is_solid and { attribute = "bg", highlight = "TabLine" } or { attribute = "fg", highlight = "DiagnosticHint" },
            bg = is_solid and { attribute = "fg", highlight = "Function" } or { attribute = "bg", highlight = "Normal" },
            bold = true,
          },
          hint_visible = {
            fg = { attribute = "fg", highlight = "DiagnosticHint" },
            bg = { attribute = "bg", highlight = "TabLine" },
          },
        },
      })
    end,
  },
}