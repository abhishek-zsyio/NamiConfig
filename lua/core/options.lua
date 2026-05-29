local opt = vim.opt

-- Load user settings safely (defaults fallback if missing)
local ok, settings = pcall(require, "settings")
if not ok then settings = {} end

-- ── UI ────────────────────────────────────────────────────────────────────────
opt.background     = settings.background == "light" and "light" or "dark"
opt.number         = settings.show_line_numbers ~= false
opt.relativenumber = settings.relative_line_numbers == true
opt.cursorline     = settings.highlight_current_line ~= false
opt.cursorlineopt  = "both"           -- highlight number + line
opt.signcolumn     = "yes"
opt.termguicolors  = true
opt.showmode       = false            -- lualine shows the mode
opt.cmdheight      = settings.cmdheight or 0
opt.pumheight      = 10
opt.scrolloff      = settings.scrolloff or 8
opt.sidescrolloff  = settings.scrolloff or 8
opt.wrap           = settings.wrap_lines == true
opt.colorcolumn    = settings.color_column or "80"
opt.linespace      = settings.line_height or 2

-- Sleek fillchars — clean folds, diff marks, and vertical splits
opt.fillchars = {
  eob       = " ",    -- hide end-of-buffer ~ marks
  fold      = " ",
  foldopen  = "▾",
  foldsep   = " ",
  foldclose = "▸",
  vert      = "│",    -- subtle vertical split line
  diff      = "╱",
}

-- ── Folds (using nvim-ufo / treesitter where available) ──────────────────────
opt.foldcolumn     = "1"
opt.foldlevel      = 99               -- start with all folds open
opt.foldlevelstart = 99
opt.foldenable     = true

-- ── Indentation ───────────────────────────────────────────────────────────────
opt.expandtab   = true
opt.shiftwidth  = settings.tab_size or 2
opt.tabstop     = settings.tab_size or 2
opt.smartindent = true
opt.shiftround  = true                -- round indent to shiftwidth multiple

-- ── Search ────────────────────────────────────────────────────────────────────
opt.ignorecase = settings.ignore_case_search ~= false
opt.smartcase  = true
opt.hlsearch   = true
opt.incsearch  = true

-- ── Files & Encoding ──────────────────────────────────────────────────────────
opt.fileencoding = "utf-8"
opt.undofile     = true
opt.undolevels   = 10000
opt.swapfile     = false
opt.backup       = false
opt.clipboard    = "unnamedplus"
opt.autowrite    = false

-- ── Windows & Splits ──────────────────────────────────────────────────────────
opt.splitbelow = settings.split_below ~= false
opt.splitright = settings.split_right ~= false
opt.splitkeep  = "screen"             -- keep screen stable when splitting

-- ── Performance ───────────────────────────────────────────────────────────────
opt.updatetime  = 250
opt.timeoutlen  = 300
opt.redrawtime  = 1500
opt.synmaxcol   = 300                 -- don't highlight long lines past 300 chars

-- ── Mouse ─────────────────────────────────────────────────────────────────────
opt.mouse = settings.mouse_support == true and "a" or ""

-- ── Completion ────────────────────────────────────────────────────────────────
opt.completeopt = { "menuone", "noselect", "noinsert" }

-- ── Misc Quality of Life ──────────────────────────────────────────────────────
opt.shortmess:append("sI")            -- suppress intro message
opt.whichwrap:append("<>[]hl")        -- move across line boundaries with arrows
opt.virtualedit = "block"             -- allow cursor beyond EOL in visual-block
opt.smoothscroll = true               -- smooth pixel-level scrolling (nvim 0.10+)
opt.conceallevel = 2                  -- hide markup in markdown / org files

-- ── Neovide (GUI) ────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    if vim.g.neovide then
      vim.g.neovide_padding_top    = 10
      vim.g.neovide_padding_bottom = 10
      vim.g.neovide_padding_right  = 15
      vim.g.neovide_padding_left   = 15
      vim.g.neovide_transparency   = settings.neovide_transparency or 0.95
      vim.g.neovide_window_blurred = true
      vim.g.neovide_floating_blur_amount_x = 2.0
      vim.g.neovide_floating_blur_amount_y = 2.0
      vim.g.neovide_hide_mouse_when_typing = true
      vim.g.neovide_cursor_animation_length = 0.05
      vim.g.neovide_cursor_trail_size = 0.4
      vim.g.neovide_cursor_vfx_mode  = "railgun"  -- cursor particle effect
    end
  end,
})
