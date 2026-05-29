-- ─────────────────────────────────────────────────────────────────────────────
-- core/theme_picker.lua  (v5)
--
-- Layout (single search bar spans full width):
--
--   ┌──────────────────────────────────────────────────────────────┐
--   │  󰍉  search themes…                              42 themes    │  ← search bar
--   ├────────────────────────┬─────────────────────────────────────┤
--   │ dark                   │  catppuccin-mocha      dark │ catppuccin/nvim │
--   │  ➔ 󰄛  catppuccin-mocha │ ─────────────────────────────────── │
--   │     󰄛  catppuccin-…   │  -- active theme: catppuccin-mocha  │
--   │     󰖔  tokyonight-…   │  local M = {}                       │
--   │  …                     │  …                                  │
--   │ light                  │                                     │
--   │     󰄛  catppuccin-…   │  ↑↓ j/k  navigate                  │
--   │     󰖔  tokyonight-day  │  ⏎  apply · esc  cancel · /  search │
--   └────────────────────────┴─────────────────────────────────────┘
--
-- Changes over v4:
--   • Search bar is full-width and always focused on open
--   • Count badge in search bar shows filtered / total
--   • Preview header shows theme id + dark/light pill + plugin slug
--   • Footer keybind bar is always visible (not overlapping the code)
--   • List column is wider (40 cols) to avoid truncation on most ids
--   • PREVIEW is pre-syntax-highlighted via Treesitter (filetype=lua)
--   • WinBar used for preview header to avoid title truncation
--   • apply_timer uses vim.uv (Neovim ≥0.10) with fallback to vim.loop
-- ─────────────────────────────────────────────────────────────────────────────

local M = {}

-- ── Compat ───────────────────────────────────────────────────────────────────

local uv = vim.uv or vim.loop  -- vim.uv is preferred in Neovim ≥0.10

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function get_hl(name)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return ok and h or {}
end

local function hex(name, attr)
  local v = get_hl(name)[attr]
  return v and ("#%06x"):format(v) or nil
end

-- Visual-width-aware right-pad (nerd-font glyphs are multi-byte)
local function rpad(s, w)
  local vw = vim.fn.strdisplaywidth(s)
  if vw >= w then return s end
  return s .. string.rep(" ", w - vw)
end

local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

-- ── Persistence ───────────────────────────────────────────────────────────────

local function sync_ghostty(ghostty_theme)
  if not ghostty_theme then return end
  local path = vim.fn.expand("~/.config/ghostty/config")
  if vim.fn.filereadable(path) ~= 1 then return end
  local lines = vim.fn.readfile(path)
  local found = false
  for i, l in ipairs(lines) do
    if l:match("^theme%s*=") then
      lines[i] = "theme = " .. ghostty_theme
      found = true; break
    end
  end
  if not found then lines[#lines + 1] = "theme = " .. ghostty_theme end
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
    if pre and q then
      lines[i] = pre .. q .. id .. q .. ","
      break
    end
  end
  vim.fn.writefile(lines, p)
end

local function apply_theme(t)
  if not t then return end
  local ok, s = pcall(require, "settings")
  local transparent = ok and s.transparent == true or false
  if t.setup then t.setup(transparent) end
  pcall(vim.cmd.colorscheme, t.colorscheme or t.id)
end

-- ── Preview code ──────────────────────────────────────────────────────────────

local function preview_lines(theme_id)
  return vim.split(([[
-- active theme: ]] .. theme_id .. [[

local M = {}

---@param name string
function M.greet(name)
  local msg = string.format("Hello, %s!", name)
  return msg
end

local palette = {
  primary = "#89b4fa",
  success = "#a6e3a1",
  warning = "#f9e2af",
  error   = "#f38ba8",
}

local function render(tbl)
  for k, v in pairs(tbl) do
    if type(v) == "string" then
      print(k .. " = " .. v)
    end
  end
end

render(palette)
return M]]), "\n", { plain = true })
end

-- ── Highlight setup ───────────────────────────────────────────────────────────

local NS = vim.api.nvim_create_namespace("ThemePickerV5")

local function setup_hls()
  local bg      = hex("NormalFloat","bg")  or hex("Normal","bg")     or "#1e1e2e"
  local fg      = hex("NormalFloat","fg")  or hex("Normal","fg")     or "#cdd6f4"
  local accent  = hex("Function","fg")     or hex("Statement","fg")  or "#89b4fa"
  local muted   = hex("Comment","fg")      or "#6c7086"
  local sel_bg  = hex("PmenuSel","bg")     or hex("Visual","bg")     or "#313244"
  local sel_fg  = hex("PmenuSel","fg")     or hex("Keyword","fg")    or "#cba6f7"
  local border  = hex("FloatBorder","fg")  or muted
  local surface = hex("CursorLine","bg")   or hex("StatusLine","bg") or bg

  local function s(n, t) vim.api.nvim_set_hl(0, n, t) end
  s("TpNormal",    { bg = bg,      fg = fg })
  s("TpBorder",    { bg = bg,      fg = border })
  s("TpSurface",   { bg = surface, fg = fg })
  s("TpSel",       { bg = sel_bg,  fg = sel_fg,  bold = true })
  s("TpSelIcon",   { bg = sel_bg,  fg = accent })
  s("TpSep",       { bg = bg,      fg = muted,   bold = true })
  s("TpIcon",      { bg = bg,      fg = muted })
  s("TpText",      { bg = bg,      fg = fg })
  s("TpMuted",     { bg = bg,      fg = muted })
  s("TpAccent",    { bg = bg,      fg = accent,  bold = true })
  s("TpPillDark",  { bg = surface, fg = muted })
  s("TpPillLight", { bg = surface, fg = accent })
  s("TpFooter",    { bg = surface, fg = muted })
  s("TpCount",     { bg = bg,      fg = muted })
  s("TpPlugin",    { bg = surface, fg = muted,   italic = true })
  s("TpBarNormal", { bg = surface, fg = fg })
end

-- ── State ─────────────────────────────────────────────────────────────────────

local st = {}

local function reset()
  st.raw         = {}   -- unsorted source list (themes only, no separators)
  st.all         = {}   -- sorted+grouped including separator rows (built once)
  st.filtered    = {}   -- current slice (points into st.all rows, rebuilt on search)
  st.cursor      = 1   -- index into st.filtered
  st.wins        = {}
  st.bufs        = {}
  st.original    = nil
  st.query       = ""
  st.closing     = false
  st.apply_timer = nil
end

-- ── Building the grouped list ─────────────────────────────────────────────────

local function build_grouped(items)
  local dark, light = {}, {}
  for _, t in ipairs(items) do
    table.insert(t.light and light or dark, t)
  end
  table.sort(dark,  function(a, b) return a.id < b.id end)
  table.sort(light, function(a, b) return a.id < b.id end)

  local out = {}
  if #dark > 0 then
    out[#out+1] = { sep = true, label = "DARK" }
    for _, t in ipairs(dark)  do out[#out+1] = t end
  end
  if #light > 0 then
    out[#out+1] = { sep = true, label = "LIGHT" }
    for _, t in ipairs(light) do out[#out+1] = t end
  end
  return out
end

-- ── Forward declarations ──────────────────────────────────────────────────────

local render, render_list, render_preview, render_searchbar
local move, confirm, cancel, update_filter

-- ── Window teardown ───────────────────────────────────────────────────────────

local function close_wins()
  if st.closing then return end
  st.closing = true
  if st.apply_timer then
    pcall(uv.timer_stop, st.apply_timer)
    st.apply_timer = nil
  end
  pcall(vim.api.nvim_del_augroup_by_name, "ThemePickerV5")
  for _, w in pairs(st.wins) do
    if type(w) == "number" and vim.api.nvim_win_is_valid(w) then
      pcall(vim.api.nvim_win_close, w, true)
    end
  end
  st.wins    = {}
  st.bufs    = {}
  st.closing = false
  vim.cmd("stopinsert")
end

cancel = function()
  close_wins()
  if st.original then apply_theme(st.original) end
end

confirm = function()
  local item = st.filtered[st.cursor]
  if not item or item.sep or item.info then return end
  close_wins()
  apply_theme(item)
  sync_ghostty(item.ghostty)
  save_theme(item.id)
  vim.notify(" Theme applied: " .. item.id, vim.log.levels.INFO)
end

-- ── Debounced live preview ────────────────────────────────────────────────────

local DEBOUNCE_MS = 80

local function debounced_apply(item)
  if not item or item.sep or item.info then return end
  if st.apply_timer then pcall(uv.timer_stop, st.apply_timer) end
  st.apply_timer = vim.defer_fn(function()
    st.apply_timer = nil
    if next(st.wins) then apply_theme(item) end
  end, DEBOUNCE_MS)
end

-- ── Dimensions ───────────────────────────────────────────────────────────────

local LIST_W    = 40   -- characters wide for the list column
local PREVIEW_W = 58   -- characters wide for the preview column
local TOTAL_H   = 22   -- total height of the two side-by-side panels
local SEARCH_H  = 1    -- height of search input
local FOOTER_H  = 1    -- height of footer keybind bar

-- ── Rendering ─────────────────────────────────────────────────────────────────

render_searchbar = function()
  local buf = st.bufs.search
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then return end
  -- The search input text is live-editable; only the count badge is static.
  -- We update it via the winbar of the search window.
  local n_all      = #st.raw
  local n_filtered = 0
  for _, it in ipairs(st.filtered) do
    if not it.sep and not it.info then n_filtered = n_filtered + 1 end
  end
  local win = st.wins.search
  if win and vim.api.nvim_win_is_valid(win) then
    local badge = n_filtered == n_all
      and ("%d themes"):format(n_all)
      or  ("%d / %d"):format(n_filtered, n_all)
    -- right-align the badge inside the title
    local pad = LIST_W + PREVIEW_W - 2 - 16 - #badge  -- 16 = " 󰍉  search…  " visual len
    if pad > 0 then badge = string.rep(" ", pad) .. badge end
    pcall(vim.api.nvim_win_set_config, win, {
      title     = " 󰍉  " .. badge,
      title_pos = "right",
    })
  end
end

render_list = function()
  local buf = st.bufs.list
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then return end

  local lines, hi = {}, {}
  local MAX_ID = LIST_W - 7  -- leave room for " ➔ " / "   " + icon + space

  for idx, item in ipairs(st.filtered) do
    local row = #lines

    if item.sep then
      -- e.g.  "  DARK ─────────"
      local label  = "  " .. item.label
      local dashes = string.rep("─", LIST_W - #label - 2)
      lines[#lines+1] = label .. "  " .. dashes
      hi[#hi+1] = { row, 0, -1, "TpSep" }

    elseif item.info then
      lines[#lines+1] = rpad("  " .. item.label, LIST_W)
      hi[#hi+1] = { row, 0, -1, "TpMuted" }

    else
      local icon   = item.icon or "󰏘 "
      local name   = item.id
      if vim.fn.strdisplaywidth(name) > MAX_ID then
        -- trim to visual width
        local w = 0
        local cut = 0
        for i = 1, #name do
          w = w + vim.fn.strdisplaywidth(name:sub(i, i))
          if w > MAX_ID - 1 then cut = i - 1; break end
        end
        name = name:sub(1, cut) .. "…"
      end

      if idx == st.cursor then
        lines[#lines+1] = rpad(" ➔ " .. icon .. " " .. name, LIST_W)
        hi[#hi+1] = { row, 0, -1,  "TpSel" }
        -- re-highlight the icon inside selection
        hi[#hi+1] = { row, 4, 8,   "TpSelIcon" }
      else
        lines[#lines+1] = rpad("   " .. icon .. " " .. name, LIST_W)
        hi[#hi+1] = { row, 3, 7,  "TpIcon" }
        hi[#hi+1] = { row, 7, -1, "TpText" }
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

  local win = st.wins.list
  if win and vim.api.nvim_win_is_valid(win) then
    pcall(vim.api.nvim_win_set_cursor, win, { st.cursor, 0 })
  end
end

render_preview = function()
  local buf = st.bufs.preview
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then return end

  local item = st.filtered[st.cursor]
  local name = (item and not item.sep and not item.info) and item.id or "—"

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, preview_lines(name))
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype   = "lua"

  -- Update preview winbar: theme-id  dark|light pill  plugin
  local win = st.wins.preview
  if win and vim.api.nvim_win_is_valid(win) and item and not item.sep and not item.info then
    local pill = item.light and "light" or "dark"
    pcall(vim.api.nvim_win_set_config, win, {
      title     = "  " .. item.id .. "  [" .. pill .. "]  " .. item.plugin .. "  ",
      title_pos = "center",
    })
  end
end

render_footer = function()
  local buf = st.bufs.footer
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then return end

  local hints = {
    { key = "↑↓ j/k", desc = "navigate" },
    { key = "⏎",      desc = "apply"    },
    { key = "esc",     desc = "cancel"   },
    { key = "/",       desc = "search"   },
  }

  local parts = {}
  for _, h in ipairs(hints) do
    parts[#parts+1] = " " .. h.key .. "  " .. h.desc .. " "
  end
  local line = table.concat(parts, " │ ")
  local full_w = LIST_W + PREVIEW_W + 1  -- +1 for border column between
  line = rpad(line, full_w)

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { line })
  vim.bo[buf].modifiable = false

  -- Highlight key tokens
  vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)
  local col = 0
  for _, h in ipairs(hints) do
    local klen = #h.key
    vim.api.nvim_buf_add_highlight(buf, NS, "TpAccent",  0, col + 1, col + 1 + klen)
    vim.api.nvim_buf_add_highlight(buf, NS, "TpFooter",  0, col + 1 + klen, col + 1 + klen + 2 + #h.desc + 1)
    col = col + 1 + klen + 2 + #h.desc + 4 -- " │ " = 3 + leading space
  end
end

render = function()
  render_list()
  render_preview()
  render_searchbar()
end

-- ── Filtering ─────────────────────────────────────────────────────────────────

update_filter = function(query)
  st.query = trim(query)

  if st.query == "" then
    st.filtered = st.all
  else
    local q    = st.query:lower()
    local dark_out, light_out = {}, {}
    for _, item in ipairs(st.raw) do
      if item.id:lower():find(q, 1, true) then
        table.insert(item.light and light_out or dark_out, item)
      end
    end
    local out = {}
    if #dark_out  > 0 then out[#out+1] = { sep=true, label="DARK"  }; for _, t in ipairs(dark_out)  do out[#out+1] = t end end
    if #light_out > 0 then out[#out+1] = { sep=true, label="LIGHT" }; for _, t in ipairs(light_out) do out[#out+1] = t end end
    if #out == 0 then out[#out+1] = { info=true, label="no matching themes" } end
    st.filtered = out
  end

  -- Clamp cursor to a real item
  local function find_first_real()
    for i, it in ipairs(st.filtered) do
      if not it.sep and not it.info then return i end
    end
    return 1
  end

  local cur = st.filtered[st.cursor]
  if not cur or cur.sep or cur.info then
    st.cursor = find_first_real()
  end

  render()

  local item = st.filtered[st.cursor]
  if item and not item.sep and not item.info then
    debounced_apply(item)
  end
end

-- ── Navigation ───────────────────────────────────────────────────────────────

move = function(dir)
  local n = #st.filtered
  if n == 0 then return end
  local curr = st.cursor
  for _ = 1, n do
    curr = curr + dir
    if curr > n then curr = 1  end
    if curr < 1 then curr = n  end
    local item = st.filtered[curr]
    if item and not item.sep and not item.info then
      st.cursor = curr
      render()
      debounced_apply(item)
      return
    end
  end
end

-- ── Keymaps ───────────────────────────────────────────────────────────────────

local function bind(buf)
  local o = { buffer=buf, nowait=true, silent=true, noremap=true }
  local dn = function() move(1)  end
  local up = function() move(-1) end
  for _, mode in ipairs({ "i", "n" }) do
    vim.keymap.set(mode, "<CR>",   confirm, o)
    vim.keymap.set(mode, "<Esc>",  cancel,  o)
    vim.keymap.set(mode, "<C-c>",  cancel,  o)
    vim.keymap.set(mode, "<Down>", dn,      o)
    vim.keymap.set(mode, "<Up>",   up,      o)
  end
  vim.keymap.set("i", "<C-j>", dn,     o)
  vim.keymap.set("i", "<C-k>", up,     o)
  vim.keymap.set("n", "j",     dn,     o)
  vim.keymap.set("n", "k",     up,     o)
  vim.keymap.set("n", "q",     cancel, o)
end

-- ── Open ──────────────────────────────────────────────────────────────────────

function M.open()
  if next(st.wins or {}) then return end
  reset()
  setup_hls()

  -- Collect themes
  local registry = require("core.theme_registry")
  for _, t in ipairs(registry) do
    if t.ghostty and t.ghostty ~= "" then
      st.raw[#st.raw+1] = t
    end
  end
  st.all      = build_grouped(st.raw)
  st.filtered = st.all

  -- Detect current theme
  local cur = vim.g.colors_name or ""
  for _, t in ipairs(st.raw) do
    if t.id == cur or (t.colorscheme and t.colorscheme == cur) then
      st.original = t; break
    end
  end

  -- ── Geometry ──────────────────────────────────────────────────────────────
  local FULL_W  = LIST_W + PREVIEW_W + 3  -- 3 = two borders + gap col
  local ui      = vim.api.nvim_list_uis()[1] or { width=200, height=55 }
  local base_row = math.floor((ui.height - (SEARCH_H + 2 + TOTAL_H + 2 + FOOTER_H + 2)) / 2)
  local base_col = math.floor((ui.width  - FULL_W) / 2)

  -- ── Buffers ───────────────────────────────────────────────────────────────
  local function mkbuf(ro)
    local b = vim.api.nvim_create_buf(false, true)
    vim.bo[b].bufhidden  = "wipe"
    vim.bo[b].modifiable = not ro
    return b
  end
  st.bufs.search  = mkbuf(false)   -- editable search input
  st.bufs.list    = mkbuf(true)
  st.bufs.preview = mkbuf(true)
  st.bufs.footer  = mkbuf(true)

  local whl = "Normal:TpNormal,FloatBorder:TpBorder,NormalFloat:TpNormal"
  local whl_surface = "Normal:TpSurface,FloatBorder:TpBorder,NormalFloat:TpSurface"

  local function set_wo(w, surface)
    local o = vim.wo[w]
    o.number         = false
    o.relativenumber = false
    o.signcolumn     = "no"
    o.statuscolumn   = ""
    o.cursorline     = false
    o.wrap           = false
    o.winhighlight   = surface and whl_surface or whl
  end

  -- ── Search window (full width, top) ───────────────────────────────────────
  st.wins.search = vim.api.nvim_open_win(st.bufs.search, true, {
    relative  = "editor", style = "minimal", border = "rounded",
    row       = base_row, col = base_col,
    width     = LIST_W + PREVIEW_W + 1,
    height    = SEARCH_H,
    title     = " 󰍉 ", title_pos = "left",
    zindex    = 52,
  })
  set_wo(st.wins.search)

  -- ── List window (left, below search) ──────────────────────────────────────
  st.wins.list = vim.api.nvim_open_win(st.bufs.list, false, {
    relative = "editor", style = "minimal", border = "rounded",
    row      = base_row + SEARCH_H + 2,
    col      = base_col,
    width    = LIST_W,
    height   = TOTAL_H,
    zindex   = 51,
  })
  set_wo(st.wins.list)

  -- ── Preview window (right, beside list) ───────────────────────────────────
  st.wins.preview = vim.api.nvim_open_win(st.bufs.preview, false, {
    relative  = "editor", style = "minimal", border = "rounded",
    row       = base_row + SEARCH_H + 2,
    col       = base_col + LIST_W + 2,
    width     = PREVIEW_W,
    height    = TOTAL_H,
    title     = "  Preview  ", title_pos = "center",
    zindex    = 51,
  })
  set_wo(st.wins.preview)

  -- ── Footer window (full width, below panels) ──────────────────────────────
  st.wins.footer = vim.api.nvim_open_win(st.bufs.footer, false, {
    relative = "editor", style = "minimal", border = "rounded",
    row      = base_row + SEARCH_H + 2 + TOTAL_H + 2,
    col      = base_col,
    width    = LIST_W + PREVIEW_W + 1,
    height   = FOOTER_H,
    zindex   = 51,
  })
  set_wo(st.wins.footer, true)

  -- Seed search buffer with empty line
  vim.api.nvim_buf_set_lines(st.bufs.search, 0, -1, false, { "" })

  bind(st.bufs.search)

  -- ── Autocmds ──────────────────────────────────────────────────────────────
  local ag = vim.api.nvim_create_augroup("ThemePickerV5", { clear = true })

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = ag, buffer = st.bufs.search,
    callback = function()
      local q = vim.api.nvim_buf_get_lines(st.bufs.search, 0, -1, false)[1] or ""
      update_filter(q)
    end,
  })

  vim.api.nvim_create_autocmd("WinLeave", {
    group = ag,
    callback = function()
      if st.closing then return end
      vim.schedule(function()
        if st.closing then return end
        local cw = vim.api.nvim_get_current_win()
        local in_picker = cw == st.wins.search
                       or cw == st.wins.list
                       or cw == st.wins.preview
                       or cw == st.wins.footer
        if not in_picker and next(st.wins) then cancel() end
      end)
    end,
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = ag, callback = setup_hls,
  })

  -- ── Initial position & render ─────────────────────────────────────────────
  if st.original then
    for i, t in ipairs(st.filtered) do
      if not t.sep and not t.info and t.id == st.original.id then
        st.cursor = i; break
      end
    end
  end

  render()
  render_footer()
  vim.cmd("startinsert!")
end

return M