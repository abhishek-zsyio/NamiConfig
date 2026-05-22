local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ── General ───────────────────────────────────────────────────────────────
map("i", "jk", "<ESC>",            { desc = "Escape insert mode" })
map("n", ";",  ":",                 { desc = "Command mode", noremap = true })
map("n", "<Esc>", "<cmd>nohl<CR>", { desc = "Clear highlights" })

-- Insert Mode Navigation (NvChad style)
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

-- ── Buffer Navigation (NvChad style) ─────────────────────────────────────
map("n", "<Tab>",   "<cmd>bnext<CR>",     { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "<leader>x", function()
  local bd = require("mini.bufremove")
  bd.delete(0, false)
end, { desc = "Close buffer" })

-- ── File Tree (NvimTree) ─────────────────────────────────────────────────
map("n", "<C-n>",     "<cmd>NvimTreeToggle<CR>",   { desc = "Toggle NvimTree" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>",    { desc = "Focus NvimTree" })

-- ── Telescope ─────────────────────────────────────────────────────────────
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>",     { desc = "Find files" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find theme=dropdown<CR>", { desc = "Fuzzy find in current buffer" })
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>",      { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",        { desc = "Find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",      { desc = "Help tags" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>",       { desc = "Old files" })
map("n", "<leader>th", function()
  -- Force Telescope to load so telescope-ui-select patches vim.ui.select
  require("telescope")
  
  local themes = { "catppuccin", "onedark", "tokyonight", "gruvbox", "rose-pine", "nord", "dracula", "kanagawa" }
  
  local ghostty_themes = {
    ["catppuccin"] = "Catppuccin Mocha",
    ["onedark"]    = "Atom One Dark",
    ["tokyonight"] = "TokyoNight",
    ["gruvbox"]    = "Gruvbox Dark",
    ["rose-pine"]  = "Rose Pine",
    ["nord"]       = "Nord",
    ["dracula"]    = "Dracula",
    ["kanagawa"]   = "Kanagawa Wave"
  }

  vim.ui.select(themes, { prompt = "Select Theme:" }, function(choice)
    if choice then
      -- 1. Hot reload the Neovim theme
      vim.cmd.colorscheme(choice)
      
      -- 2. Save it permanently to settings.lua
      local settings_path = vim.fn.stdpath("config") .. "/lua/settings.lua"
      local lines = vim.fn.readfile(settings_path)
      for i, line in ipairs(lines) do
        if line:match('^%s*theme%s*=%s*["\']') then
          lines[i] = '  theme = "' .. choice .. '",'
          break
        end
      end
      vim.fn.writefile(lines, settings_path)
      
      -- 3. Hot reload Ghostty terminal to match
      local ghostty_path = vim.fn.expand("~/.config/ghostty/config")
      if vim.fn.filereadable(ghostty_path) == 1 then
        local g_lines = vim.fn.readfile(ghostty_path)
        for i, line in ipairs(g_lines) do
          if line:match('^theme%s*=') then
            g_lines[i] = 'theme = "' .. ghostty_themes[choice] .. '"'
            break
          end
        end
        -- Use standard Lua I/O to preserve the inode so Ghostty's file watcher triggers
        local file = io.open(ghostty_path, "w")
        if file then
          file:write(table.concat(g_lines, "\n") .. "\n")
          file:close()
        end
      end

      vim.notify("Theme synced to " .. choice .. " (Neovim + Ghostty)!", vim.log.levels.INFO)
    end
  end)
end, { desc = "Select & Save Theme (Sync Ghostty)" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>",     { desc = "Git status" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>",    { desc = "Git commits" })
map("n", "<leader>ma", "<cmd>Telescope marks<CR>",          { desc = "Find marks" })

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
  vim.lsp.buf.format({ async = true })
end, { desc = "LSP Format" })
map("n", "<leader>ds",  "<cmd>Telescope diagnostics<CR>", { desc = "LSP diagnostics" })
map("n", "[d",          vim.diagnostic.goto_prev,     { desc = "Prev diagnostic" })
map("n", "]d",          vim.diagnostic.goto_next,     { desc = "Next diagnostic" })

-- ── DAP Debugging ─────────────────────────────────────────────────────────
map("n", "<leader>db",  "<cmd>DapToggleBreakpoint<CR>",  { desc = "DAP Toggle breakpoint" })
map("n", "<leader>dc",  "<cmd>DapContinue<CR>",          { desc = "DAP Continue" })
map("n", "<leader>dso", "<cmd>DapStepOver<CR>",          { desc = "DAP Step over" })
map("n", "<leader>dsi", "<cmd>DapStepIn<CR>",            { desc = "DAP Step in" })
map("n", "<leader>dt",  "<cmd>DapTerminate<CR>",         { desc = "DAP Terminate" })

-- ── Git ───────────────────────────────────────────────────────────────────
map("n", "<leader>gg",  "<cmd>LazyGit<CR>",              { desc = "Open LazyGit" })

-- ── Noice ─────────────────────────────────────────────────────────────────
map("n", "<leader>cn",  "<cmd>NoiceDismiss<CR>",         { desc = "Dismiss Noice message" })

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
