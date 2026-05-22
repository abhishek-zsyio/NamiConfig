-- Comment.nvim: gcc to toggle comment, gc in visual mode
return {
  {
    "numToStr/Comment.nvim",
    event  = { "BufReadPost", "BufNewFile" },
    config = function()
      require("Comment").setup({
        padding = true,
        sticky  = true,
        toggler = {
          line  = "gcc",
          block = "gbc",
        },
        opleader = {
          line  = "gc",
          block = "gb",
        },
        mappings = {
          basic    = true,
          extra    = true,
        },
        pre_hook = function(ctx)
          -- Support for tsx/jsx comment contexts via treesitter
          local ok, ts_ctx = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
          if ok then return ts_ctx.create_pre_hook()(ctx) end
        end,
      })
    end,
    dependencies = {
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        lazy = true,
      },
    },
  },
}
