-- Extra: Rust language support
-- Enable in settings.lua → extras = { "plugins.extras.lang.rust" }
--
-- Installs: rust-analyzer, codelldb (DAP), rustfmt, cargo-expand
return {
  -- rustaceanvim: best-in-class Rust LSP integration
  {
    "mrcjkb/rustaceanvim",
    version      = "^5",
    ft           = { "rust" },
    dependencies = { "neovim/nvim-lspconfig" },
    config       = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      vim.g.rustaceanvim = {
        server = {
          capabilities = capabilities,
          settings     = {
            ["rust-analyzer"] = {
              cargo    = { allFeatures = true },
              checkOnSave = { command = "clippy" },
              procMacro   = { enable = true },
            },
          },
        },
        tools = {
          hover_actions    = { auto_focus = true },
          inlay_hints      = { auto = true },
          float_win_config = { border = "rounded" },
        },
      }

      -- Rust-specific keymaps
      local map = vim.keymap.set
      map("n", "<leader>rr", function() vim.cmd("RustLsp runnables") end,   { ft = "rust", desc = "Rust: Runnables" })
      map("n", "<leader>rt", function() vim.cmd("RustLsp testables") end,   { ft = "rust", desc = "Rust: Testables" })
      map("n", "<leader>re", function() vim.cmd("RustLsp expandMacro") end, { ft = "rust", desc = "Rust: Expand Macro" })
      map("n", "<leader>rc", function() vim.cmd("RustLsp openCargo") end,   { ft = "rust", desc = "Rust: Open Cargo.toml" })
    end,
  },

  -- Rust DAP (codelldb)
  {
    "mfussenegger/nvim-dap",
    optional = true,
    config   = function()
      local dap = require("dap")
      dap.adapters.codelldb = {
        type    = "server",
        port    = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
          args    = { "--port", "${port}" },
        },
      }
      dap.configurations.rust = {
        {
          name    = "Launch",
          type    = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd     = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
    end,
  },

  -- Rust treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "rust", "toml" })
    end,
  },
}
