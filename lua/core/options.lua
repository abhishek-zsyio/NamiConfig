local opt = vim.opt

-- ── UI ────────────────────────────────────────────────────────────────────
opt.number         = true
opt.relativenumber = false
opt.cursorline     = true
opt.cursorlineopt  = "both"
opt.signcolumn     = "yes"
opt.termguicolors  = true
opt.showmode       = false      -- lualine shows the mode
opt.cmdheight      = 1
opt.pumheight      = 10         -- max items in popup menu
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.wrap           = false
opt.colorcolumn    = "80"
opt.fillchars      = { eob = " " }  -- hide the ~ on empty lines

-- ── Indentation ──────────────────────────────────────────────────────────
opt.expandtab   = true
opt.shiftwidth  = 2
opt.tabstop     = 2
opt.smartindent = true

-- ── Search ───────────────────────────────────────────────────────────────
opt.ignorecase = true
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
opt.splitbelow = true
opt.splitright = true

-- ── Performance ──────────────────────────────────────────────────────────
opt.updatetime  = 250
opt.timeoutlen  = 300
opt.lazyredraw  = false

-- ── Mouse ────────────────────────────────────────────────────────────────
opt.mouse = ""   -- disabled (NvChad default for terminal users)

-- ── Neovide (GUI) ────────────────────────────────────────────────────────
if vim.g.neovide then
  vim.g.neovide_padding_top    = 5
  vim.g.neovide_padding_bottom = 5
  vim.g.neovide_padding_right  = 5
  vim.g.neovide_padding_left   = 5
end
