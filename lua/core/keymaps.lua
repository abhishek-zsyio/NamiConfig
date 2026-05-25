local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ── General ───────────────────────────────────────────────────────────────
map("i", "jk", "<ESC>",            { desc = "Escape insert mode" })
map("n", ";",  ":",                 { desc = "Command mode", noremap = true })
map("n", "<Esc>", "<cmd>nohl<CR>", { desc = "Clear highlights" })
map("n", "<leader>ch", function()
  Snacks.scratch({ 
    icon = "󱗼", 
    name = "Cheat Sheet", 
    file = vim.fn.stdpath("config") .. "/cheatsheet.md", 
    wo = { wrap = false, number = false, relativenumber = false, cursorline = false, signcolumn = "no" },
    bo = { modifiable = false, readonly = true }
  })
end, { desc = "Open Cheat Sheet" })

map("n", "<leader>ce", "<cmd>edit " .. vim.fn.stdpath("config") .. "/cheatsheet.md<CR>", { desc = "Edit Cheat Sheet" })

-- Insert Mode Navigation
map("i", "<C-h>", "<Left>",  { desc = "Move left" })
map("i", "<C-l>", "<Right>", { desc = "Move right" })
map("i", "<C-j>", "<Down>",  { desc = "Move down" })
map("i", "<C-k>", "<Up>",    { desc = "Move up" })

-- ── Save / Quit ──────────────────────────────────────────────────────────
map("n", "<C-s>", "<cmd>w<CR>",  { desc = "Save file" })
map("n", "<C-q>", "<cmd>q<CR>",  { desc = "Quit" })

-- ── Move Lines (Alt + j/k) ───────────────────────────────────────────────
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", opts)
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", opts)
map("n", "<A-j>", ":m .+1<CR>==",        opts)
map("n", "<A-k>", ":m .-2<CR>==",        opts)
map("v", "<A-j>", ":m '>+1<CR>gv=gv",    opts)
map("v", "<A-k>", ":m '<-2<CR>gv=gv",    opts)

-- ── Better Indenting in Visual ────────────────────────────────────────────
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- ── Window Navigation ────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Navigate seamlessly out of terminal mode
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to below window" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to above window" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })

-- ── Buffer Navigation ────────────────────────────────────────────────────
map("n", "<Tab>",   "<cmd>bnext<CR>",     { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "<leader>x", function()
  local bd = require("mini.bufremove")
  bd.delete(0, false)
end, { desc = "Close buffer" })



-- ── Telescope ─────────────────────────────────────────────────────────────

-- ── Theme Switcher ──────────────────────────────────────────────────────────
map("n", "<leader>th", function()
  local registry = require("core.theme_registry")
  local themes = {}
  local ghostty_themes = {}
  local icons = {}

  for _, t in ipairs(registry) do
    table.insert(themes, t.id)
    ghostty_themes[t.id] = t.ghostty
    icons[t.id] = t.icon
  end

  vim.ui.select(themes, {
    prompt = "Select Theme (Syncs to Ghostty)",
    format_item = function(item)
      return (icons[item] or "󰏘 ") .. " " .. item
    end,
  }, function(choice)
    if not choice then return end
    vim.cmd.colorscheme(choice)
    
    local settings_path = vim.fn.stdpath("config") .. "/lua/settings.lua"
    local lines = vim.fn.readfile(settings_path)
    for i, line in ipairs(lines) do
      if line:match('^%s*theme%s*=%s*["\']') then
        lines[i] = '  theme = "' .. choice .. '",'
        break
      end
    end
    vim.fn.writefile(lines, settings_path)
    
    local ghostty_path = vim.fn.expand("~/.config/ghostty/config")
    if vim.fn.filereadable(ghostty_path) == 1 then
      local g_lines = vim.fn.readfile(ghostty_path)
      for i, line in ipairs(g_lines) do
        if line:match('^theme%s*=') then
          g_lines[i] = 'theme = ' .. ghostty_themes[choice]
          break
        end
      end
      local file = io.open(ghostty_path, "w")
      if file then
        file:write(table.concat(g_lines, "\n") .. "\n")
        file:close()
      end
      os.execute([[osascript -e 'tell application "System Events" to keystroke "," using {command down, shift down}']])
    end

    vim.notify("Theme synced to " .. choice .. " (Neovim + Ghostty)!", vim.log.levels.INFO)
  end)
end, { desc = "Select & Save Theme (Sync Ghostty)" })

-- ── Line Numbers ─────────────────────────────────────────────────────────
map("n", "<leader>n", "<cmd>set nu!<CR>",   { desc = "Toggle line number" })
map("n", "<leader>rn","<cmd>set rnu!<CR>",  { desc = "Toggle relative number" })

-- ── Comments ─────────────────────────────────────────────────────────────
-- Comment.nvim registers gcc/gc itself — these are the extra ones
map("n", "<leader>/", "gcc",         { desc = "Toggle comment", remap = true })
map("v", "<leader>/", "gc",          { desc = "Toggle comment", remap = true })

-- ── LSP ───────────────────────────────────────────────────────────────────
map("n", "gD",          vim.lsp.buf.declaration,      { desc = "LSP Declaration" })
map("n", "gd",          vim.lsp.buf.definition,       { desc = "LSP Definition" })
map("n", "gi",          vim.lsp.buf.implementation,   { desc = "LSP Implementation" })
map("n", "gr",          vim.lsp.buf.references,       { desc = "LSP References" })
map("n", "K",           vim.lsp.buf.hover,            { desc = "LSP Hover" })
map("n", "<leader>ca",  vim.lsp.buf.code_action,      { desc = "LSP Code action" })
map("n", "<leader>ra",  vim.lsp.buf.rename,           { desc = "LSP Rename" })
map("n", "<leader>fm", function()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ async = true, lsp_format = "fallback" })
  else
    vim.lsp.buf.format({ async = true })
  end
end, { desc = "Format Buffer" })
map("n", "<leader>ds",  "<cmd>Telescope diagnostics<CR>", { desc = "LSP diagnostics" })
map("n", "[d",          vim.diagnostic.goto_prev,     { desc = "Prev diagnostic" })
map("n", "]d",          vim.diagnostic.goto_next,     { desc = "Next diagnostic" })

-- ── DAP Debugging ─────────────────────────────────────────────────────────

-- ── Git ───────────────────────────────────────────────────────────────────



-- ── Visual Code Screenshot ─────────────────────────────────────────────────
map("v", "<leader>sc", ":Silicon<CR>",                   { desc = "Screenshot code" })

-- ── Python Venv ───────────────────────────────────────────────────────────
map("n", "<leader>vs",  "<cmd>VenvSelect<CR>",           { desc = "Select Python venv" })

-- ── Hard Mode: Disable Arrow Keys ─────────────────────────────────────────
local disabled = [[<cmd>echohl Error | echo "KEY DISABLED" | echohl None<CR>]]
map("i", "<Up>",    "<C-o>" .. disabled, { noremap = true })
map("i", "<Down>",  "<C-o>" .. disabled, { noremap = true })
map("i", "<Left>",  "<C-o>" .. disabled, { noremap = true })
map("i", "<Right>", "<C-o>" .. disabled, { noremap = true })
map("n", "<Up>",    disabled,            { noremap = true })
map("n", "<Down>",  disabled,            { noremap = true })
map("n", "<Left>",  disabled,            { noremap = true })
map("n", "<Right>", disabled,            { noremap = true })
