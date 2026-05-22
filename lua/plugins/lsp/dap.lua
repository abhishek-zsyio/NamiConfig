-- DAP: Debug Adapter Protocol for Python (and extensible)
return {
  { "mfussenegger/nvim-dap",  lazy = true },
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
