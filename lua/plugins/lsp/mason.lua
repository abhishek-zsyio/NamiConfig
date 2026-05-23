-- Mason: LSP/formatter/linter installer
-- Tools are automatically derived from lua/core/lang_registry.lua
return {
  {
    "williamboman/mason.nvim",
    cmd    = { "Mason", "MasonInstall", "MasonUpdate" },
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed   = "✓",
            package_pending     = "➜",
            package_uninstalled = "✗",
          },
          border = "rounded",
        },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy         = true,
    dependencies = { "williamboman/mason.nvim" },
    config       = function()
      local registry = require("core.lang_registry")
      local ok, settings = pcall(require, "settings")
      if not ok then settings = {} end

      -- Collect only LSP server names for mason-lspconfig
      local lsp_servers = {}
      local seen = {}
      for _, srv in ipairs(registry.lsp_servers()) do
        if not seen[srv.name] then
          seen[srv.name] = true
          table.insert(lsp_servers, srv.name)
        end
      end
      
      -- Add user's custom LSPs from settings.lua
      for _, name in ipairs(settings.lsp_servers or {}) do
        if not seen[name] then
          seen[name] = true
          table.insert(lsp_servers, name)
        end
      end

      require("mason-lspconfig").setup({
        ensure_installed   = lsp_servers,
        automatic_installation = true,
      })
    end,
  },

  -- mason-tool-installer: installs formatters/linters that aren't LSP servers
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- Expose commands so lazy.nvim registers them immediately,
    -- and load on VeryLazy so run_on_start fires on every startup.
    cmd   = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    config       = function()
      local registry = require("core.lang_registry")
      local ok, settings = pcall(require, "settings")
      if not ok then settings = {} end
      
      local tools = registry.mason_tools()
      local seen_tools = {}
      for _, t in ipairs(tools) do seen_tools[t] = true end
      
      -- Add user's custom tools from settings.lua
      for _, name in ipairs(settings.mason_tools or {}) do
        if not seen_tools[name] then
          seen_tools[name] = true
          table.insert(tools, name)
        end
      end

      require("mason-tool-installer").setup({
        ensure_installed = tools,
        auto_update      = false,
        run_on_start     = true,   -- installs missing tools on every startup
      })
    end,
  },
}

