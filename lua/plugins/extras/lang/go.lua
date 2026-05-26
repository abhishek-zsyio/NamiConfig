-- Extra: Go language support
-- Enable in settings.lua → extras = { "plugins.extras.lang.go" }
--
-- Installs: gopls, gofumpt, goimports, delve (DAP), gomodifytags, impl
return {
  -- Go LSP + tools (gopls handled via the lang_registry already)
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    ft    = { "go", "gomod", "gowork", "gotmpl" },
    build = ':lua require("go.install").update_all_sync()',
    config = function()
      require("go").setup({
        go         = "go",
        goimports  = "gopls",
        gofmt      = "gofumpt",
        max_line_len = 120,
        tag_transform = false,
        test_runner = "go",
        run_in_floaterm = false,
        lsp_cfg    = false, -- We configure gopls via lang_registry
        lsp_gofumpt = true,
        lsp_on_attach = false,
        dap_debug  = true,
      })

      -- Go-specific keymaps
      local map = vim.keymap.set
      map("n", "<leader>gr", "<cmd>GoRun<CR>",       { ft = "go", desc = "Go: Run" })
      map("n", "<leader>gT", "<cmd>GoTest<CR>",      { ft = "go", desc = "Go: Test" })
      map("n", "<leader>gi", "<cmd>GoImport<CR>",    { ft = "go", desc = "Go: Import" })
      map("n", "<leader>gfs", "<cmd>GoFillStruct<CR>", { ft = "go", desc = "Go: Fill Struct" })
    end,
  },

  -- Go DAP (delve)
  {
    "leoluz/nvim-dap-go",
    ft           = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    config       = function()
      require("dap-go").setup({
        dap_configurations = {
          {
            type    = "go",
            name    = "Attach remote",
            mode    = "remote",
            request = "attach",
          },
        },
        delve = { initialize_timeout_sec = 20, port = "${port}" },
      })
    end,
  },

  -- Go treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "go", "gomod", "gowork", "gosum" })
    end,
  },
}
