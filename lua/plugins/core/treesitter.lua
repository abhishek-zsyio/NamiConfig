return {
  -- Treesitter Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "javascript",
        "htmldjango",
        "regex",
        "markdown",
        "markdown_inline",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "html" },
      },
    },
  },

  -- Auto-close HTML/JSX tags
  {
    "windwp/nvim-ts-autotag",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
}
