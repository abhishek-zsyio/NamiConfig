local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── Highlight on Yank ─────────────────────────────────────────────────────
autocmd("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- ── Restore cursor position on file open ─────────────────────────────────
autocmd("BufReadPost", {
  group = augroup("RestoreCursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── Auto-resize splits when Neovim is resized ────────────────────────────
autocmd("VimResized", {
  group = augroup("ResizeSplits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- ── Close certain filetypes with just 'q' ────────────────────────────────
autocmd("FileType", {
  group = augroup("QuickClose", { clear = true }),
  pattern = {
    "qf", "help", "man", "notify", "lspinfo",
    "spectre_panel", "startuptime", "tsplayground",
    "checkhealth",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})

-- ── Strip trailing whitespace on save ────────────────────────────────────
autocmd("BufWritePre", {
  group = augroup("StripTrailingWS", { clear = true }),
  callback = function(event)
    if not vim.bo[event.buf].modifiable then
      return
    end
    local save = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- ── Django HTML filetype detection (when in a Django project) ─────────────
local function in_django_project()
  return vim.fn.filereadable(vim.fn.getcwd() .. "/manage.py") == 1
end
if in_django_project() then
  autocmd({ "BufNewFile", "BufRead" }, {
    group = augroup("DjangoFiletype", { clear = true }),
    pattern = "*.html",
    callback = function()
      vim.bo.filetype = "htmldjango"
    end,
  })
end

-- ── Disable Dropbar for Snacks Picker ──────────────────────────────────────
autocmd("FileType", {
  group = augroup("DisableDropbar", { clear = true }),
  pattern = { "snacks_picker_list", "snacks_picker_input", "snacks_picker_preview", "snacks_layout_box", "snacks_terminal" },
  callback = function(event)
    vim.b[event.buf].dropbar_enable = false
  end,
})


