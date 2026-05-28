-- ─────────────────────────────────────────────────────────────────────────────
-- core/theme_picker.lua  (v3)
-- Three-panel floating UI: Search, List, Preview
-- ─────────────────────────────────────────────────────────────────────────────

local M = {}

-- ── Tiny helpers ─────────────────────────────────────────────────────────────

local function get_hl(name)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return ok and h or {}
end
local function hex(name, attr)
  local v = get_hl(name)[attr]
  return v and ("#%06x"):format(v) or nil
end

local function rpad(s, w)          -- right-pad string to exact width
  local n = #s
  if n >= w then return s:sub(1, w) end
  return s .. string.rep(" ", w - n)
end

-- ── Ghostty / settings persistence ───────────────────────────────────────────

local function sync_ghostty(ghostty_theme)
  if not ghostty_theme then return end
  local path = vim.fn.expand("~/.config/ghostty/config")
  if vim.fn.filereadable(path) ~= 1 then return end
  local lines = vim.fn.readfile(path)
  for i, l in ipairs(lines) do
    if l:match("^theme%s*=") then lines[i] = "theme = " .. ghostty_theme; break end
  end
  local f = io.open(path, "w")
  if f then f:write(table.concat(lines, "\n") .. "\n"); f:close() end
  if vim.fn.has("mac") == 1 then
    os.execute([[osascript -e 'tell application "System Events" to keystroke "," using {command down, shift down}']])
  end
end

local function save_theme(id)
  local p = vim.fn.stdpath("config") .. "/lua/settings.lua"
  local lines = vim.fn.readfile(p)
  for i, l in ipairs(lines) do
    local pre, q = l:match("^(%s*theme%s*=%s*)([\"'])")
    if pre and q then lines[i] = pre .. q .. id .. q .. ","; break end
  end
  vim.fn.writefile(lines, p)
end

local function apply_theme(t)
  if not t then return end
  local ok, s = pcall(require, "settings")
  if t.setup then t.setup(ok and s.transparent or false) end
  pcall(vim.cmd.colorscheme, t.colorscheme or t.id)
  sync_ghostty(t.ghostty)
end

-- ── Theme lists ───────────────────────────────────────────────────────────────

local LIGHT = {
  ["catppuccin-latte"]=true, ["tokyonight-day"]=true, ["rose-pine-dawn"]=true,
  ["kanagawa-lotus"]=true,   ["github_light"]=true,   ["dayfox"]=true,
  ["onedark-light"]=true,    ["ayu-light"]=true,       ["cyberdream-light"]=true,
  ["material-lighter"]=true,
}

-- ── Preview code ──────────────────────────────────────────────────────────────

local PREVIEW = [[
-- Active theme: %s
local M = {}

--- Greet a user by name.
---@param name string
function M.greet(name)
  local msg = string.format("Hello, %%s!", name)
  return msg
end

local colors = {
  primary  = "#89b4fa",
  success  = "#a6e3a1",
  warning  = "#f9e2af",
  error    = "#f38ba8",
}

local function render(tbl)
  for k, v in pairs(tbl) do
    if type(v) == "string" then
      print(k .. " = " .. v)
    end
  end
end

render(colors)
return M
]]

-- ── Highlight groups ──────────────────────────────────────────────────────────

local NS = vim.api.nvim_create_namespace("ThemePickerV3")

local function setup_hls()
  local bg      = hex("NormalFloat", "bg") or hex("Normal", "bg") or "#1e1e2e"
  local fg      = hex("NormalFloat", "fg") or hex("Normal", "fg") or "#cdd6f4"
  local accent  = hex("Function",    "fg") or "#89b4fa"
  local comment = hex("Comment",     "fg") or "#6c7086"
  local keyword = hex("Keyword",     "fg") or "#cba6f7"
  local sel_bg  = hex("PmenuSel",    "bg") or hex("Visual", "bg") or "#313244"
  local sel_fg  = hex("PmenuSel",    "fg") or hex("Keyword", "fg") or "#cba6f7"
  local border  = hex("FloatBorder", "fg") or hex("Comment", "fg") or "#45475a"

  local function s(n, t) vim.api.nvim_set_hl(0, n, t) end
  s("TpNormal",   { bg = bg,     fg = fg })
  s("TpBorder",   { bg = bg,     fg = border })
  s("TpSel",      { bg = sel_bg, fg = sel_fg, bold = true })
  s("TpSep",      { bg = bg,     fg = comment, bold = true })
  s("TpIcon",     { bg = bg,     fg = accent })
  s("TpText",     { bg = bg,     fg = fg })
  s("TpDim",      { bg = bg,     fg = comment })
  s("TpTitle",    { bg = bg,     fg = accent, bold = true })
end

-- ── State ─────────────────────────────────────────────────────────────────────

local st = {}

local function reset()
  st.items          = {}
  st.filtered_items = {}
  st.cursor         = 1
  st.wins           = {}
  st.bufs           = {}
  st.original       = nil
  st.query          = ""
end

-- ── Forward declarations ──────────────────────────────────────────────────────
local render_list, render_preview, render, move, confirm, cancel, update_filter

-- ── Windows management ────────────────────────────────────────────────────────

local function close_wins()
  pcall(vim.api.nvim_del_augroup_by_name, "ThemePickerV3")
  
  for _, w in pairs(st.wins) do
    if type(w) == "number" and vim.api.nvim_win_is_valid(w) then
      pcall(vim.api.nvim_win_close, w, true)
    end
  end
  st.wins = {}
  st.bufs = {}
  
  vim.cmd("stopinsert")
end

cancel = function()
  close_wins()
  if st.original then
    apply_theme(st.original)
    sync_ghostty(st.original.ghostty)
  end
end

confirm = function()
  local item = st.filtered_items[st.cursor]
  if not item or item.sep or item.info then return end
  close_wins()
  apply_theme(item)
  sync_ghostty(item.ghostty)
  save_theme(item.id)
  vim.notify(" Theme applied: " .. item.id, vim.log.levels.INFO)
end

-- ── Rendering ──────────────────────────────────────────────────────────────────

local LEFT_W = 34
local PREVIEW_W = 60

render_list = function()
  local buf = st.bufs.list
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end

  local lines = {}
  local hi    = {}

  for idx, item in ipairs(st.filtered_items) do
    if item.sep then
      local label = "  " .. item.label
      table.insert(lines, rpad(label, LEFT_W))
      table.insert(hi, { #lines - 1, 0, -1, "TpSep" })
    elseif item.info then
      local label = "  " .. item.label
      table.insert(lines, rpad(label, LEFT_W))
      table.insert(hi, { #lines - 1, 0, -1, "TpDim" })
    else
      local icon = item.icon or "󰏘 "
      local name = item.id
      local max_w = LEFT_W - 5
      if #name > max_w then name = name:sub(1, max_w - 1) .. "…" end
      
      local line
      if idx == st.cursor then
        line = " ➔ " .. icon .. " " .. rpad(name, max_w - 2)
      else
        line = "   " .. icon .. " " .. rpad(name, max_w - 2)
      end
      table.insert(lines, line)

      local row = #lines - 1
      if idx == st.cursor then
        table.insert(hi, { row, 0, -1, "TpSel" })
      else
        table.insert(hi, { row, 3, 7,  "TpIcon" })
        table.insert(hi, { row, 7, -1, "TpText" })
      end
    end
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)
  for _, h in ipairs(hi) do
    vim.api.nvim_buf_add_highlight(buf, NS, h[4], h[1], h[2], h[3])
  end

  -- Scroll list window to selected line
  local win = st.wins.list
  if win and vim.api.nvim_win_is_valid(win) then
    pcall(vim.api.nvim_win_set_cursor, win, { st.cursor, 0 })
  end
end

render_preview = function()
  local buf = st.bufs.preview
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end

  local item = st.filtered_items[st.cursor]
  local name = (item and not item.sep and not item.info and item.id) or "—"
  local code = PREVIEW:format(name)

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(code, "\n"))
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype   = "lua"

  -- Dynamic title
  local win = st.wins.preview
  if win and vim.api.nvim_win_is_valid(win) and item and not item.sep and not item.info then
    local title = "  Theme: " .. item.id .. "  "
    pcall(vim.api.nvim_win_set_config, win, {
      title = title,
      title_pos = "center",
    })
  end
end

render = function()
  render_list()
  render_preview()
end

-- ── Filtering & Selection ─────────────────────────────────────────────────────

update_filter = function(query)
  st.query = query:gsub("^%s*", ""):gsub("%s*$", "")
  
  local dark, light = {}, {}
  for _, t in ipairs(st.items) do
    if st.query == "" or t.id:lower():find(st.query:lower(), 1, true) then
      table.insert(LIGHT[t.id] and light or dark, t)
    end
  end
  
  table.sort(dark,  function(a,b) return a.id < b.id end)
  table.sort(light, function(a,b) return a.id < b.id end)
  
  local filtered = {}
  if #dark > 0 then
    table.insert(filtered, { sep = true, label = "DARK THEMES" })
    for _, t in ipairs(dark) do table.insert(filtered, t) end
  end
  if #light > 0 then
    table.insert(filtered, { sep = true, label = "LIGHT THEMES" })
    for _, t in ipairs(light) do table.insert(filtered, t) end
  end
  
  if #filtered == 0 then
    table.insert(filtered, { info = true, label = "No matching themes" })
  end
  
  st.filtered_items = filtered
  
  -- Keep cursor inside bounds
  if st.cursor > #st.filtered_items then
    st.cursor = 1
  end
  
  local item = st.filtered_items[st.cursor]
  if not item or item.sep or item.info then
    local found = false
    for i, it in ipairs(st.filtered_items) do
      if not it.sep and not it.info then
        st.cursor = i
        found = true
        break
      end
    end
    if not found then st.cursor = 1 end
  end
  
  render()
  
  local curr_item = st.filtered_items[st.cursor]
  if curr_item and not curr_item.sep and not curr_item.info then
    apply_theme(curr_item)
  end
end

move = function(dir)
  local n = #st.filtered_items
  if n == 0 then return end
  
  local curr = st.cursor
  local steps = 0
  while steps < n do
    curr = curr + dir
    if curr > n then curr = 1 end
    if curr < 1 then curr = n end
    
    local item = st.filtered_items[curr]
    if item and not item.sep and not item.info then
      st.cursor = curr
      apply_theme(item)
      render()
      return
    end
    steps = steps + 1
  end
end

-- ── Keymaps ───────────────────────────────────────────────────────────────────

local function bind_input(buf)
  local o = { buffer = buf, nowait = true, silent = true, noremap = true }
  
  -- Insert mode keys
  vim.keymap.set("i", "<CR>",    confirm,                 o)
  vim.keymap.set("i", "<Esc>",   cancel,                  o)
  vim.keymap.set("i", "<C-c>",   cancel,                  o)
  vim.keymap.set("i", "<C-j>",   function() move(1)  end, o)
  vim.keymap.set("i", "<C-k>",   function() move(-1) end, o)
  vim.keymap.set("i", "<Down>",  function() move(1)  end, o)
  vim.keymap.set("i", "<Up>",    function() move(-1) end, o)
  
  -- Normal mode keys
  vim.keymap.set("n", "<CR>",    confirm,                 o)
  vim.keymap.set("n", "q",       cancel,                  o)
  vim.keymap.set("n", "<Esc>",   cancel,                  o)
  vim.keymap.set("n", "j",       function() move(1)  end, o)
  vim.keymap.set("n", "k",       function() move(-1) end, o)
  vim.keymap.set("n", "<Down>",  function() move(1)  end, o)
  vim.keymap.set("n", "<Up>",    function() move(-1) end, o)
end

-- ── Open ──────────────────────────────────────────────────────────────────────

function M.open()
  if next(st.wins or {}) then return end
  reset()
  setup_hls()

  local registry = require("core.theme_registry")
  st.items = {}
  for _, t in ipairs(registry) do
    if t.ghostty and t.ghostty ~= "" then
      table.insert(st.items, t)
    end
  end

  -- Find active theme
  local cur = vim.g.colors_name or ""
  for _, t in ipairs(st.items) do
    if t.id == cur or (t.colorscheme and t.colorscheme == cur) then
      st.original = t; break
    end
  end

  -- Geometry
  local TOTAL_H = 20
  local TOTAL_W = LEFT_W + PREVIEW_W + 2

  local ui  = vim.api.nvim_list_uis()[1] or { width = 180, height = 50 }
  local row = math.floor((ui.height - TOTAL_H) / 2)
  local col = math.floor((ui.width  - TOTAL_W) / 2)

  -- Buffers
  local function mkbuf()
    local b = vim.api.nvim_create_buf(false, true)
    vim.bo[b].modifiable = false
    vim.bo[b].bufhidden  = "wipe"
    return b
  end

  st.bufs.input   = vim.api.nvim_create_buf(false, true)
  vim.bo[st.bufs.input].bufhidden = "wipe"
  vim.bo[st.bufs.input].modifiable = true
  
  st.bufs.list    = mkbuf()
  st.bufs.preview = mkbuf()

  local whl = "Normal:TpNormal,FloatBorder:TpBorder,NormalFloat:TpNormal"
  local function set_wo(w)
    vim.wo[w].number         = false
    vim.wo[w].relativenumber = false
    vim.wo[w].signcolumn     = "no"
    vim.wo[w].statuscolumn   = ""
    vim.wo[w].cursorline     = false
    vim.wo[w].wrap           = false
    vim.wo[w].winhighlight   = whl
  end

  -- Windows
  st.wins.input = vim.api.nvim_open_win(st.bufs.input, true, {
    relative  = "editor",
    style     = "minimal",
    border    = "rounded",
    row       = row,
    col       = col,
    width     = LEFT_W,
    height    = 1,
    title     = " 󰍉  Search Theme ",
    title_pos = "center",
  })
  set_wo(st.wins.input)

  st.wins.list = vim.api.nvim_open_win(st.bufs.list, false, {
    relative  = "editor",
    style     = "minimal",
    border    = "rounded",
    row       = row + 3,
    col       = col,
    width     = LEFT_W,
    height    = TOTAL_H - 3,
  })
  set_wo(st.wins.list)

  st.wins.preview = vim.api.nvim_open_win(st.bufs.preview, false, {
    relative  = "editor",
    style     = "minimal",
    border    = "rounded",
    row       = row,
    col       = col + LEFT_W + 2,
    width     = PREVIEW_W,
    height    = TOTAL_H,
    title     = "  Preview  ",
    title_pos = "center",
  })
  set_wo(st.wins.preview)

  -- Empty input initially
  vim.api.nvim_buf_set_lines(st.bufs.input, 0, -1, false, { "" })

  -- Keymaps
  bind_input(st.bufs.input)

  -- Autocmds for interactive filtering
  local ag = vim.api.nvim_create_augroup("ThemePickerV3", { clear = true })
  
  vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
    group    = ag,
    buffer   = st.bufs.input,
    callback = function()
      local query = vim.api.nvim_buf_get_lines(st.bufs.input, 0, -1, false)[1] or ""
      update_filter(query)
    end,
  })

  -- Cancel on click-away
  vim.api.nvim_create_autocmd("WinLeave", {
    group    = ag,
    callback = function()
      vim.schedule(function()
        local cw = vim.api.nvim_get_current_win()
        local in_picker = cw == st.wins.input or cw == st.wins.list or cw == st.wins.preview
        if not in_picker and next(st.wins) then
          cancel()
        end
      end)
    end,
  })

  -- Find active theme cursor position initially
  update_filter("")
  
  if st.original then
    for i, t in ipairs(st.filtered_items) do
      if not t.sep and not t.info and t.id == st.original.id then
        st.cursor = i
        break
      end
    end
    render()
  end

  -- Enter insert mode
  vim.cmd("startinsert!")
end

return M
