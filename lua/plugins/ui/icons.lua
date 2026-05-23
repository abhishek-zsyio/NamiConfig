return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    dependencies = { "Allianaab2m/nvim-material-icon-v3" },
    config = function()
      require("nvim-web-devicons").setup({
        override = require("nvim-material-icon").get_icons(),
      })
    end,
  }
}
