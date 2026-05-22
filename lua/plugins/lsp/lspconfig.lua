-- LSP Configuration (all servers via lspconfig, NvChad-style capabilities)
return {
  {
    "neovim/nvim-lspconfig",
    event        = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- ── Capabilities (boost with cmp-nvim-lsp) ───────────────────────────
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
      capabilities.textDocument.completion.completionItem = {
        documentationFormat = { "markdown", "plaintext" },
        snippetSupport      = true,
        preselectSupport    = true,
        insertReplaceSupport = true,
        labelDetailsSupport  = true,
        deprecatedSupport    = true,
        commitCharactersSupport = true,
        tagSupport           = { valueSet = { 1 } },
        resolveSupport       = {
          properties = { "documentation", "detail", "additionalTextEdits" },
        },
      }

      -- ── on_attach: keymaps set per-buffer when LSP attaches ──────────────
      local on_attach = function(client, bufnr)
        -- Disable semantic tokens (cleaner with Treesitter highlighting)
        if client.supports_method("textDocument/semanticTokens") then
          client.server_capabilities.semanticTokensProvider = nil
        end

        local map = vim.keymap.set
        local bufopts = { buffer = bufnr, silent = true }

        map("n", "gD",         vim.lsp.buf.declaration,    vim.tbl_extend("force", bufopts, { desc = "LSP Declaration" }))
        map("n", "gd",         vim.lsp.buf.definition,     vim.tbl_extend("force", bufopts, { desc = "LSP Definition" }))
        map("n", "gi",         vim.lsp.buf.implementation,  vim.tbl_extend("force", bufopts, { desc = "LSP Implementation" }))
        map("n", "gr",         vim.lsp.buf.references,      vim.tbl_extend("force", bufopts, { desc = "LSP References" }))
        map("n", "K",          vim.lsp.buf.hover,           vim.tbl_extend("force", bufopts, { desc = "LSP Hover" }))
        map("n", "<leader>ca", vim.lsp.buf.code_action,     vim.tbl_extend("force", bufopts, { desc = "LSP Code action" }))
        map("n", "<leader>ra", vim.lsp.buf.rename,          vim.tbl_extend("force", bufopts, { desc = "LSP Rename" }))
        map("n", "<leader>fm", function()
          vim.lsp.buf.format({ async = true })
        end, vim.tbl_extend("force", bufopts, { desc = "LSP Format" }))
        map("n", "[d",  vim.diagnostic.goto_prev, vim.tbl_extend("force", bufopts, { desc = "Prev diagnostic" }))
        map("n", "]d",  vim.diagnostic.goto_next, vim.tbl_extend("force", bufopts, { desc = "Next diagnostic" }))
      end

      -- ── Diagnostic display ───────────────────────────────────────────────
      vim.diagnostic.config({
        virtual_text    = { prefix = "●" },
        signs           = true,
        underline       = true,
        update_in_insert = false,
        severity_sort    = true,
        float = {
          focusable = false,
          style     = "minimal",
          border    = "rounded",
          source    = "always",
          header    = "",
          prefix    = "",
        },
      })

      -- Update diagnostic signs in signcolumn
      local signs = { Error = " ", Warn = " ", Hint = "󰝶 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      local lspconfig = require("lspconfig")

      -- ── Default setup helper ─────────────────────────────────────────────
      local function default(server, extra_opts)
        local server_opts = vim.tbl_deep_extend("force", {
          on_attach    = on_attach,
          capabilities = capabilities,
        }, extra_opts or {})
        lspconfig[server].setup(server_opts)
      end

      -- ── Servers ──────────────────────────────────────────────────────────
      default("bashls")
      default("sqls")
      default("texlab")
      default("jsonls")
      default("yamlls")
      default("taplo")
      default("dockerls")
      default("docker_compose_language_service")
      default("gopls")
      default("marksman")
      default("unocss")

      default("cssls",      { filetypes = { "css", "scss", "less" } })
      default("tailwindcss")
      default("eslint")
      default("ts_ls")

      default("html", {
        filetypes    = { "html", "htmldjango" },
        capabilities = capabilities,
      })

      default("volar", {
        filetypes = { "vue" },
      })

      default("pyright", {
        filetypes = { "python" },
        settings  = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths  = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      default("emmet_language_server", {
        filetypes = {
          "css", "eruby", "html", "javascript", "javascriptreact",
          "less", "sass", "scss", "pug", "typescriptreact", "htmldjango",
        },
        init_options = {
          showAbbreviationSuggestions = true,
          showExpandedAbbreviation    = "always",
          showSuggestionsAsSnippets   = false,
        },
      })

      default("lua_ls", {
        settings = {
          Lua = {
            runtime     = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace   = {
              library    = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry   = { enable = false },
          },
        },
      })
    end,
  },

  -- Python venv-selector (relies on lspconfig)
  {
    "linux-cultist/venv-selector.nvim",
    ft           = "python",
    lazy         = true,
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    config       = function()
      require("venv-selector").setup({})
    end,
  },
}
