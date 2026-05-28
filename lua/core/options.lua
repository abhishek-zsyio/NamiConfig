local opt = vim.opt

-- Load user settings safely (defaults fallback if missing)
local ok, settings = pcall(require, "settings")
if not ok then settings = {} end

-- ── UI ────────────────────────────────────────────────────────────────────
opt.background     = settings.background == "light" and "light" or "dark"
opt.number         = settings.show_line_numbers ~= false
opt.relativenumber = settings.relative_line_numbers == true
opt.cursorline     = settings.highlight_current_line ~= false -- highlight the current line
opt.cursorlineopt  = "both" -- highlight both the number and the lines"
opt.signcolumn     = "yes"
opt.termguicolors  = true
opt.showmode       = false      -- lualine shows the mode
opt.showtabline    = (settings.show_tab_buffer ~= false) and 2 or 0 -- 2 to show tab buffer bar, 0 to completely hide it
opt.cmdheight      = settings.cmdheight or 0 -- 0 provides a modern clean UI
opt.pumheight      = 10         -- max items in popup menu
opt.scrolloff      = settings.scrolloff or 8
opt.sidescrolloff  = settings.scrolloff or 8
opt.wrap           = settings.wrap_lines == true
opt.colorcolumn    = settings.color_column or "80"
opt.linespace      = settings.line_height or 2 -- Extra vertical padding (GUIs)

-- Sleek window borders and hidden end of buffer markers
opt.fillchars      = { 
  eob = " ", 
  fold = " ", 
  foldopen = "", 
  foldsep = " ", 
  foldclose = "", 
  vert = "│", 
  diff = "╱" 
}

-- ── Indentation ──────────────────────────────────────────────────────────
opt.expandtab   = true
opt.shiftwidth  = settings.tab_size or 2
opt.tabstop     = settings.tab_size or 2
opt.smartindent = true

-- ── Search ───────────────────────────────────────────────────────────────
opt.ignorecase = settings.ignore_case_search ~= false
opt.smartcase  = true
opt.hlsearch   = true

-- ── Files & Encoding ─────────────────────────────────────────────────────
opt.fileencoding = "utf-8"
opt.undofile    = true
opt.swapfile    = false
opt.backup      = false
opt.clipboard   = "unnamedplus"

-- ── Windows & Splits ─────────────────────────────────────────────────────
opt.splitbelow = settings.split_below ~= false
opt.splitright = settings.split_right ~= false

-- ── Performance ──────────────────────────────────────────────────────────
opt.updatetime  = 250
opt.timeoutlen  = 300
-- Note: lazyredraw was removed in Neovim 0.10+, do not set it

-- ── Mouse ────────────────────────────────────────────────────────────────
opt.mouse = settings.mouse_support == true and "a" or ""

-- ── Neovide (GUI) ────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    if vim.g.neovide then
      vim.g.neovide_padding_top    = 10
      vim.g.neovide_padding_bottom = 10
      vim.g.neovide_padding_right  = 15
      vim.g.neovide_padding_left   = 15
      vim.g.neovide_transparency   = settings.neovide_transparency or 0.9
      vim.g.neovide_window_blurred = true
      vim.g.neovide_floating_blur_amount_x = 2.0
      vim.g.neovide_floating_blur_amount_y = 2.0
      vim.g.neovide_hide_mouse_when_typing = true
      vim.g.neovide_cursor_animation_length = 0.05
      vim.g.neovide_cursor_trail_size = 0.4
    end
  end,
})
