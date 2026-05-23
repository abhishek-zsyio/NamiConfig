-- Extra: SQL language support + interactive DB explorer
-- Enable in settings.lua → extras = { "plugins.extras.lang.sql" }
--
-- Installs: sqls (LSP), sqlfluff (linter/formatter), vim-dadbod (DB UI)
return {
  -- vim-dadbod: interactive DB explorer (supports Postgres, MySQL, SQLite, etc.)
  {
    "tpope/vim-dadbod",
    lazy = true,
    cmd  = { "DB", "DBUI" },
  },

  -- vim-dadbod-ui: beautiful UI around vim-dadbod
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd  = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts   = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_auto_execute_table_helpers = 1
    end,
    keys = {
      { "<leader>Du", "<cmd>DBUIToggle<CR>",        desc = "DB: Toggle UI" },
      { "<leader>Da", "<cmd>DBUIAddConnection<CR>", desc = "DB: Add Connection" },
      { "<leader>Df", "<cmd>DBUIFindBuffer<CR>",    desc = "DB: Find Buffer" },
    },
  },

  -- vim-dadbod-completion: SQL completion inside .sql buffers
  {
    "kristijanhusak/vim-dadbod-completion",
    ft   = { "sql", "mysql", "plsql" },
    lazy = true,
    config = function()
      -- Wire into nvim-cmp
      local ok, cmp = pcall(require, "cmp")
      if ok then
        cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
          sources = cmp.config.sources({
            { name = "vim-dadbod-completion" },
            { name = "buffer" },
          }),
        })
      end
    end,
  },

  -- SQL treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "sql" })
    end,
  },
}
