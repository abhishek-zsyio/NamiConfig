local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── Highlight on Yank ─────────────────────────────────────────────────────────
autocmd("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- ── Restore cursor position on file open ─────────────────────────────────────
autocmd("BufReadPost", {
  group = augroup("RestoreCursor", { clear = true }),
  callback = function(ev)
    local mark  = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── Auto-resize splits when terminal is resized ───────────────────────────────
autocmd("VimResized", {
  group = augroup("ResizeSplits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- ── Close auxiliary filetypes with just 'q' ──────────────────────────────────
autocmd("FileType", {
  group   = augroup("QuickClose", { clear = true }),
  pattern = {
    "qf", "help", "man", "notify", "lspinfo",
    "spectre_panel", "startuptime", "tsplayground", "checkhealth",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
  end,
})

-- ── Strip trailing whitespace on save ────────────────────────────────────────
autocmd("BufWritePre", {
  group = augroup("StripTrailingWS", { clear = true }),
  callback = function(ev)
    if not vim.bo[ev.buf].modifiable then return end
    local save = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- ── Django HTML filetype detection ───────────────────────────────────────────
-- Evaluated per-buffer (not at startup) so it works even after cwd changes.
autocmd({ "BufNewFile", "BufRead" }, {
  group   = augroup("DjangoFiletype", { clear = true }),
  pattern = "*.html",
  callback = function()
    if vim.fn.filereadable(vim.fn.getcwd() .. "/manage.py") == 1 then
      vim.bo.filetype = "htmldjango"
    end
  end,
})

-- ── Disable Dropbar for Snacks windows ───────────────────────────────────────
autocmd("FileType", {
  group   = augroup("DisableDropbar", { clear = true }),
  pattern = {
    "snacks_picker_list", "snacks_picker_input",
    "snacks_picker_preview", "snacks_layout_box", "snacks_terminal",
  },
  callback = function(ev)
    vim.b[ev.buf].dropbar_enable = false
  end,
})

-- ── Hot Reload Settings ───────────────────────────────────────────────────────
-- Automatically applies setting changes when lua/settings.lua is saved.
autocmd({ "BufWritePost", "FileChangedShellPost" }, {
  group   = augroup("HotReloadSettings", { clear = true }),
  pattern = "*/lua/settings.lua",
  callback = function()
    local ok, settings = pcall(function()
      return require("core.settings_loader").load()
    end)
    if not ok then
      vim.notify("Error reloading settings: " .. tostring(settings), vim.log.levels.ERROR)
      return
    end

    -- Re-apply colorscheme
    local theme_id = settings.ui and settings.ui.theme or settings.theme
    if theme_id then
      local reg = require("core.theme_registry")
      for _, t in ipairs(reg) do
        if t.id == theme_id then
          local transparent = settings.ui and settings.ui.transparent or settings.transparent
          if t.setup then t.setup(transparent == true) end
          pcall(vim.cmd, "colorscheme " .. (t.colorscheme or t.id))
          break
        end
      end
    end

    local bg = settings.ui and settings.ui.background or settings.background
    if bg then vim.o.background = bg end

    -- Live-update common window options (support both flat and nested keys)
    local ed = settings.editor or {}
    local show_nums    = ed.show_line_numbers    ~= nil and ed.show_line_numbers    or settings.show_line_numbers
    local rel_nums     = ed.relative_line_numbers~= nil and ed.relative_line_numbers or settings.relative_line_numbers
    local wrap         = ed.wrap_lines           ~= nil and ed.wrap_lines           or settings.wrap_lines
    local col_col      = ed.color_column or settings.color_column
    if show_nums  ~= nil then vim.wo.number         = show_nums  end
    if rel_nums   ~= nil then vim.wo.relativenumber = rel_nums   end
    if wrap       ~= nil then vim.wo.wrap           = wrap       end
    if col_col           then vim.wo.colorcolumn    = col_col    end

    vim.notify("Settings reloaded 🚀", vim.log.levels.INFO, { title = "Config" })
  end,
})

-- ── Large file performance guard ─────────────────────────────────────────────
-- Disables heavy features for files > 500 KB
autocmd("BufReadPre", {
  group = augroup("LargeFile", { clear = true }),
  callback = function(ev)
    local size = vim.fn.getfsize(ev.file)
    if size > 500 * 1024 then
      vim.bo[ev.buf].syntax      = "off"
      vim.wo.foldmethod          = "manual"
      vim.wo.foldexpr            = ""
      vim.b[ev.buf].large_file   = true
      vim.notify(
        "Large file detected — some features disabled for performance.",
        vim.log.levels.WARN
      )
    end
  end,
})
