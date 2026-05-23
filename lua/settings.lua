-- ==============================================================================
-- 🚀  User Configuration Settings
-- ==============================================================================
-- Feel free to edit these values to customize your Neovim experience without
-- ever having to touch the complex Lua plugin files!

---@alias Theme "catppuccin" | "onedark" | "tokyonight" | "gruvbox" | "rose-pine" | "nord" | "dracula" | "kanagawa" | "nightfox" | "cyberdream" | "sonokai" | "material" | "oxocarbon" | "monokai"

---@alias Extra
---| "plugins.extras.lang.go"         Go language support (LSP + DAP)
---| "plugins.extras.lang.rust"        Rust language support (rust-analyzer)
---| "plugins.extras.lang.sql"         SQL language support + DB explorer
---| "plugins.extras.testing.neotest"  Unified test runner (pytest, jest, vitest)

return {
  -- ── UI & Aesthetics ────────────────────────────────────────────────────────
  
  -- The core colorscheme. (Default: "catppuccin")
  ---@type Theme
  theme = "gruvbox",
  
  -- Background mode for the editor: "transparent" or "solid"
  background = "solid",
  
  -- Hide the tab bar at the top if there's only 1 file open
  hide_empty_tabline = true,

  -- Toggle the vertical lines that show indentation levels
  show_indent_guides = true,

  -- Enable smooth scrolling animations
  smooth_scroll = true,

  -- Dim panes that you aren't currently focused on
  dim_inactive = false,

  -- ── Editor Behavior ────────────────────────────────────────────────────────

  -- Highlight the line your cursor is currently on
  highlight_current_line = true,

  -- Show line numbers on the left
  show_line_numbers = true,
  
  -- Use relative line numbers (useful for jumping lines e.g., 5j, 4k)
  relative_line_numbers = false,
  
  -- Automatically format code when you save the file
  format_on_save = true,

  -- Spaces per tab indentation
  tab_size = 2,

  -- Enable mouse support in the editor
  mouse_support = true,

  -- Toggle line wrapping for long lines of code
  wrap_lines = true,

  -- Keep a certain number of lines visible above and below your cursor when scrolling
  scrolloff = 8,

  -- Automatically save the file when you lose focus or after a delay
  auto_save = false,

  -- Choose whether the cursor should blink in normal/insert modes
  blink_cursor = true,

  -- Draw a vertical line at a specific column (e.g. "80", or "" to disable)
  color_column = "80",

  -- Open new horizontal splits below the current window
  split_below = true,

  -- Open new vertical splits to the right of the current window
  split_right = true,

  -- Search is case-insensitive by default (unless you use a capital letter)
  ignore_case_search = true,

  -- ── Code Intelligence (LSP) ────────────────────────────────────────────────

  -- Show inline variable types and parameter names
  enable_inlay_hints = true,

  -- Show errors and warnings directly at the end of the line
  show_inline_errors = true,

  -- ── File Explorer ──────────────────────────────────────────────────────────

  -- Show hidden files like .env or .gitignore in your file tree
  show_hidden_files = true,

  -- ── Linting ────────────────────────────────────────────────────────────────

  -- Enable asynchronous linting (shellcheck, ruff, eslint_d, etc.)
  -- Linters are defined per-language in lua/core/lang_registry.lua
  enable_linting = true,

  -- ── Project-Local Config ───────────────────────────────────────────────────

  -- Allow per-project overrides via .neoconf.json in the project root.
  -- Example: disable a linter or change typeCheckingMode for one project.
  enable_project_config = true,

  -- ── Extras (Opt-in Modules) ────────────────────────────────────────────────

  -- Uncomment any extras to enable them. Each extra installs its own
  -- plugins, LSPs, debuggers, and test adapters automatically.
  ---@type Extra[]
  extras = {
    -- "plugins.extras.lang.go",
    -- "plugins.extras.lang.rust",
    -- "plugins.extras.lang.sql",
    -- "plugins.extras.testing.neotest",
  },

  -- ── Custom Tools (NvChad Style) ────────────────────────────────────────────
  -- List any extra LSP servers you want automatically installed and configured.
  lsp_servers = {
    -- "clangd",
    -- "tailwindcss",
  },

  -- List any extra formatters or linters you want automatically installed.
  mason_tools = {
    -- "prettier",
    -- "stylua",
  },
}
