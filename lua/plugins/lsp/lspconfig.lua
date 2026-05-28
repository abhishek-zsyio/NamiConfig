-- LSP Configuration — driven by lua/core/lang_registry.lua
return {
  {
    "neovim/nvim-lspconfig",
    event        = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local ok_s, settings = pcall(require, "settings")
      if not ok_s then settings = {} end

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
      local on_attach = function(_, bufnr)
        local map = vim.keymap.set
        local bufopts = { buffer = bufnr, silent = true }
        local e = function(tbl, extra)
          return vim.tbl_extend("force", tbl, extra)
        end

        -- Enable inlay hints if requested
        if settings.enable_inlay_hints == true and vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end

        map("n", "gD",         vim.lsp.buf.declaration,    e(bufopts, { desc = "LSP Declaration" }))
        map("n", "gd",         vim.lsp.buf.definition,     e(bufopts, { desc = "LSP Definition" }))
        map("n", "gi",         vim.lsp.buf.implementation,  e(bufopts, { desc = "LSP Implementation" }))
        map("n", "gr",         vim.lsp.buf.references,      e(bufopts, { desc = "LSP References" }))
        map("n", "K",          vim.lsp.buf.hover,           e(bufopts, { desc = "LSP Hover" }))
        map("n", "<leader>ca", vim.lsp.buf.code_action,     e(bufopts, { desc = "LSP Code action" }))
        map("n", "<leader>ra", vim.lsp.buf.rename,          e(bufopts, { desc = "LSP Rename" }))
        map("n", "<leader>fm", function()
          local ok, conform = pcall(require, "conform")
          if ok then
            conform.format({ async = true, lsp_format = "fallback" })
          else
            vim.lsp.buf.format({ async = true })
          end
        end, e(bufopts, { desc = "Format Buffer" }))
        map("n", "[d",  vim.diagnostic.goto_prev, e(bufopts, { desc = "Prev diagnostic" }))
        map("n", "]d",  vim.diagnostic.goto_next, e(bufopts, { desc = "Next diagnostic" }))
      end

      -- ── Diagnostic display ───────────────────────────────────────────────
      vim.diagnostic.config({
        virtual_text    = settings.show_inline_errors ~= false and { prefix = "●" } or false,
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

      local signs = { Error = " ", Warn = " ", Hint = "󰝶 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      local lspconfig = require("lspconfig")
      local registry  = require("nami.lang")

      -- ── Boot all servers from the lang registry ───────────────────────────
      for _, srv in ipairs(registry.lsp_servers()) do
        local server_opts = vim.tbl_deep_extend("force", {
          on_attach    = on_attach,
          capabilities = capabilities,
        }, srv.opts or {})
        lspconfig[srv.name].setup(server_opts)
      end

      -- ── Boot custom user servers from settings.lua ───────────────────────
      for _, srv_name in ipairs(settings.lsp_servers or {}) do
        -- Check if it wasn't already booted by the registry
        local is_in_registry = false
        for _, r_srv in ipairs(registry.lsp_servers()) do
          if r_srv.name == srv_name then is_in_registry = true break end
        end
        if not is_in_registry then
          lspconfig[srv_name].setup({
            on_attach    = on_attach,
            capabilities = capabilities,
          })
        end
      end

      -- ── Extra servers not in the registry ────────────────────────────────
      -- These are servers with special filetypes or not tracked per-language
      local extras = {
        tailwindcss = {},
        eslint      = {},
        unocss      = {},
        sqls        = {},
        texlab      = {},
        -- NOTE: gopls is managed by lang_registry (go entry) — do not duplicate here
        docker_compose_language_service = {},
        emmet_language_server = {
          filetypes = {
            "css", "eruby", "html", "javascript", "javascriptreact",
            "less", "sass", "scss", "pug", "typescriptreact", "htmldjango",
          },
          init_options = {
            showAbbreviationSuggestions = true,
            showExpandedAbbreviation    = "always",
            showSuggestionsAsSnippets   = false,
          },
        },
        volar = { filetypes = { "vue" } },
      }
      for name, extra_opts in pairs(extras) do
        -- Only setup if the command is executable (installed by Mason or globally)
        -- This prevents errors when a server is configured but not installed
        local has_cmd = false
        pcall(function()
          local cmd = lspconfig[name].document_config.default_config.cmd
          if cmd and cmd[1] and vim.fn.executable(cmd[1]) == 1 then
            has_cmd = true
          end
        end)
        
        if has_cmd then
          local server_opts = vim.tbl_deep_extend("force", {
            on_attach    = on_attach,
            capabilities = capabilities,
          }, extra_opts)
          pcall(lspconfig[name].setup, server_opts)
        end
      end
    end,
  },
}
