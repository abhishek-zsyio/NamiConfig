local registry = require("core.theme_registry")
local plugins = {}

-- 1. Dynamically load all themes from the registry
for _, theme in ipairs(registry) do
  table.insert(plugins, {
    theme.plugin,
    name = theme.plugin:match("([^/]+)$"):gsub("%.nvim$", ""),
    lazy = false,
    priority = 1000,
    config = function()
      local ok, settings = pcall(require, "settings")
      if not ok then settings = {} end
      local transparent = settings.background == "transparent"
      
      -- Run the theme's specific setup logic if it has any
      if theme.setup then
        theme.setup(transparent)
      end
      
      -- Apply it if it's the globally selected theme
      if (settings.theme or "catppuccin") == theme.id then
        vim.cmd.colorscheme(theme.id)
      end
    end,
  })
end

-- 2. Inject the Universal Theme Overrides (applies after whichever theme loads)
table.insert(plugins, {
    "theme-overrides",
    name = "theme-overrides",
    dir = "", -- dummy plugin
    virtual = true,
    lazy = false,
    priority = 1001, -- run after themes
    config = function()
      local ok, settings = pcall(require, "settings")
      
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          -- 1. Apply transparency to main editor if requested
          if ok and settings.background == "transparent" then
            local hl_groups = {
              "Normal", "NormalNC", "Comment", "Constant", "Special", "Identifier",
              "Statement", "PreProc", "Type", "Underlined", "Todo", "String", "Function",
              "Conditional", "Repeat", "Operator", "Structure", "LineNr", "NonText",
              "SignColumn", "CursorLineNr", "EndOfBuffer", 
              "NvimTreeNormal", "NvimTreeNormalNC",
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

          -- 3. Universal Telescope Theme (NvChad borderless style)
          local function get_hl(name)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
            return ok and hl or {}
          end
          local bg = get_hl("Normal").bg
          local fg = get_hl("Normal").fg
          local alt_bg = get_hl("CursorLine").bg or get_hl("StatusLine").bg or bg
          local accent = get_hl("Statement").fg or get_hl("Function").fg or fg

          if bg and fg and alt_bg then
            local set_hl = vim.api.nvim_set_hl
            
            -- Telescope NvChad Borderless
            set_hl(0, "TelescopeNormal", { bg = bg, fg = fg })
            set_hl(0, "TelescopeBorder", { bg = bg, fg = bg })
            set_hl(0, "TelescopePromptNormal", { bg = alt_bg, fg = fg })
            set_hl(0, "TelescopePromptBorder", { bg = alt_bg, fg = alt_bg })
            set_hl(0, "TelescopePromptTitle", { bg = accent, fg = bg, bold = true })
            set_hl(0, "TelescopePromptPrefix", { bg = alt_bg, fg = accent })
            set_hl(0, "TelescopeResultsNormal", { bg = bg, fg = fg })
            set_hl(0, "TelescopeResultsBorder", { bg = bg, fg = bg })
            set_hl(0, "TelescopeResultsTitle", { bg = bg, fg = bg })
            set_hl(0, "TelescopePreviewNormal", { bg = alt_bg, fg = fg })
            set_hl(0, "TelescopePreviewBorder", { bg = alt_bg, fg = alt_bg })
            set_hl(0, "TelescopePreviewTitle", { bg = alt_bg, fg = alt_bg })

            -- Premium Global Highlight Adjustments
            -- Make line numbers subtle but the active line number pop out
            set_hl(0, "LineNr", { fg = get_hl("Comment").fg or "#5c6370", italic = true })
            set_hl(0, "CursorLineNr", { fg = accent, bold = true })
            
            -- Blend virtual text diagnostics elegantly into the background
            local function make_diag_bg(diag_name)
              local diag_fg = get_hl(diag_name).fg
              if diag_fg then
                -- In Neovim 0.9+, blend colors using nvim_set_hl, 
                -- or just fallback to the original fg with no bg for transparency
                set_hl(0, diag_name .. "VirtualText", { fg = diag_fg, bg = "NONE", italic = true })
              end
            end
            make_diag_bg("DiagnosticError")
            make_diag_bg("DiagnosticWarn")
            make_diag_bg("DiagnosticInfo")
            make_diag_bg("DiagnosticHint")
            
            -- Sleek Pmenu (Autocomplete)
            set_hl(0, "Pmenu", { bg = alt_bg, fg = fg })
            set_hl(0, "PmenuSel", { bg = accent, fg = bg, bold = true })
          end
        end,
      })
    end,
})

return plugins
