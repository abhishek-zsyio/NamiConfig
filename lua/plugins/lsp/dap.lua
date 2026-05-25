-- DAP: Debug Adapter Protocol for Python (and extensible)
return {
  { 
    "mfussenegger/nvim-dap",  
    lazy = true,
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<CR>", desc = "DAP Toggle breakpoint" },
      { "<leader>dc", "<cmd>DapContinue<CR>", desc = "DAP Continue" },
      { "<leader>dso", "<cmd>DapStepOver<CR>", desc = "DAP Step over" },
      { "<leader>dsi", "<cmd>DapStepIn<CR>", desc = "DAP Step in" },
      { "<leader>dt", "<cmd>DapTerminate<CR>", desc = "DAP Terminate" },
    },
  },
  { "nvim-neotest/nvim-nio",  lazy = true },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config       = function()
      local dap    = require("dap")
      local dapui  = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
    end,
  },

  {
    "mfussenegger/nvim-dap-python",
    ft           = "python",
    dependencies = { "mfussenegger/nvim-dap", "rcarriga/nvim-dap-ui" },
    config       = function()
      require("dap-python").setup(
        "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      )
    end,
  },
}
