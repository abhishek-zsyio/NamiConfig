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
    config = function(_, opts)
      require("leetcode").setup(opts)
      
      -- Defer the loading and monkey-patching of the interpreter until setup has fully completed
      vim.schedule(function()
        local interpreter = require("leetcode.api.interpreter")
        local original_handle_item = interpreter.handle_item
        
        interpreter.handle_item = function(self, item)
          local res = original_handle_item(self, item)
          
          if res and res.status_msg then
            -- Robust fallback detection
            local is_submit = false
            if res._ and res._.submission ~= nil then
              is_submit = res._.submission
            elseif res.submission_id then
              is_submit = not res.submission_id:find("runcode") and true or false
            end
            
            local is_success = false
            if res._ and res._.success ~= nil then
              is_success = res._.success
            else
              is_success = (res.status_msg == "Accepted") or (res.status_code == 10 and res.compare_result and res.compare_result:match("^[1]+$") ~= nil)
            end
            
            local msg = ""
            local level = vim.log.levels.INFO
            
            if is_success then
              msg = is_submit and "🎉 LeetCode Submission ACCEPTED!" or "✅ LeetCode Test Passed!"
              level = vim.log.levels.INFO
            else
              msg = is_submit and ("❌ LeetCode Submission FAILED: %s"):format(res.status_msg) or ("⚠️ LeetCode Test Failed: %s"):format(res.status_msg)
              level = vim.log.levels.WARN
            end
            
            if res.total_correct and res.total_testcases then
              msg = msg .. (" (%s/%s cases)"):format(res.total_correct, res.total_testcases)
            end
            
            vim.schedule(function()
              vim.notify(msg, level, { title = is_submit and "LeetCode Submit" or "LeetCode Test" })
            end)
          end
          
          return res
        end
      end)
    end,
  },
}
