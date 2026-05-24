local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ── General ───────────────────────────────────────────────────────────────
map("i", "jk", "<ESC>",            { desc = "Escape insert mode" })
map("n", ";",  ":",                 { desc = "Command mode", noremap = true })
map("n", "<Esc>", "<cmd>nohl<CR>", { desc = "Clear highlights" })

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
  
  local registry = require("core.theme_registry")
  local themes = {}
  local ghostty_themes = {}
  local icons = {}

  for _, t in ipairs(registry) do
    table.insert(themes, t.id)
    ghostty_themes[t.id] = t.ghostty
    icons[t.id] = t.icon
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local current_theme = vim.g.colors_name or "catppuccin"

  pickers.new({}, {
    prompt_title = "Select Theme",
    finder = finders.new_table({
      results = themes,
      entry_maker = function(entry)
        return {
          value = entry,
          display = (icons[entry] or "󰏘 ") .. " " .. entry,
          ordinal = entry,
        }
      end
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      local function live_preview()
        local selection = action_state.get_selected_entry()
        if selection then
          pcall(vim.cmd.colorscheme, selection.value)
        end
      end

      map("i", "<C-j>", function() actions.move_selection_next(prompt_bufnr) live_preview() end)
      map("i", "<C-k>", function() actions.move_selection_previous(prompt_bufnr) live_preview() end)
      map("i", "<Down>", function() actions.move_selection_next(prompt_bufnr) live_preview() end)
      map("i", "<Up>", function() actions.move_selection_previous(prompt_bufnr) live_preview() end)

      local function restore_and_close()
        pcall(vim.cmd.colorscheme, current_theme)
        actions.close(prompt_bufnr)
      end
      map("i", "<Esc>", restore_and_close)
      map("n", "<Esc>", restore_and_close)

      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if not selection then return end
        local choice = selection.value
        
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
      return true
    end,
  }):find()
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
map("n", "<leader>db",  "<cmd>DapToggleBreakpoint<CR>",  { desc = "DAP Toggle breakpoint" })
map("n", "<leader>dc",  "<cmd>DapContinue<CR>",          { desc = "DAP Continue" })
map("n", "<leader>dso", "<cmd>DapStepOver<CR>",          { desc = "DAP Step over" })
map("n", "<leader>dsi", "<cmd>DapStepIn<CR>",            { desc = "DAP Step in" })
map("n", "<leader>dt",  "<cmd>DapTerminate<CR>",         { desc = "DAP Terminate" })

-- ── Git ───────────────────────────────────────────────────────────────────
map("n", "<leader>gg",  "<cmd>LazyGit<CR>",              { desc = "Open LazyGit" })
map("n", "<leader>gd", function()
  if next(require('diffview.lib').views) == nil then
    vim.cmd('DiffviewOpen')
  else
    vim.cmd('DiffviewClose')
  end
end, { desc = "Toggle Git Diffview" })

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
