-- neoconf.nvim: project-local Neovim/LSP configuration overrides
-- Drop a .neoconf.json in any project root to override LSP settings locally.
--
-- Example .neoconf.json:
--   {
--     "pyright": {
--       "python.analysis.typeCheckingMode": "strict"
--     },
--     "lua_ls": {
--       "Lua.diagnostics.globals": ["vim", "hs"]
--     }
--   }
--
-- Toggle via settings.lua → enable_project_config = true/false
return {
  {
    "folke/neoconf.nvim",
    -- Must load BEFORE lspconfig so it can intercept LSP opts
    priority     = 1000,
    lazy         = false,
    config       = function()
      local ok, settings = pcall(require, "settings")
      if not ok then settings = {} end

      if settings.enable_project_config == false then return end

      require("neoconf").setup({
        -- Files neoconf reads (in priority order)
        local_settings  = ".neoconf.json",
        global_settings = "neoconf.json",

        -- Import from existing per-project files
        import = {
          vscode    = true,  -- .vscode/settings.json
          coc       = true,  -- coc-settings.json
          nlsp      = true,  -- .nlsp-settings/*.json
        },

        -- Live-reload when the config file changes
        live_reload = true,

        -- Log level for debugging: "trace" | "debug" | "info" | "warn" | "error"
        filetype_jsonc = true, -- Use JSONC syntax in .neoconf.json
      })
    end,
  },
}
