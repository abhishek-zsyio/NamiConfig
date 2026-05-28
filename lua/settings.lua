-- ==============================================================================
-- 🚀  User Configuration Settings
-- ==============================================================================

---@alias Theme
--- Light Themes:
---| "catppuccin-latte" | "tokyonight-day" | "rose-pine-dawn" | "kanagawa-lotus"
---| "github_light" | "dayfox" | "onedark-light"
---| "ayu-light" | "cyberdream-light" | "material-lighter"
--- Dark Themes:
---| "catppuccin-mocha" | "catppuccin-frappe" | "catppuccin-macchiato"
---| "tokyonight-night" | "tokyonight-storm" | "tokyonight-moon"
---| "rose-pine-main" | "rose-pine-moon"
---| "kanagawa-wave" | "kanagawa-dragon"
---| "github_dark" | "github_dark_dimmed"
---| "nightfox" | "duskfox" | "nordfox" | "terafox" | "carbonfox"
---| "onedark-dark" | "onedark-darker" | "onedark-cool" | "onedark-deep" | "onedark-warm" | "onedark-warmer"
---| "gruvbox" | "nord" | "dracula" | "sonokai" | "oxocarbon" | "monokai"
---| "everforest" | "gruvbox-material" | "poimandres"
---| "nightfly" | "moonfly" | "ayu-dark" | "ayu-mirage" | "cyberdream-dark" | "material-darker" | "material-oceanic"
---| "night-owl" | "solarized-osaka" | "mellifluous" | "bamboo"

---@alias Extra
---| "plugins.extras.lang.go"
---| "plugins.extras.lang.rust"
---| "plugins.extras.lang.sql"
---| "plugins.extras.testing.neotest"

return {
	-- ── UI & Aesthetics ────────────────────────────────────────────────────────
	---@type Theme
	theme = "rose-pine-main",
	background = "dark",
	transparent = true,
	show_tab_buffer = true, -- Enable/disable the tab buffer bar completely
	tab_buffer_style = "buffers", -- Options: "buffers", "tabs"
	tab_buffer_show_icons = true, -- Toggle file-type icons in tabs
	tab_buffer_show_close = false, -- Toggle close button inside tabs
	tab_buffer_diagnostics = "nvim_lsp", -- Options: "nvim_lsp", "none"
	tab_divider_style = "slope", -- Options: "slant", "slope", "thick", "thin", "none", "dotted"
	tab_buffer_transparent_dividers = true, -- Make vertical divider lines completely transparent
	hide_empty_tabline = true, -- Hide buffer bar when only 1 file is open
	show_indent_guides = true,
	smooth_scroll = true,
	dim_inactive = false,
	line_height = 2, -- Additional spacing between lines (GUI only, e.g., Neovide)
	cmdheight = 0, -- 0 for modern hidden cmdline, 1 for classic
	neovide_transparency = 0.9, -- Transparency level for Neovide (0.0 to 1.0)

	-- ── Menus & Pickers (UI) ───────────────────────────────────────────────────
	picker_layout = "ivy", -- Options: "telescope", "ivy", "dropdown", "default", "vertical", "horizontal", "vscode"
	picker_width = 0.85,
	picker_height = 0.8,
	menu_border = "rounded", -- Options: "rounded", "single", "double", "solid", "shadow", "none"

	-- ── Editor Behavior ────────────────────────────────────────────────────────
	highlight_current_line = true,
	show_line_numbers = true,
	relative_line_numbers = true,
	format_on_save = true,
	tab_size = 2,
	mouse_support = false,
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
