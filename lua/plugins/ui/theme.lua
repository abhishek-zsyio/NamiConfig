-- plugins/ui/theme.lua
-- Dynamically loads ALL theme plugins from the central registry.
-- Only the active theme is loaded eagerly (priority = 1000); others are lazy.

local registry = require("core.theme_registry")
local plugins = {}

-- ── 1. Load theme plugins ───────────────────────────────────────────────────
local unique_plugins = {}
local ok, settings = pcall(require, "settings")
local current = ok and settings.theme or "catppuccin-mocha"

for _, theme in ipairs(registry) do
  local repo = theme.plugin
  if not unique_plugins[repo] then
    unique_plugins[repo] = { is_active = false }
  end
  if current == theme.id then
    unique_plugins[repo].is_active = true
  end
end

for repo, data in pairs(unique_plugins) do
  table.insert(plugins, {
    repo,
    lazy     = not data.is_active,
    priority = 1000,
    config = function()
      local ok2, s2 = pcall(require, "settings")
      local current_theme = ok2 and s2.theme or "catppuccin-mocha"
      local transparent   = ok2 and s2.transparent == true

      local target_theme = nil
      for _, t in ipairs(require("core.theme_registry")) do
        if t.id == current_theme then
          target_theme = t
          break
        end
      end

      if target_theme and target_theme.plugin == repo then
        if target_theme.setup then
          target_theme.setup(transparent)
        end
        vim.cmd.colorscheme(target_theme.colorscheme or target_theme.id)
      end
    end,
  })
end

-- ── 2. Universal highlight overrides (run after any colorscheme loads) ──────
-- These fill gaps not covered by individual theme integrations.
table.insert(plugins, {
  "theme-overrides",
  name    = "theme-overrides",
  virtual = true,
  lazy    = false,
  priority = 1001,
  config = function()
    local function apply_overrides()
      local ok2, s2 = pcall(require, "settings")

      -- Transparency pass (only if transparent = true)
      if ok2 and s2.transparent == true then
        local transparent_groups = {
          "Normal", "NormalNC", "SignColumn", "LineNr", "NonText",
          "EndOfBuffer", "CursorLineNr",
        }
        for _, name in ipairs(transparent_groups) do
          pcall(vim.cmd, ("hi %s ctermbg=NONE guibg=NONE"):format(name))
        end
      end

      -- Helpers
      local function get_hl(name)
        local ok_hl, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        return ok_hl and hl or {}
      end
      local set_hl = vim.api.nvim_set_hl

      local bg      = get_hl("Normal").bg
      local fg      = get_hl("Normal").fg
      local alt_bg  = get_hl("CursorLine").bg or get_hl("StatusLine").bg or bg
      local accent  = get_hl("Function").fg or get_hl("Statement").fg or fg
      local comment = get_hl("Comment").fg

      if not (bg and fg) then return end

      -- Line numbers
      if comment then
        set_hl(0, "LineNr", { fg = comment, italic = true })
      end
      set_hl(0, "CursorLineNr", { fg = accent, bold = true })

      -- Diagnostics virtual text — italic, no background
      for _, kind in ipairs({ "Error", "Warn", "Info", "Hint" }) do
        local diag_fg = get_hl("Diagnostic" .. kind).fg
        if diag_fg then
          set_hl(0, "Diagnostic" .. kind .. "VirtualText",
            { fg = diag_fg, bg = "NONE", italic = true })
        end
      end

      -- Autocomplete menu
      local cmp_bg   = alt_bg or bg
      local label_bg = bg
      set_hl(0, "Pmenu",       { bg = cmp_bg, fg = fg })
      set_hl(0, "PmenuSel",    { bg = accent, fg = label_bg, bold = true })
      set_hl(0, "PmenuSbar",   { bg = cmp_bg })
      set_hl(0, "PmenuThumb",  { bg = accent })

      -- CMP item kind colors (dynamic, using theme tokens)
      local kind_colors = {
        Function      = get_hl("Function").fg,
        Method        = get_hl("Function").fg,
        Variable      = get_hl("Identifier").fg,
        Constant      = get_hl("Constant").fg,
        Keyword       = get_hl("Keyword").fg,
        Snippet       = get_hl("Special").fg,
        Class         = get_hl("Type").fg,
        Interface     = get_hl("Type").fg,
        Module        = get_hl("PreProc").fg,
        Property      = get_hl("Identifier").fg,
        Field         = get_hl("Identifier").fg,
        Enum          = get_hl("Type").fg,
        EnumMember    = get_hl("Constant").fg,
        Struct        = get_hl("Type").fg,
        Event         = get_hl("Special").fg,
        Operator      = get_hl("Operator").fg,
        TypeParameter = get_hl("Type").fg,
      }
      for kind, color in pairs(kind_colors) do
        if color then
          set_hl(0, "CmpItemKind" .. kind, { fg = color })
        end
      end

      -- CMP match highlights
      if accent then
        set_hl(0, "CmpItemAbbrMatch",      { fg = accent, bold = true })
        set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = accent, bold = true })
      end
      if comment then
        set_hl(0, "CmpItemAbbrDeprecated", { fg = comment, strikethrough = true })
        set_hl(0, "CmpItemMenu",           { fg = comment, italic = true })
        -- Indent guides fallback (catppuccin sets these, but other themes need it)
        set_hl(0, "SnacksIndent",      { fg = comment })
      end
      if accent then
        set_hl(0, "SnacksIndentScope", { fg = accent })
        set_hl(0, "SnacksIndentChunk", { fg = accent })
      end

      -- Window separator — use FloatBorder fg color
      local border_fg = get_hl("FloatBorder").fg or comment
      if border_fg then
        set_hl(0, "WinSeparator", { fg = border_fg, bg = "NONE" })
      end
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern  = "*",
      callback = apply_overrides,
    })
    -- Also apply immediately (the first colorscheme may already be loaded)
    apply_overrides()
  end,
})

return plugins
