-- =============================================================================
-- 🌊  Nami Framework — Utility Functions
-- =============================================================================
-- Common helpers for framework internals and user customization.
-- Usage: local utils = require("nami.utils")
-- =============================================================================

local M = {}

--- Get the current merged settings table.
---@return table
function M.get_settings()
	return require("nami.config").current or {}
end

--- Wrapper for vim.keymap.set with sensible defaults.
---@param mode string|table
---@param lhs string
---@param rhs string|function
---@param opts? table
function M.map(mode, lhs, rhs, opts)
	opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
	vim.keymap.set(mode, lhs, rhs, opts)
end

--- Safely load a module from `lua/custom/`. Returns the module or an empty table.
---@param module string Module name relative to `custom.` (e.g., "settings", "keymaps")
---@return table
function M.load_custom(module)
	local ok, mod = pcall(require, "custom." .. module)
	return ok and mod or {}
end

--- Check if a `lua/custom/<module>.lua` file exists.
---@param module string
---@return boolean
function M.has_custom(module)
	local path = vim.fn.stdpath("config") .. "/lua/custom/" .. module:gsub("%.", "/") .. ".lua"
	return vim.fn.filereadable(path) == 1
end

--- Notify with Nami branding.
---@param msg string
---@param level? integer vim.log.levels.*
function M.notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "Nami" })
end

--- Get the Nami framework version.
---@return string
function M.version()
	return require("nami").version
end

--- Deep-merge a list of tables (left to right).
---@param ... table
---@return table
function M.merge(...)
	local result = {}
	for _, t in ipairs({ ... }) do
		result = vim.tbl_deep_extend("force", result, t or {})
	end
	return result
end

--- Get a highlight group's attribute value as a hex string.
---@param name string Highlight group name
---@param attr string "fg" or "bg"
---@return string|nil
function M.get_hl_hex(name, attr)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
	if ok and hl and hl[attr] then
		return ("#%06x"):format(hl[attr])
	end
	return nil
end

--- Get the path to the Nami config directory.
---@return string
function M.config_dir()
	return vim.fn.stdpath("config")
end

--- Get the path to the user's custom directory.
---@return string
function M.custom_dir()
	return vim.fn.stdpath("config") .. "/lua/custom"
end

return M
