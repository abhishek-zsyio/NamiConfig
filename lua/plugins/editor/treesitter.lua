-- Treesitter: use opts so lazy.nvim handles module loading correctly
return {
  {
    "nvim-treesitter/nvim-treesitter",
    event  = { "BufReadPost", "BufNewFile", "VeryLazy" },
    build  = ":TSUpdate",
    -- Use config function to call setup on the correct new module
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)
    end,
    opts   = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css",
        "javascript", "typescript", "tsx",
        "json", "jsonc",
        "python",
        "htmldjango",
        "markdown", "markdown_inline",
        "regex",
        "bash",
        "yaml", "toml",
        "dockerfile",
        "vue",
      },
      highlight = {
        enable                            = true,
        additional_vim_regex_highlighting = { "html" },
      },
      indent = { enable = true },
    },
  },

}
