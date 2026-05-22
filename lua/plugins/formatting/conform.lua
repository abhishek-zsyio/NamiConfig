-- Conform.nvim: formatting on save (replaces null-ls for formatting)
return {
  {
    "stevearc/conform.nvim",
    event  = { "BufWritePre" },
    cmd    = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua        = { "stylua" },
          python     = { "black" },
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          html       = { "prettier" },
          htmldjango = { "djlint" },
          css        = { "prettier" },
          json       = { "prettier" },
          yaml       = { "prettier" },
          markdown   = { "prettier" },
          bash       = { "shfmt" },
        },
        format_on_save = {
          timeout_ms  = 500,
          lsp_fallback = true,
        },
      })
    end,
  },
}
