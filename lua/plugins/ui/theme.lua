local registry = require("nami.themes.registry")
local plugins = {}

-- 1. Dynamically load all themes from the registry
local unique_plugins = {}
local ok, settings = pcall(require, "settings")
local current = ok and settings.theme or "catppuccin"
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
    lazy = not data.is_active,
    priority = 1000,
    config = function()
      local ok2, s2 = pcall(require, "settings")
      local current_theme = s2 and s2.theme or "catppuccin"
      local transparent = (ok2 and s2.transparent == true)
      
      -- Find the active theme object for this repository
      local target_theme = nil
      for _, t in ipairs(require("nami.themes.registry")) do
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

-- 2. Inject the Universal Theme Overrides (applies after whichever theme loads)
table.insert(plugins, {
    "theme-overrides",
    name = "theme-overrides",
    -- virtual = true is sufficient; no dir needed
    virtual = true,
    lazy = false,
    priority = 1001, -- run after themes
    config = function()
      local ok, settings = pcall(require, "settings")
      
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          -- 1. Apply transparency to main editor if requested
          if ok and settings.transparent == true then
            local hl_groups = {
              "Normal", "NormalNC", "Comment", "Constant", "Special", "Identifier",
              "Statement", "PreProc", "Type", "Underlined", "Todo", "String", "Function",
              "Conditional", "Repeat", "Operator", "Structure", "LineNr", "NonText",
              "SignColumn", "CursorLineNr", "EndOfBuffer", 
            }
            for _, name in ipairs(hl_groups) do
              vim.cmd(string.format("hi %s ctermbg=NONE guibg=NONE", name))
            end
          end

          -- 2. Ensure popups and borders perfectly match the editor background
          -- by removing any special dark backgrounds they might have by default
          local popup_groups = { "FloatBorder", "Pmenu", "NormalFloat" }
          for _, name in ipairs(popup_groups) do
            vim.cmd(string.format("hi %s guibg=NONE ctermbg=NONE", name))
          end

          -- 3. Universal Highlight Adjustments
          local function get_hl(name)
            local ok_hl, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            return ok_hl and hl or {}
          end
          local bg = get_hl("Normal").bg
          local fg = get_hl("Normal").fg
          local alt_bg = get_hl("CursorLine").bg or get_hl("StatusLine").bg or bg
          local accent = get_hl("Statement").fg or get_hl("Function").fg or fg

          if bg and fg and alt_bg then
            local set_hl = vim.api.nvim_set_hl

            -- Make line numbers subtle but the active line number pop out
            set_hl(0, "LineNr", { fg = get_hl("Comment").fg or "#5c6370", italic = true })
            set_hl(0, "CursorLineNr", { fg = accent, bold = true })
            
            -- Blend virtual text diagnostics elegantly into the background
            local function make_diag_bg(diag_name)
              local diag_fg = get_hl(diag_name).fg
              if diag_fg then
                set_hl(0, diag_name .. "VirtualText", { fg = diag_fg, bg = "NONE", italic = true })
              end
            end
            make_diag_bg("DiagnosticError")
            make_diag_bg("DiagnosticWarn")
            make_diag_bg("DiagnosticInfo")
            make_diag_bg("DiagnosticHint")
            
            -- Sleek Pmenu & Borderless nvim-cmp overrides
            local function cmp_hl(name, val)
              set_hl(0, name, val)
            end
            
            local cmp_bg = alt_bg
            local fallback_fg = bg or "#1e1e2e"
            
            cmp_hl("CmpPmenu", { bg = cmp_bg })
            cmp_hl("CmpPmenuBorder", { bg = cmp_bg, fg = cmp_bg })
            cmp_hl("CmpPmenuSel", { bg = accent, fg = fallback_fg, bold = true })
            
            cmp_hl("CmpItemAbbr", { fg = fg })
            cmp_hl("CmpItemAbbrDeprecated", { fg = get_hl("Comment").fg or "#5c6370", strikethrough = true })
            cmp_hl("CmpItemAbbrMatch", { fg = accent, bold = true })
            cmp_hl("CmpItemAbbrMatchFuzzy", { fg = accent, bold = true })
            cmp_hl("CmpItemMenu", { fg = get_hl("Comment").fg or "#5c6370", italic = true })
            
            -- Color-code autocomplete item kinds dynamically
            local colors_map = {
              Function = get_hl("Function").fg or "#89b4fa",
              Method = get_hl("Function").fg or "#89b4fa",
              Variable = get_hl("Identifier").fg or "#cdd6f4",
              Constant = get_hl("Constant").fg or "#f9e2af",
              Keyword = get_hl("Keyword").fg or "#cba6f7",
              Snippet = get_hl("Special").fg or "#f5c2e7",
              Class = get_hl("Type").fg or "#f9e2af",
              Interface = get_hl("Type").fg or "#f9e2af",
              Module = get_hl("PreProc").fg or "#a6e3a1",
              Property = get_hl("Identifier").fg or "#f38ba8",
              Field = get_hl("Identifier").fg or "#f38ba8",
              Enum = get_hl("Type").fg or "#f9e2af",
              EnumMember = get_hl("Constant").fg or "#f9e2af",
              Struct = get_hl("Type").fg or "#f9e2af",
              Event = get_hl("Special").fg or "#f5c2e7",
              Operator = get_hl("Operator").fg or "#89dceb",
              TypeParameter = get_hl("Type").fg or "#89dceb",
            }
            
            for kind, k_color in pairs(colors_map) do
              cmp_hl("CmpItemKind" .. kind, { fg = k_color })
            end

            set_hl(0, "Pmenu", { bg = alt_bg, fg = fg })
            set_hl(0, "PmenuSel", { bg = accent, fg = fallback_fg, bold = true })

            -- Subtle split separators that don't compete with content
            local border_fg = get_hl("FloatBorder").fg or get_hl("Comment").fg
            if border_fg then
              set_hl(0, "WinSeparator", { fg = border_fg, bg = "NONE" })
            end

            -- Softer MatchParen: underline + bold instead of jarring background
            set_hl(0, "MatchParen", { underline = true, bold = true, sp = accent })

            -- Indent guides: active scope uses the accent color so it glows
            local comment_fg = get_hl("Comment").fg
            local fn_fg = get_hl("Function").fg
            if comment_fg then
              set_hl(0, "SnacksIndent",       { fg = comment_fg })
            end
            if fn_fg then
              set_hl(0, "SnacksIndentScope",  { fg = fn_fg })
              set_hl(0, "SnacksIndentChunk",  { fg = fn_fg })
            end
          end
        end,
      })
    end,
})

return plugins
