-- Mason: LSP/formatter/linter installer
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
      require("mason-lspconfig").setup({
        ensure_installed = {
          -- Web
          "html",
          "cssls",
          "ts_ls",
          "tailwindcss",
          "eslint",
          "emmet_language_server",
          "jsonls",
          -- Lua
          "lua_ls",
          -- Python
          "pyright",
          -- Shell
          "bashls",
          -- Markdown
          "marksman",
          -- YAML / TOML
          "yamlls",
          "taplo",
          -- Docker
          "dockerls",
          "docker_compose_language_service",
        },
        automatic_installation = true,
      })
    end,
  },
}
