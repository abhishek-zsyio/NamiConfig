local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ── General ───────────────────────────────────────────────────────────────
map("i", "jk", "<ESC>",            { desc = "Escape insert mode" })
map("n", ";",  ":",                 { desc = "Command mode", noremap = true })
map("n", "<Esc>", "<cmd>nohl<CR>", { desc = "Clear highlights" })
map("n", "<leader>ch", function()
  local filepath = vim.fn.stdpath("config") .. "/cheatsheet.md"
  Snacks.scratch({ 
    icon = "󱗼", 
    name = "Cheat Sheet", 
    file = filepath, 
    wo = { wrap = false, number = false, relativenumber = false, cursorline = false, signcolumn = "no" },
    bo = { modifiable = false, readonly = true }
  })
  vim.schedule(function()
    local buf = vim.fn.bufnr(filepath)
    if buf ~= -1 and vim.api.nvim_buf_is_valid(buf) then
      vim.bo[buf].modifiable = false
      vim.bo[buf].readonly = true
    end
  end)
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
map("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit Neovim" })

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
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<C-x>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ── Buffer Navigation ────────────────────────────────────────────────────
map("n", "<Tab>",   "<cmd>bnext<CR>",     { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })


-- ── Theme Switcher ──────────────────────────────────────────────────────────
map("n", "<leader>th", function()
  local registry = require("core.theme_registry")
  local original_theme = vim.g.colors_name
  
  -- Find the original Ghostty theme to revert if cancelled
  local original_ghostty_theme = nil
  for _, t in ipairs(registry) do
    if t.id == original_theme or t.colorscheme == original_theme then
      original_ghostty_theme = t.ghostty
      break
    end
  end

  local function sync_ghostty(ghostty_theme)
    if not ghostty_theme then return end
    local ghostty_path = vim.fn.expand("~/.config/ghostty/config")
    if vim.fn.filereadable(ghostty_path) == 1 then
      local g_lines = vim.fn.readfile(ghostty_path)
      for i, line in ipairs(g_lines) do
        if line:match('^theme%s*=') then
          g_lines[i] = 'theme = ' .. ghostty_theme
          break
        end
      end
      local file = io.open(ghostty_path, "w")
      if file then
        file:write(table.concat(g_lines, "\n") .. "\n")
        file:close()
      end
      if vim.fn.has("mac") == 1 then
        os.execute([[osascript -e 'tell application "System Events" to keystroke "," using {command down, shift down}']])
      end
    end
  end

  local light_themes = {
    ["catppuccin-latte"] = true, ["tokyonight-day"] = true, ["rose-pine-dawn"] = true,
    ["kanagawa-lotus"] = true, ["github_light"] = true, ["dayfox"] = true,
    ["onedark-light"] = true, ["ayu-light"] = true, ["cyberdream-light"] = true,
    ["material-lighter"] = true
  }

  local dark_themes_list = {}
  local light_themes_list = {}

  for _, t in ipairs(registry) do
    if light_themes[t.id] then
      table.insert(light_themes_list, { text = t.id, value = t })
    else
      table.insert(dark_themes_list, { text = t.id, value = t })
    end
  end

  table.sort(dark_themes_list, function(a, b) return a.text < b.text end)
  table.sort(light_themes_list, function(a, b) return a.text < b.text end)

  local items = {}
  table.insert(items, { text = "   DARK THEMES", value = "separator" })
  for _, item in ipairs(dark_themes_list) do table.insert(items, item) end

  table.insert(items, { text = "", value = "spacer" })
  table.insert(items, { text = "   LIGHT THEMES", value = "separator" })
  for _, item in ipairs(light_themes_list) do table.insert(items, item) end

  Snacks.picker.pick({
    source = "themes",
    items = items,
    layout = {
      preset = require("settings").picker_layout or "vertical",
      width = require("settings").picker_width or 0.5,
      height = require("settings").picker_height or 0.8,
    },
    win = {
      input = { border = require("settings").menu_border or "rounded" },
      list = { border = require("settings").menu_border or "rounded" },
      preview = { border = require("settings").menu_border or "rounded" },
    },
    prompt = "Select Theme (Syncs to Ghostty)",
    format = function(item)
      if item.value == "spacer" then
        return {}
      end
      if item.value == "separator" then
        return {
          { item.text, "Title" },
        }
      end
      local t = item.value
      return {
        { "  " .. (t.icon or "󰏘 ") .. " ", "SnacksPickerIcon" },
        { t.id, "SnacksPickerText" },
      }
    end,
    preview = function(ctx)
      local buf = ctx.buf
      local lines = {
        "// ── Theme Preview Showcase (JavaScript/React) ──────────────────",
        "import React, { useState, useEffect } from 'react';",
        "",
        "const ThemeShowcase = ({ themeName, isAwesome }) => {",
        "  const [active, setActive] = useState(false);",
        "",
        "  useEffect(() => {",
        "    console.log(`Colorscheme previewed: ${themeName}`);",
        "  }, [themeName]);",
        "",
        "  const colors = {",
        "    accent: '#ff79c6',",
        "    info: '#8be9fd',",
        "    success: '#50fa7b',",
        "  };",
        "",
        "  return (",
        "    <div className=\"preview-container\" style={{ padding: '20px' }}>",
        "      <h1 style={{ color: colors.accent }}>{themeName}</h1>",
        "      <p style={{ color: colors.info }}>",
        "        This is a live syntax preview showing how your JS code",
        "        renders in this colorscheme.",
        "      </p>",
        "      <button",
        "        onClick={() => setActive(!active)}",
        "        disabled={!isAwesome}",
        "        style={{ background: colors.success }}",
        "      >",
        "        Toggle Accent State (Current: {active ? 'On' : 'Off'})",
        "      </button>",
        "    </div>",
        "  );",
        "};",
        "",
        "export default ThemeShowcase;",
      }
      vim.bo[buf].modifiable = true
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.bo[buf].modifiable = false
      vim.bo[buf].filetype = "javascriptreact"
    end,
    on_change = function(picker, item)
      if item and item.value ~= "separator" then
        if item.value.setup then
          local ok2, s2 = pcall(require, "settings")
          local transparent = (ok2 and s2.transparent)
          item.value.setup(transparent)
        end
        local cs = item.value.colorscheme or item.value.id
        pcall(vim.cmd.colorscheme, cs)
        sync_ghostty(item.value.ghostty)
      end
    end,
    on_close = function(picker)
      if not picker.confirmed and original_theme then
        -- We must find the original theme's setup if it needs to be restored!
        local orig_item
        for _, t in ipairs(registry) do
           if t.id == original_theme or t.colorscheme == original_theme then
              orig_item = t
              break
           end
        end
        if orig_item and orig_item.setup then
          local ok2, s2 = pcall(require, "settings")
          orig_item.setup(ok2 and s2.transparent)
        end
        pcall(vim.cmd.colorscheme, original_theme)
        if original_ghostty_theme then
          sync_ghostty(original_ghostty_theme)
        end
      end
    end,
    confirm = function(picker, item)
      if not item or item.value == "separator" then return end
      picker.confirmed = true
      picker:close()
      local choice = item.value.id
      
      local settings_path = vim.fn.stdpath("config") .. "/lua/settings.lua"
      local lines = vim.fn.readfile(settings_path)
      for i, line in ipairs(lines) do
        -- More robust match that preserves indentation and quote style
        local prefix, quote = line:match("^(%s*theme%s*=%s*)([\"'])")
        if prefix and quote then
          lines[i] = prefix .. quote .. choice .. quote .. ","
          break
        end
      end
      vim.fn.writefile(lines, settings_path)
      
      vim.notify("Theme synced to " .. choice .. " (Neovim + Ghostty)!", vim.log.levels.INFO)
    end,
  })
end, { desc = "Select & Save Theme (Sync Ghostty)" })

-- ── Line Numbers ─────────────────────────────────────────────────────────
map("n", "<leader>n", "<cmd>set nu!<CR>",   { desc = "Toggle line number" })
map("n", "<leader>rn","<cmd>set rnu!<CR>",  { desc = "Toggle relative number" })
map("n", "<leader>tc", "<cmd>TSContextToggle<CR>", { desc = "Toggle Treesitter Context" })



-- ── Visual Code Screenshot ─────────────────────────────────────────────────
map("v", "<leader>sc", ":Silicon<CR>",                   { desc = "Screenshot code" })

-- ── Python Venv ───────────────────────────────────────────────────────────
map("n", "<leader>vs", function()
  local s = require("settings")
  local paths = {}
  local cwd = vim.fn.getcwd()
  
  -- 1. Check workspace venvs
  local local_venvs = { "/.venv", "/venv" }
  for _, name in ipairs(local_venvs) do
    local p = cwd .. name .. "/bin/python"
    if vim.fn.executable(p) == 1 then
      table.insert(paths, { name = "Local: ." .. name, path = p })
    end
  end
  
  -- 2. Check ~/.virtualenvs
  local home_venv_dir = vim.fn.expand("~/.virtualenvs")
  if vim.fn.isdirectory(home_venv_dir) == 1 then
    local venvs = vim.fn.readdir(home_venv_dir)
    for _, name in ipairs(venvs) do
      local p = home_venv_dir .. "/" .. name .. "/bin/python"
      if vim.fn.executable(p) == 1 then
        table.insert(paths, { name = "Global: " .. name, path = p })
      end
    end
  end

  -- 3. Check poetry venvs
  local poetry_dir = vim.fn.expand("~/.cache/pypoetry/virtualenvs")
  if vim.fn.isdirectory(poetry_dir) == 1 then
    local venvs = vim.fn.readdir(poetry_dir)
    for _, name in ipairs(venvs) do
      local p = poetry_dir .. "/" .. name .. "/bin/python"
      if vim.fn.executable(p) == 1 then
        table.insert(paths, { name = "Poetry: " .. name, path = p })
      end
    end
  end

  if #paths == 0 and vim.env.VIRTUAL_ENV == nil then
    vim.notify("No virtual environments found!", vim.log.levels.WARN)
    return
  end

  local items = {}
  if vim.env.VIRTUAL_ENV ~= nil then
    table.insert(items, {
      text = "Deactivate Current Venv",
      value = "deactivate",
    })
  end
  for _, item in ipairs(paths) do
    table.insert(items, {
      text = item.name,
      value = item.path,
    })
  end

  Snacks.picker.pick({
    source = "venvs",
    items = items,
    prompt = "Select Python Virtual Environment",
    layout = {
      preset = s.picker_layout or "select",
      width = s.picker_width or 0.5,
      height = s.picker_height or 0.8,
    },
    win = {
      input = { border = s.menu_border or "rounded" },
      list = { border = s.menu_border or "rounded" },
      preview = { border = s.menu_border or "rounded" },
    },
    format = function(item)
      local icon = item.value == "deactivate" and "󰅙  " or "  "
      local hl = item.value == "deactivate" and "DiagnosticWarn" or "SnacksPickerText"
      return {
        { icon, "SnacksPickerIcon" },
        { item.text, hl },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if not item then return end
      
      if item.value == "deactivate" then
        vim.env.VIRTUAL_ENV = nil
        local default_py = vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
        for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
          client.config.settings.python.pythonPath = default_py
          client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
        vim.notify("Deactivated Python Virtual Environment", vim.log.levels.WARN)
        return
      end

      local py_path = item.value
      
      -- Set environment variables
      vim.env.VIRTUAL_ENV = py_path:gsub("/bin/python$", "")
      
      -- Update LSP clients
      for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
        client.config.settings.python.pythonPath = py_path
        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
      end
      
      vim.notify("Activated Venv: " .. item.text, vim.log.levels.INFO)
    end,
  })
end, { desc = "Select Python venv" })


-- ── Code Runner ───────────────────────────────────────────────────────────
map("n", "<leader>rr", function()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")

  if file == "" then
    vim.notify("No file to run!", vim.log.levels.WARN)
    return
  end

  -- Save buffer first
  vim.cmd("silent! write")

  local cmd

  if ft == "python" then
    -- Use venv python if active, else python3/python
    local py = (vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV .. "/bin/python")
      or vim.fn.exepath("python3")
      or vim.fn.exepath("python")
      or "python3"
    cmd = py .. " " .. vim.fn.shellescape(file)

  elseif ft == "javascript" or ft == "javascriptreact" then
    cmd = "node " .. vim.fn.shellescape(file)

  elseif ft == "typescript" or ft == "typescriptreact" then
    -- Prefer tsx (bun), ts-node, or npx ts-node
    if vim.fn.executable("tsx") == 1 then
      cmd = "tsx " .. vim.fn.shellescape(file)
    elseif vim.fn.executable("ts-node") == 1 then
      cmd = "ts-node " .. vim.fn.shellescape(file)
    else
      cmd = "npx --yes ts-node " .. vim.fn.shellescape(file)
    end

  else
    vim.notify("No runner configured for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  local fname = vim.fn.expand("%:t")

  -- Pass file path via env var to avoid all single-quote / shellescape issues
  -- inside the bash -c '...' wrapper.
  local env_vars = {
    RUNNER_FILE = file,
    RUNNER_NAME = fname,
    RUNNER_CMD  = cmd,        -- e.g. "node" / "python3" / "tsx"
  }

  -- Pretty ANSI wrapper ────────────────────────────────────────────────────
  --   • dynamic-width separator using tput cols
  --   • header: file icon + name + timestamp
  --   • green ✓ / red ✗ footer with exit code
  --   • silent read -n1 so the pressed key isn't echoed
  local script = [[
clear
_w=$(tput cols 2>/dev/null || echo 72)
_sep=$(printf '%*s' "$_w" '' | tr ' ' '─')
_ts=$(date '+%H:%M:%S')

# ── header ────────────────────────────────────────────────────────────
printf '\033[38;5;239m%s\033[0m\n' "$_sep"
printf '  \033[1;38;5;75m▶  %s\033[0m   \033[38;5;240m%s\033[0m\n' "$RUNNER_NAME" "$_ts"
printf '\033[38;5;239m%s\033[0m\n\n' "$_sep"

# ── run ───────────────────────────────────────────────────────────────
eval "$RUNNER_CMD \"$RUNNER_FILE\""
_x=$?

# ── footer ────────────────────────────────────────────────────────────
printf '\n\033[38;5;239m%s\033[0m\n' "$_sep"
if [ "$_x" -eq 0 ]; then
  printf '  \033[1;32m✓  Done\033[0m  \033[38;5;240m(exit 0)\033[0m   \033[38;5;245m· press any key to close\033[0m\n'
else
  printf '  \033[1;31m✗  Exited with error\033[0m  \033[38;5;240m(exit %s)\033[0m   \033[38;5;245m· press any key to close\033[0m\n' "$_x"
fi
read -n1 -s
]]

  local term = Snacks.terminal("bash -c " .. vim.fn.shellescape(script), {
    env = env_vars,
    win = {
      position    = "bottom",
      height      = 0.35,
      border      = require("settings").menu_border or "rounded",
      title       = " ▶ " .. fname .. " ",
      title_pos   = "center",
    },
    bo = { filetype = "snacks_terminal" },
  })
  if term and term.buf and vim.api.nvim_buf_is_valid(term.buf) then
    pcall(vim.api.nvim_buf_set_name, term.buf, "runner: " .. fname)
  end

end, { desc = "Run current file (Node / Python)" })

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
