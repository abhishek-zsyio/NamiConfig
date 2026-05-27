return {
  "mistweaverco/kulala.nvim",
  ft = "http",
  keys = {
    { "<leader>R", "<cmd>lua require('kulala').run()<cr>", desc = "Run HTTP Request" },
    { "<leader>Rt", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "Toggle Headers/Body" },
    { "<leader>Rc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy HTTP Request as cURL" },
  },
  opts = {},
}
