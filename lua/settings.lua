-- ==============================================================================
-- 🚀  User Configuration Settings (Structured & Grouped)
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

local M = {
	-- ── UI & Aesthetics ────────────────────────────────────────────────────────
	ui = {
		---@type Theme
		theme = "kanagawa-wave",

		background = "dark", -- "dark" or "light"
		transparent = ture,
		dim_inactive = false,
		show_indent_guides = true,
		smooth_scroll = true,
		cmdheight = 0, -- 0 for modern hidden cmdline, 1 for classic



		-- Pickers & Menus (snacks.picker / telescope / fzf-lua)
		picker = {
			layout = "default", -- Options: "telescope", "ivy", "dropdown", "default", "vertical", "horizontal", "vscode"
			width = 0.85,
			height = 0.8,
			border = "rounded", -- Options: "rounded", "single", "double", "solid", "shadow", "none"
		},

		-- GUI Settings (Neovide specific)
		neovide = {
			transparency = 0.9, -- Transparency level for Neovide (0.0 to 1.0)
			line_height = 2, -- Additional spacing between lines (GUI only)
		},

		-- Bufferline Style
		bufferline_style = "nvchad", -- Options: "nvchad" (dark tab, bright accent bar, colored icons), "solid" (bright tab, dark text/icons)
	},

	-- ── Editor Behavior ────────────────────────────────────────────────────────
	editor = {
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
	},

	-- ── Code Intelligence (LSP) ────────────────────────────────────────────────
	lsp = {
		enable_inlay_hints = true,
		show_inline_errors = true,
	},

	-- ── File Explorer (snacks.explorer) ────────────────────────────────────────
	explorer = {
		show_hidden = true,
		position = "left", -- "left" or "right"
	},

	-- ── Linting (nvim-lint) ────────────────────────────────────────────────────
	linting = {
		enable = true,
	},

	-- ── Project-Local Configuration ────────────────────────────────────────────
	project = {
		enable_config = true, -- Enable project-local config loading (.neoconf.json)
	},

	-- ── Extras (Opt-in Modules) ────────────────────────────────────────────────
	---@type Extra[]
	extras = {
		"plugins.extras.lang.go",
		"plugins.extras.lang.rust",
		"plugins.extras.lang.sql",
		"plugins.extras.testing.neotest",
	},

	-- ── Custom Tooling Installation ────────────────────────────────────────────
	custom_tools = {
		lsp_servers = {
			"clangd",
			"tailwindcss",
		},
		mason_tools = {
			"prettier",
			"stylua",
		},
	},
}

return M
