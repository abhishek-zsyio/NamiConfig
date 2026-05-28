-- Conform.nvim: formatting — driven by lua/core/lang_registry.lua
return {
  {
    "stevearc/conform.nvim",
    event  = { "BufWritePre" },
    cmd    = { "ConformInfo" },
    config = function()
      local registry = require("nami.lang")
      local ok, settings = pcall(require, "settings")
      if not ok then settings = {} end

      require("conform").setup({
        -- Formatters per filetype come from the centralized registry.
        -- To add a formatter for a new language, add it to lang_registry.lua
        formatters_by_ft = registry.formatters_by_ft(),

        format_on_save = settings.format_on_save and {
          timeout_ms   = 2000,
          lsp_format   = "fallback",
        } or nil,

        -- ── Custom Formatter Instructions ────────────────────────────────────
        formatters = {
          prettier = {
            -- Custom styling for JS, TS, React, Vue, CSS, etc.
            -- Change these arguments to match your preferred code style!
            prepend_args = { 
              "--single-quote", 
              "--jsx-single-quote", 
              "--tab-width", tostring(settings.tab_size or 2), 
              "--trailing-comma", "es5",
              "--print-width", "80"
            },
          },
        },
      })

      -- Manual format keymap (works regardless of format_on_save setting)
      vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        require("conform").format({ async = true, lsp_format = "fallback" }, function(err, did_edit)
          if err then
            Snacks.notifier.error("Formatting failed: " .. tostring(err), { title = "Conform" })
          elseif did_edit then
            Snacks.notifier.info("Formatted " .. vim.fn.expand("%:t"), { title = "Conform" })
          else
            Snacks.notifier.info("No changes needed", { title = "Conform" })
          end
        end)
      end, { desc = "Format buffer (Conform)" })
    end,
  },
}
