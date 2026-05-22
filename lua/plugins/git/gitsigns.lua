-- Gitsigns: inline git diff indicators (NvChad has this built-in)
return {
  {
    "lewis6991/gitsigns.nvim",
    event  = { "BufReadPost", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "│" },
          change       = { text = "│" },
          delete       = { text = "" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
          untracked    = { text = "┆" },
        },
        signs_staged = {
          add          = { text = "│" },
          change       = { text = "│" },
          delete       = { text = "" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
          untracked    = { text = "┆" },
        },
        signcolumn         = true,
        numhl              = false,
        linehl             = false,
        word_diff          = false,
        watch_gitdir       = { follow_files = true },
        auto_attach        = true,
        attach_to_untracked = false,
        current_line_blame  = false,
        current_line_blame_opts = {
          virt_text         = true,
          virt_text_pos     = "eol",
          delay             = 1000,
          ignore_whitespace = false,
        },
        preview_config = {
          border   = "rounded",
          style    = "minimal",
          relative = "cursor",
          row      = 0,
          col      = 1,
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          -- Navigation
          map("n", "]h", gs.next_hunk, { desc = "Next hunk" })
          map("n", "[h", gs.prev_hunk, { desc = "Prev hunk" })
          -- Actions
          map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
          map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
          map("n", "<leader>hb", gs.blame_line,  { desc = "Blame line" })
          map("n", "<leader>hd", gs.diffthis,    { desc = "Diff this" })
          map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
        end,
      })
    end,
  },

  -- Git blame virtual text (inline, end of line)
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts  = {
      enabled                = true,
      message_template       = " <summary> • <date> • <author> ",
      date_format            = "%m-%d-%Y",
      virtual_text_column    = 1,
    },
  },
}
