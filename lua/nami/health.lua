-- =============================================================================
-- 🌊  Nami Framework — Health Checks
-- =============================================================================
-- Integrates with `:checkhealth nami` to verify all required dependencies.
-- =============================================================================

local M = {}

function M.check()
	vim.health.start("Nami Framework")

	-- Core Requirements
	vim.health.info("Checking Core Requirements")
	local core_tools = {
		{ cmd = "git", name = "Git" },
		{ cmd = "rg", name = "ripgrep" },
		{ cmd = "fd", name = "fd" },
		{ cmd = "lazygit", name = "lazygit" },
		{ cmd = "node", name = "Node.js" },
		{ cmd = "npm", name = "npm" },
	}

	for _, tool in ipairs(core_tools) do
		if vim.fn.executable(tool.cmd) == 1 then
			vim.health.ok(tool.name .. " is installed")
		else
			vim.health.error(tool.name .. " is missing! Required for core functionality.")
		end
	end

	-- Optional Extras
	vim.health.info("Checking Optional Extras")
	local optional_tools = {
		{ cmd = "python3", name = "Python 3" },
		{ cmd = "go", name = "Go" },
		{ cmd = "cargo", name = "Rust (cargo)" },
		{ cmd = "silicon", name = "Silicon (for code screenshots)" },
		{ cmd = "deno", name = "Deno (for markdown preview)" },
	}

	for _, tool in ipairs(optional_tools) do
		if vim.fn.executable(tool.cmd) == 1 then
			vim.health.ok(tool.name .. " is installed")
		else
			vim.health.warn(tool.name .. " is not installed. Some optional features may not work.")
		end
	end

	-- Configuration
	vim.health.info("Checking Configuration")
	local custom_settings = vim.fn.stdpath("config") .. "/lua/custom/settings.lua"
	if vim.fn.filereadable(custom_settings) == 1 then
		vim.health.ok("Custom settings found: lua/custom/settings.lua")
	else
		vim.health.warn("Custom settings not found. Using framework defaults.")
	end
end

return M
