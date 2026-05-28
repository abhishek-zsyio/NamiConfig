-- =============================================================================
-- 🌊  Nami — Neovim Framework
-- =============================================================================
-- Public API entry point.
--
-- Usage:
--   local nami = require("nami")
--   nami.setup(user_settings)
--   nami.config.get("ui.theme")
-- =============================================================================

local M = {}

M.version = "1.0.0"

-- ── Sub-modules (lazy-loaded) ────────────────────────────────────────────────

--- Configuration engine (defaults + merge + get)
M.config = require("nami.config")

--- Utility helpers
M.utils = require("nami.utils")

-- ── Setup ────────────────────────────────────────────────────────────────────
--- Initialize the framework with user overrides.
--- Called from init.lua during boot.
---@param user_opts? table User's settings from custom/settings.lua
function M.setup(user_opts)
	M.config.apply(user_opts)
end

-- ── Convenience shortcuts ────────────────────────────────────────────────────

--- Get the current merged settings.
---@return table
function M.settings()
	return M.config.current or {}
end

--- Reload user settings from custom/settings.lua and re-apply.
function M.reload()
	return M.config.reload()
end

return M
