-- LeetCode Native Integration
return {
  {
    "kawre/leetcode.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Leet",
    keys = {
      { "<leader>lc", "<cmd>Leet<CR>", desc = "Open LeetCode Dashboard" },
      { "<leader>lr", "<cmd>Leet run<CR>", desc = "LeetCode Run Test" },
      { "<leader>ls", "<cmd>Leet submit<CR>", desc = "LeetCode Submit Solution" },
      { "<leader>ld", "<cmd>Leet desc<CR>", desc = "LeetCode Show Description" },
      { "<leader>li", "<cmd>Leet info<CR>", desc = "LeetCode Question Info" },
    },
    opts = {
      lang = require("settings").leetcode_lang or "python3",
      cn = { -- Use local endpoint if applicable, defaults to global
        enabled = false,
      },
      storage = {
        home = vim.fn.stdpath("data") .. "/leetcode",
      },
      logging = true,
      injector = {},
      cache = {
        update_interval = 24 * 60 * 60, -- 24 hours
      },
    },
  },
}
