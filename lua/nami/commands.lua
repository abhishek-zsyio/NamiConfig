-- =============================================================================
-- 🌊  Nami Framework — Commands
-- =============================================================================
-- Exposes helpful user commands for interacting with the framework.
-- =============================================================================

local M = {}

local function cmd(name, fn, opts)
	opts = opts or {}
	opts.desc = opts.desc or "Nami framework command"
	vim.api.nvim_create_user_command(name, fn, opts)
end

function M.setup()
	cmd("NamiInfo", function()
		local settings = require("nami.config").current or {}
		local version = require("nami").version

		local lines = {
			"🌊 Nami Framework v" .. version,
			"────────────────────────────────────────",
			"Theme:    " .. (settings.ui and settings.ui.theme or "unknown"),
			"BG:       " .. (settings.ui and settings.ui.background or "unknown"),
			"",
			"Active Extras:",
		}

		if settings.extras and #settings.extras > 0 then
			for _, ext in ipairs(settings.extras) do
				table.insert(lines, "  • " .. ext:gsub("plugins.extras.", ""))
			end
		else
			table.insert(lines, "  (None)")
		end

		table.insert(lines, "")
		table.insert(lines, "Config Location: " .. vim.fn.stdpath("config") .. "/lua/custom/settings.lua")

		vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Nami Info" })
	end, { desc = "Show Nami framework information" })

	cmd("NamiUpdate", function()
		vim.notify("Pulling latest Nami updates from Git...", vim.log.levels.INFO, { title = "Nami" })
		vim.fn.jobstart({ "git", "pull" }, {
			cwd = vim.fn.stdpath("config"),
			on_exit = function(_, code)
				if code == 0 then
					vim.notify("Update successful! Please restart Neovim.", vim.log.levels.INFO, { title = "Nami" })
				else
					vim.notify("Update failed. Check git status in ~/.config/nvim.", vim.log.levels.ERROR, { title = "Nami" })
				end
			end,
		})
	end, { desc = "Update Nami framework" })
end

M.setup()

return M
