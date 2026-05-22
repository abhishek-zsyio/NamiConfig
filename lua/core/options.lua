local opt = vim.opt

-- Load user settings safely (defaults fallback if missing)
local ok, settings = pcall(require, "settings")
if not ok then settings = {} end

-- ── UI ────────────────────────────────────────────────────────────────────
opt.number         = settings.show_line_numbers ~= false
opt.relativenumber = settings.relative_line_numbers == true
opt.cursorline     = settings.highlight_current_line ~= false -- highlight the current line
opt.cursorlineopt  = "both" -- highlight both the number and the lines"
opt.signcolumn     = "yes"
opt.termguicolors  = true
opt.showmode       = false      -- lualine shows the mode
opt.cmdheight      = 1
opt.pumheight      = 10         -- max items in popup menu
opt.scrolloff      = settings.scrolloff or 8
opt.sidescrolloff  = settings.scrolloff or 8
opt.wrap           = settings.wrap_lines == true
opt.colorcolumn    = settings.color_column or "80"
opt.fillchars      = { eob = " " }  -- hide the ~ on empty lines

-- ── Indentation ──────────────────────────────────────────────────────────
opt.expandtab   = true
opt.shiftwidth  = settings.tab_size or 2
opt.tabstop     = settings.tab_size or 2
opt.smartindent = true

-- ── Search ───────────────────────────────────────────────────────────────
opt.ignorecase = settings.ignore_case_search ~= false
opt.smartcase  = true
opt.hlsearch   = true
opt.incsearch  = true

-- ── Files & Encoding ─────────────────────────────────────────────────────
opt.encoding    = "utf-8"
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
opt.lazyredraw  = false

-- ── Mouse ────────────────────────────────────────────────────────────────
opt.mouse = settings.mouse_support == true and "a" or ""

-- ── Neovide (GUI) ────────────────────────────────────────────────────────
if vim.g.neovide then
  vim.g.neovide_padding_top    = 5
  vim.g.neovide_padding_bottom = 5
  vim.g.neovide_padding_right  = 5
  vim.g.neovide_padding_left   = 5
end
