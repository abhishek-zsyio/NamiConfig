-- plugins/ui/theme.lua
-- Dynamically loads ALL theme plugins from the central registry.
-- Only the active theme's plugin is loaded eagerly (priority = 1000).
-- Every other plugin repo is deferred (lazy = true, no priority).

local registry = require("core.theme_registry")
local plugins  = {}

-- ── 1. Resolve active theme id ───────────────────────────────────────────────

local function current_theme_id()
  local ok, s = pcall(require, "settings")
  return ok and s.theme or "catppuccin-mocha"
end

local current = current_theme_id()

-- ── 2. Deduplicate repos and track which one is active ───────────────────────

local repo_active = {} -- repo → bool

for _, theme in ipairs(registry) do
  local repo = theme.plugin
  -- Mark repo active if any of its theme ids matches the saved setting
  if repo_active[repo] == nil then
    repo_active[repo] = false
  end
  if theme.id == current then
    repo_active[repo] = true
  end
end

-- ── 3. Emit one lazy spec per unique repo ────────────────────────────────────

for repo, is_active in pairs(repo_active) do
  local spec = {
    repo,
    lazy = not is_active,
  }

  -- Only the active plugin needs a priority boost so it runs before the
  -- override shim (priority 1001) that fires afterwards.
  if is_active then
    spec.priority = 1000
  end

  spec.config = function()
    -- Re-read settings at config time (supports live theme switching)
    local ok, s     = pcall(require, "settings")
    local theme_id  = ok and s.theme  or "catppuccin-mocha"
    local t         = ok and s.transparent == true or false

    -- Find the matching entry for this repo
    for _, entry in ipairs(require("core.theme_registry")) do
      if entry.id == theme_id and entry.plugin == repo then
        if entry.setup then entry.setup(t) end
        pcall(vim.cmd.colorscheme, entry.colorscheme or entry.id)
        return
      end
    end
  end

  table.insert(plugins, spec)
end

-- ── 4. Universal highlight overrides ─────────────────────────────────────────
-- Runs after every ColorScheme change, plugging gaps individual themes miss.
-- Priority 1001 ensures this shim is evaluated *after* the theme plugin (1000).

table.insert(plugins, {
  "theme-overrides",
  name     = "theme-overrides",
  virtual  = true,
  lazy     = false,
  priority = 1001,
  config   = function()
    local function apply_overrides()
      local ok, s = pcall(require, "settings")
      local transparent = ok and s.transparent == true

      -- ── Transparency pass ──────────────────────────────────────────────────
      if transparent then
        local clear = { "Normal","NormalNC","SignColumn","LineNr","NonText","EndOfBuffer","CursorLineNr" }
        for _, name in ipairs(clear) do
          pcall(vim.cmd, ("hi %s ctermbg=NONE guibg=NONE"):format(name))
        end
      end

      -- ── Token helpers ──────────────────────────────────────────────────────
      local function get_hl(name)
        local ok2, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        return ok2 and hl or {}
      end
      local set = vim.api.nvim_set_hl

      local bg      = get_hl("Normal").bg
      local fg      = get_hl("Normal").fg
      local alt_bg  = get_hl("CursorLine").bg or get_hl("StatusLine").bg or bg
      local accent  = get_hl("Function").fg   or get_hl("Statement").fg  or fg
      local comment = get_hl("Comment").fg

      -- Can't do anything meaningful without base colours
      if not (bg and fg) then return end

      -- ── Line numbers ───────────────────────────────────────────────────────
      if comment then set(0, "LineNr",      { fg = comment, italic = true }) end
      set(0, "CursorLineNr", { fg = accent,  bold   = true })

      -- ── Diagnostic virtual text ────────────────────────────────────────────
      for _, kind in ipairs({ "Error", "Warn", "Info", "Hint" }) do
        local diag_fg = get_hl("Diagnostic" .. kind).fg
        if diag_fg then
          set(0, "Diagnostic" .. kind .. "VirtualText", { fg = diag_fg, bg = "NONE", italic = true })
        end
      end

      -- ── Autocomplete menu ──────────────────────────────────────────────────
      local cmp_bg = alt_bg or bg
      set(0, "Pmenu",      { bg = cmp_bg, fg = fg })
      set(0, "PmenuSel",   { bg = accent, fg = bg,     bold = true })
      set(0, "PmenuSbar",  { bg = cmp_bg })
      set(0, "PmenuThumb", { bg = accent })

      -- ── CMP item kind colours ──────────────────────────────────────────────
      local kinds = {
        Function="Function", Method="Function",
        Variable="Identifier", Property="Identifier", Field="Identifier",
        Constant="Constant", EnumMember="Constant",
        Keyword="Keyword",
        Snippet="Special", Event="Special",
        Class="Type", Interface="Type", Struct="Type", Enum="Type", TypeParameter="Type",
        Module="PreProc",
        Operator="Operator",
      }
      for kind, src in pairs(kinds) do
        local c = get_hl(src).fg
        if c then set(0, "CmpItemKind" .. kind, { fg = c }) end
      end

      -- ── CMP match & menu ───────────────────────────────────────────────────
      if accent then
        set(0, "CmpItemAbbrMatch",      { fg = accent, bold = true })
        set(0, "CmpItemAbbrMatchFuzzy", { fg = accent, bold = true })
      end
      if comment then
        set(0, "CmpItemAbbrDeprecated", { fg = comment, strikethrough = true })
        set(0, "CmpItemMenu",           { fg = comment, italic = true })
        set(0, "SnacksIndent",          { fg = comment })
      end
      if accent then
        set(0, "SnacksIndentScope", { fg = accent })
        set(0, "SnacksIndentChunk", { fg = accent })
      end

      -- ── Window separator ───────────────────────────────────────────────────
      -- Flat design: perfectly blend the vertical split with a subtle solid color
      set(0, "WinSeparator", { fg = alt_bg, bg = bg })
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern  = "*",
      callback = apply_overrides,
    })
    apply_overrides() -- also apply to whatever is already loaded
  end,
})

return plugins