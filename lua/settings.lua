-- ==============================================================================
-- 🌊  NamiConfig — User Settings
-- ==============================================================================
-- Edit this file to configure your Neovim experience.
-- Hot-reload: changes take effect on :w without restarting Neovim.
--
-- Theme picker: <leader>th  (live preview + persists here automatically)
-- ==============================================================================

---@alias Theme
--- Light: "catppuccin-latte" | "tokyonight-day" | "rose-pine-dawn" | "kanagawa-lotus"
---        "github_light" | "dayfox" | "onedark-light" | "ayu-light" | "cyberdream-light" | "material-lighter"
--- Dark:  "catppuccin-mocha" | "catppuccin-frappe" | "catppuccin-macchiato"
---        "tokyonight-night" | "tokyonight-storm" | "tokyonight-moon"
---        "rose-pine-main" | "rose-pine-moon" | "kanagawa-wave" | "kanagawa-dragon"
---        "github_dark" | "github_dark_dimmed" | "nightfox" | "duskfox" | "nordfox" | "terafox" | "carbonfox"
---        "onedark-dark" | "onedark-darker" | "onedark-cool" | "onedark-deep" | "onedark-warm" | "onedark-warmer"
---        "gruvbox" | "nord" | "dracula" | "sonokai" | "oxocarbon" | "monokai"
---        "everforest" | "gruvbox-material" | "poimandres"
---        "nightfly" | "moonfly" | "ayu-dark" | "ayu-mirage" | "cyberdream-dark" | "material-darker" | "material-oceanic"
---        "night-owl" | "solarized-osaka" | "mellifluous" | "bamboo"

---@alias Extra
---| "plugins.extras.lang.go"
---| "plugins.extras.lang.rust"
---| "plugins.extras.lang.sql"
---| "plugins.extras.testing.neotest"

return {
	-- ── UI & Aesthetics ──────────────────────────────────────────────────────────
	ui = {
		---@type Theme
		theme = "tokyonight-night",

		background = "dark",
		transparent = true, -- false = rich #1e1e2e background (true dark)
		dim_inactive = false,
		show_indent_guides = true,
		smooth_scroll = true,
		cmdheight = 0, -- 0 = modern hidden cmdline

		-- Pickers & Menus
		picker = {
			layout = "default", -- "telescope" | "ivy" | "dropdown" | "default" | "vertical" | "vscode"
			width = 0.85,
			height = 0.8,
			border = "rounded", -- "rounded" | "single" | "double" | "solid" | "none"
		},

		-- GUI (Neovide)
		neovide = {
			transparency = 0.95,
			line_height = 2,
		},

		-- Bufferline style
		bufferline_style = "nvchad", -- "nvchad" | "solid"
	},

	-- ── Editor Behavior ──────────────────────────────────────────────────────────
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
		color_column = "80",
		split_below = true,
		split_right = true,
		ignore_case_search = true,
	},

	-- ── LSP / Code Intelligence ──────────────────────────────────────────────────
	lsp = {
		enable_inlay_hints = true,
		show_inline_errors = true,
	},

	-- ── File Explorer ────────────────────────────────────────────────────────────
	explorer = {
		show_hidden = true,
		position = "left", -- "left" | "right"
	},

	-- ── Linting ──────────────────────────────────────────────────────────────────
	linting = {
		enable = true,
	},

	-- ── Project-Local Config ─────────────────────────────────────────────────────
	project = {
		enable_config = true, -- Load .neoconf.json for per-project LSP settings
	},

	-- ── Extras (opt-in feature modules) ─────────────────────────────────────────
	---@type Extra[]
	extras = {
		"plugins.extras.lang.go",
		"plugins.extras.lang.rust",
		"plugins.extras.lang.sql",
		"plugins.extras.testing.neotest",
	},

	-- ── Custom Tooling ───────────────────────────────────────────────────────────
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
