-- =============================================================================
-- 🌊  Nami Framework — Configuration Engine
-- =============================================================================
-- Defines ALL framework defaults. User overrides from `lua/custom/settings.lua`
-- are deep-merged on top. The merged result is injected into
-- `package.loaded["settings"]` so existing plugin code keeps working.
-- =============================================================================

local M = {}

-- ── Framework Defaults ───────────────────────────────────────────────────────
-- These are the out-of-the-box settings. Users only need to specify
-- what they want to CHANGE in `lua/custom/settings.lua`.
M.defaults = {
	-- ── UI & Aesthetics ────────────────────────────────────────────────────
	ui = {
		---@type string
		theme = "catppuccin-mocha",
		background = "dark", -- "dark" or "light"
		transparent = false,
		dim_inactive = false,
		show_indent_guides = true,
		smooth_scroll = true,
		cmdheight = 0, -- 0 for modern hidden cmdline, 1 for classic

		-- Pickers & Menus (snacks.picker)
		picker = {
			layout = "default", -- "telescope", "ivy", "dropdown", "default", "vertical", "horizontal", "vscode"
			width = 0.85,
			height = 0.8,
			border = "rounded", -- "rounded", "single", "double", "solid", "shadow", "none"
		},

		-- GUI Settings (Neovide specific)
		neovide = {
			transparency = 0.9,
			line_height = 2,
		},

		-- Bufferline Style
		bufferline_style = "nvchad", -- "nvchad" or "solid"
	},

	-- ── Editor Behavior ────────────────────────────────────────────────────
	editor = {
		highlight_current_line = true,
		show_line_numbers = true,
		relative_line_numbers = true,
		format_on_save = true,
		tab_size = 2,
		mouse_support = false,
		wrap_lines = false,
		scrolloff = 8,
		auto_save = false,
		blink_cursor = true,
		color_column = "80",
		split_below = true,
		split_right = true,
		ignore_case_search = true,
	},

	-- ── Code Intelligence (LSP) ────────────────────────────────────────────
	lsp = {
		enable_inlay_hints = true,
		show_inline_errors = true,
	},

	-- ── File Explorer (snacks.explorer) ────────────────────────────────────
	explorer = {
		show_hidden = true,
		position = "left", -- "left" or "right"
	},

	-- ── Linting (nvim-lint) ────────────────────────────────────────────────
	linting = {
		enable = true,
	},

	-- ── Project-Local Configuration ────────────────────────────────────────
	project = {
		enable_config = true,
	},

	-- ── Extras (Opt-in Modules) ────────────────────────────────────────────
	---@type string[]
	extras = {},

	-- ── Custom Tooling Installation ────────────────────────────────────────
	custom_tools = {
		lsp_servers = {},
		mason_tools = {},
	},
}

-- ── Merged config (populated after setup) ────────────────────────────────────
M.current = nil

-- ── Flat-key compatibility layer ─────────────────────────────────────────────
-- Allows `settings.theme`, `settings.picker_layout`, etc. to work
-- alongside the nested `settings.ui.theme`, `settings.ui.picker.layout`.
local function wrap_settings(merged)
	return setmetatable(merged, {
		__index = function(self, key)
			-- 1. Direct top-level key
			if rawget(self, key) ~= nil then
				return rawget(self, key)
			end

			-- 2. Flat → nested translations (backward compat)
			local translations = {
				theme = self.ui.theme,
				background = self.ui.background,
				transparent = self.ui.transparent,
				dim_inactive = self.ui.dim_inactive,
				show_indent_guides = self.ui.show_indent_guides,
				smooth_scroll = self.ui.smooth_scroll,
				cmdheight = self.ui.cmdheight,
				bufferline_style = self.ui.bufferline_style,
				show_hidden_files = self.explorer.show_hidden,
				file_explorer_position = self.explorer.position,
				enable_linting = self.linting.enable,
				enable_project_config = self.project.enable_config,
				lsp_servers = self.custom_tools.lsp_servers,
				mason_tools = self.custom_tools.mason_tools,
				picker_layout = self.ui.picker.layout,
				picker_width = self.ui.picker.width,
				picker_height = self.ui.picker.height,
				menu_border = self.ui.picker.border,
				neovide_transparency = self.ui.neovide.transparency,
				line_height = self.ui.neovide.line_height,
			}
			if translations[key] ~= nil then
				return translations[key]
			end

			-- 3. Deep search through nested groups
			local function find_key(t, k)
				if type(t) ~= "table" then
					return nil
				end
				if rawget(t, k) ~= nil then
					return rawget(t, k)
				end
				for sub_key, v in pairs(t) do
					if
						type(v) == "table"
						and sub_key ~= "extras"
						and sub_key ~= "lsp_servers"
						and sub_key ~= "mason_tools"
					then
						local res = find_key(v, k)
						if res ~= nil then
							return res
						end
					end
				end
				return nil
			end

			return find_key(self, key)
		end,
		__newindex = function(self, key, value)
			-- Ensure writes to theme update the nested ui.theme correctly
			if key == "theme" then
				self.ui.theme = value
			else
				rawset(self, key, value)
			end
		end,
	})
end

-- ── Setup: merge user overrides and activate ─────────────────────────────────
function M.apply(user_opts)
	local merged = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), user_opts or {})
	local wrapped = wrap_settings(merged)

	M.current = wrapped

	-- Inject into package.loaded so `require("settings")` returns the merged config
	package.loaded["settings"] = wrapped

	return wrapped
end

-- ── Convenience getter ───────────────────────────────────────────────────────
-- Usage: require("nami").config.get("ui.theme") → "catppuccin-mocha"
function M.get(path)
	if not M.current then
		return nil
	end
	local parts = vim.split(path, ".", { plain = true })
	local val = M.current
	for _, part in ipairs(parts) do
		if type(val) ~= "table" then
			return nil
		end
		val = val[part]
	end
	return val
end

-- ── Hot-reload: re-read custom/settings.lua and re-apply ─────────────────────
function M.reload()
	-- Clear cached modules
	package.loaded["custom.settings"] = nil
	package.loaded["custom.init"] = nil
	package.loaded["settings"] = nil

	local ok, user_settings = pcall(require, "custom.settings")
	if not ok then
		user_settings = {}
	end

	M.apply(user_settings)
	return M.current
end

return M
