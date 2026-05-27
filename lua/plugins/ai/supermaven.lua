return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter",
  keys = {
    {
      "<leader>tm",
      function()
        local api = require("supermaven-nvim.api")
        if api.is_running() then
          vim.cmd("SupermavenStop")
          vim.notify("Supermaven disabled", vim.log.levels.WARN, { title = "Supermaven" })
        else
          vim.cmd("SupermavenStart")
          vim.notify("Supermaven enabled", vim.log.levels.INFO, { title = "Supermaven" })
        end
      end,
      desc = "Toggle Supermaven",
    },
  },
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-f>",
      },
    })
  end,
}
