-- mini.comment: Neovim 0.12-compatible commenting plugin
-- Replaces Comment.nvim (which has a nil error on Neovim 0.12)
return {
  {
    "echasnovski/mini.comment",
    version = false,
    event   = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        lazy = true,
        opts = { enable_autocmd = false },
      },
    },
    opts = {
      options = {
        -- Use ts-context-commentstring for JSX/TSX/Vue context-aware comments
        -- Note: calculate_commentstring() is on the main module, not the comment_nvim submodule
        custom_commentstring = function()
          local ok, ts_cs = pcall(require, "ts_context_commentstring")
          if ok and ts_cs and ts_cs.calculate_commentstring then
            local cs = ts_cs.calculate_commentstring()
            if cs and cs ~= "" then return cs end
          end
          return vim.bo.commentstring
        end,
      },
    },
    config = function(_, opts)
      require("mini.comment").setup(opts)

      -- <leader>/ → comment current line (normal mode)
      vim.keymap.set("n", "<leader>/", "gcc", {
        remap   = true,
        silent  = true,
        desc    = "Toggle comment",
      })

      -- <leader>/ → comment selection (visual mode)
      vim.keymap.set("x", "<leader>/", "gc", {
        remap   = true,
        silent  = true,
        desc    = "Toggle comment",
      })
    end,
  },
}
