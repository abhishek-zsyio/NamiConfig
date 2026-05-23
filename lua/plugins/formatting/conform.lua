-- Conform.nvim: formatting — driven by lua/core/lang_registry.lua
return {
  {
    "stevearc/conform.nvim",
    event  = { "BufWritePre" },
    cmd    = { "ConformInfo" },
    config = function()
      local registry = require("core.lang_registry")
      local ok, settings = pcall(require, "settings")
      if not ok then settings = {} end

      require("conform").setup({
        -- Formatters per filetype come from the centralized registry.
        -- To add a formatter for a new language, add it to lang_registry.lua
        formatters_by_ft = registry.formatters_by_ft(),

        format_on_save = settings.format_on_save and {
          timeout_ms   = 500,
          lsp_format   = "fallback",
        } or nil,
      })

      -- Manual format keymap (works regardless of format_on_save setting)
      vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end, { desc = "Format buffer (Conform)" })
    end,
  },
}
