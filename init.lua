-- =============================================================================
-- 🌊  Nami — Neovim Framework
-- =============================================================================
-- Entry point. Boots the framework, merges user config, loads plugins.
-- =============================================================================

if vim.loader then
	vim.loader.enable()
end

-- ── Environment Path Patch (fixes Node.js/Mason path issues in GUI/IDE) ─────
local function patch_path()
	-- 1. Prepend Mason bin path
	local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
	if vim.fn.isdirectory(mason_bin) == 1 and not vim.env.PATH:find(mason_bin, 1, true) then
		vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
	end

	-- 2. If node is not executable, check typical version manager paths (like NVM)
	if vim.fn.executable("node") == 0 then
		local home = vim.env.HOME
		local nvm_dir = home .. "/.nvm/versions/node"
		if vim.fn.isdirectory(nvm_dir) == 1 then
			local versions = vim.fn.glob(nvm_dir .. "/*/bin", true, true)
			if #versions > 0 then
				table.sort(versions)
				local latest_node_bin = versions[#versions]
				vim.env.PATH = latest_node_bin .. ":" .. vim.env.PATH
			end
		end
	end
end
patch_path()

-- Suppress deprecation warnings (lspconfig v2 → v3 transition)
vim.deprecate = function() end

-- ── Boot Nami Framework ─────────────────────────────────────────────────────
-- 1. Load user overrides from lua/custom/ (if they exist)
local nami = require("nami")
local user_ok, user = pcall(require, "custom.init")
if not user_ok then
	user = {}
end

-- 2. Merge user settings over framework defaults
nami.setup(user.settings or {})

-- Leader keys must be set BEFORE lazy loads plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core options immediately
require("nami.options")

-- ── Bootstrap lazy.nvim ─────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugin setup ────────────────────────────────────────────────────────────
local settings = nami.config.current or {}

-- Build the spec: framework plugins + user extras + custom plugins
local spec = { { import = "plugins" } }

-- Add opt-in extras from settings
for _, extra in ipairs(settings.extras or {}) do
	table.insert(spec, { import = extra })
end

-- Add user's custom plugins (if custom/plugins/ exists)
if user.plugins then
	table.insert(spec, { import = user.plugins })
end

require("lazy").setup(spec, {
	defaults = { lazy = true },
	install = { colorscheme = { "catppuccin" } },
	rocks = { enabled = false },
	ui = {
		icons = {
			ft = "",
			lazy = "󰂠 ",
			loaded = "",
			not_loaded = "",
		},
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"2html_plugin",
				"tohtml",
				"getscript",
				"getscriptPlugin",
				"gzip",
				"logipat",
				"netrw",
				"netrwPlugin",
				"netrwSettings",
				"netrwFileHandlers",
				"matchit",
				"tar",
				"tarPlugin",
				"rrhelper",
				"spellfile_plugin",
				"vimball",
				"vimballPlugin",
				"zip",
				"zipPlugin",
				"tutor",
				"rplugin",
				"syntax",
				"synmenu",
				"optwin",
				"compiler",
				"bugreport",
				"ftplugin",
			},
		},
	},
})

-- ── Load keymaps & autocmds after plugins ────────────────────────────────────
vim.schedule(function()
	-- Framework keymaps & autocmds
	require("nami.keymaps")
	require("nami.autocmds")

	-- User's custom keymaps & autocmds (if they exist)
	pcall(require, "custom.keymaps")
	pcall(require, "custom.autocmds")

	-- Framework commands
	require("nami.commands")
end)
