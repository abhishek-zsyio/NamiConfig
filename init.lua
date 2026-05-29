if vim.loader then
	vim.loader.enable()
end

-- ── Environment Path Patch ────────────────────────────────────────────────────
-- Fixes Node.js / Mason binary resolution in GUI frontends (Neovide, etc.)
local function patch_path()
	local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
	if vim.fn.isdirectory(mason_bin) == 1 and not vim.env.PATH:find(mason_bin, 1, true) then
		vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
	end

	if vim.fn.executable("node") == 0 then
		local nvm_dir = vim.env.HOME .. "/.nvm/versions/node"
		if vim.fn.isdirectory(nvm_dir) == 1 then
			local versions = vim.fn.glob(nvm_dir .. "/*/bin", true, true)
			if #versions > 0 then
				table.sort(versions)
				vim.env.PATH = versions[#versions] .. ":" .. vim.env.PATH
			end
		end
	end
end
patch_path()

-- Suppress lspconfig v2→v3 deprecation noise
vim.deprecate = function() end

-- Load and wrap settings (supports both flat & nested key access)
require("core.settings_loader").load()

-- Leader keys must be set BEFORE lazy loads plugins
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- Core editor options
require("core.options")

-- ── Bootstrap lazy.nvim ──────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugin spec ──────────────────────────────────────────────────────────────
local ok, settings = pcall(require, "settings")
if not ok then settings = {} end

-- Core plugins + user-enabled extras + user's personal plugins
local spec = { { import = "plugins" }, { import = "custom.plugins" } }
for _, extra in ipairs(settings.extras or {}) do
	table.insert(spec, { import = extra })
end

require("lazy").setup(spec, {
	defaults  = { lazy = true },
	install   = { colorscheme = { "catppuccin" } },
	rocks     = { enabled = false },
	ui = {
		icons = {
			ft        = "",
			lazy      = "󰂠 ",
			loaded    = "",
			not_loaded = "",
		},
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"2html_plugin", "tohtml", "getscript", "getscriptPlugin",
				"gzip", "logipat", "netrw", "netrwPlugin", "netrwSettings",
				"netrwFileHandlers", "matchit", "tar", "tarPlugin", "rrhelper",
				"spellfile_plugin", "vimball", "vimballPlugin", "zip", "zipPlugin",
				"tutor", "rplugin", "syntax", "synmenu", "optwin", "compiler",
				"bugreport", "ftplugin",
			},
		},
	},
})

-- ── Post-plugin load ─────────────────────────────────────────────────────────
vim.schedule(function()
	require("core.keymaps")
	require("core.autocmds")
end)
