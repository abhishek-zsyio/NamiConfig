-- Extra: neotest — unified test runner
-- Enable in settings.lua → extras = { "plugins.extras.testing.neotest" }
--
-- Adapters: neotest-python (pytest), neotest-jest, neotest-vitest
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Language adapters
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    event = { "BufReadPost" },
    keys  = {
      -- Run
      { "<leader>Tr", function() require("neotest").run.run() end,                          desc = "Test: Run nearest" },
      { "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end,        desc = "Test: Run file" },
      { "<leader>Ta", function() require("neotest").run.run(vim.loop.cwd()) end,            desc = "Test: Run all (suite)" },
      -- Debug
      { "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end,      desc = "Test: Debug nearest" },
      -- Stop
      { "<leader>Ts", function() require("neotest").run.stop() end,                         desc = "Test: Stop" },
      -- Output / Summary
      { "<leader>To", function() require("neotest").output.open({ enter = true }) end,      desc = "Test: Open output" },
      { "<leader>TS", function() require("neotest").summary.toggle() end,                   desc = "Test: Toggle summary" },
      -- Watch
      { "<leader>Tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end,   desc = "Test: Watch file" },
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap    = { justMyCode = false },
            runner = "pytest",
            python = function()
              -- Use venv python if available
              local venv = os.getenv("VIRTUAL_ENV")
              if venv then
                return venv .. "/bin/python"
              end
              return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
            end,
          }),

          require("neotest-jest")({
            jestCommand      = "npm test --",
            jestConfigFile   = "jest.config.js",
            env              = { CI = "true" },
            cwd              = function() return vim.fn.getcwd() end,
          }),

          require("neotest-vitest")({
            filter_dir = function(name)
              return name ~= "node_modules"
            end,
          }),
        },

        -- Output window config
        output = {
          enabled       = true,
          open_on_run   = "short",
        },

        -- Status icons in signcolumn
        icons = {
          failed   = " ",
          passed   = " ",
          running  = "󰑮 ",
          skipped  = " ",
          unknown  = " ",
          watching = "󰂶 ",
        },

        -- Floating diagnostics window
        floating = { border = "rounded", max_height = 0.6, max_width = 0.7 },

        summary = {
          enabled        = true,
          animated       = true,
          follow         = true,
          expand_errors  = true,
        },
      })
    end,
  },
}
