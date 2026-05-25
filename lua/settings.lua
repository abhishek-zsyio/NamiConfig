-- ==============================================================================
-- 🚀  User Configuration Settings
-- ==============================================================================

---@alias Theme "catppuccin" | "onedark" | "tokyonight" | "gruvbox" | "rose-pine" | "nord" | "dracula" | "kanagawa" | "nightfox" | "cyberdream" | "sonokai" | "material" | "oxocarbon" | "monokai"

---@alias Extra
---| "plugins.extras.lang.go"
---| "plugins.extras.lang.rust"
---| "plugins.extras.lang.sql"
---| "plugins.extras.testing.neotest"

return {
  -- ── UI & Aesthetics ────────────────────────────────────────────────────────
  ---@type Theme
  theme = "catppuccin-mocha",
  background = "dark",
  transparent = false,
  hide_empty_tabline = true,
  show_indent_guides = true,
  smooth_scroll = true,
  dim_inactive = false,
  line_height = 2,           -- Additional spacing between lines (GUI only, e.g., Neovide)
  cmdheight = 0,             -- 0 for modern hidden cmdline, 1 for classic
  neovide_transparency = 0.9,-- Transparency level for Neovide (0.0 to 1.0)

  -- ── Menus & Pickers (UI) ───────────────────────────────────────────────────
  picker_layout = "dropdown", -- Options: "telescope", "ivy", "dropdown", "default", "vertical", "horizontal", "vscode"
  picker_width = 0.85,
  picker_height = 0.8,
  menu_border = "none",     -- Options: "rounded", "single", "double", "solid", "shadow", "none"

  -- ── Editor Behavior ────────────────────────────────────────────────────────
  highlight_current_line = true,
  show_line_numbers = true,
  relative_line_numbers = true,
  format_on_save = true,
  tab_size = 2,
  mouse_support = true,
  wrap_lines = true,
  scrolloff = 8,
  auto_save = false,
  blink_cursor = true,
  color_column = "80",
  split_below = true,
  split_right = true,
  ignore_case_search = true,

  -- ── Code Intelligence (LSP) ────────────────────────────────────────────────
  enable_inlay_hints = true,
  show_inline_errors = true,

  -- ── File Explorer ──────────────────────────────────────────────────────────
  show_hidden_files = true,
  file_explorer_position = "left",

  -- ── Linting ────────────────────────────────────────────────────────────────
  enable_linting = true,

  -- ── Project-Local Config ───────────────────────────────────────────────────
  enable_project_config = true,

  -- ── Extras (Opt-in Modules) ────────────────────────────────────────────────
  ---@type Extra[]
  extras = {
    "plugins.extras.lang.go",
    "plugins.extras.lang.rust",
    "plugins.extras.lang.sql",
    "plugins.extras.testing.neotest",
  },

  -- ── Custom Tools ───────────────────────────────────────────────────────────
  lsp_servers = {
    "clangd",
    "tailwindcss",
  },

  mason_tools = {
    "prettier",
    "stylua",
  },
}
