-- nvim-lint: asynchronous linting — driven by lua/core/lang_registry.lua
-- Toggle linting on/off via settings.lua → enable_linting = true/false
return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local ok, settings = pcall(require, "settings")
      if not ok then settings = {} end

      -- Respect the global toggle
      if settings.enable_linting == false then return end

      local lint     = require("lint")
      local registry = require("nami.lang")

      -- ── Prepend Mason's bin dir to PATH ────────────────────────────────────
      -- Mason installs linter binaries to a non-system path.
      -- nvim-lint shells out using $PATH, so we inject Mason's bin
      -- directory at the front so executables like ruff, eslint_d,
      -- shellcheck, markdownlint-cli, etc. are always found.
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
      if not vim.env.PATH:find(mason_bin, 1, true) then
        vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
      end

      -- ── Wire linters_by_ft from the centralized registry ─────────────────
      lint.linters_by_ft = registry.linters_by_ft()

      -- ── Guard: skip linters whose binary isn't installed yet ─────────────
      -- This silences ENOENT errors during the first-run Mason install phase.
      local function safe_lint()
        local ft = vim.bo.filetype
        local linters = lint.linters_by_ft[ft] or {}
        local available = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then return false end
          -- cmd can be a function or a string
          local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
          return vim.fn.executable(cmd) == 1
        end, linters)

        if #available > 0 then
          lint.try_lint(available)
        end
      end

      -- ── Auto-lint on relevant events ─────────────────────────────────────
      local lint_augroup = vim.api.nvim_create_augroup("NvimLint", { clear = true })

      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        group    = lint_augroup,
        callback = function()
          -- Don't lint special buffers (oil, lazy, noice, etc.)
          if vim.bo.buftype ~= "" then return end
          safe_lint()
        end,
      })

      -- ── Manual lint keymap ────────────────────────────────────────────────
      vim.keymap.set("n", "<leader>cl", function()
        safe_lint()
        vim.notify("Linting " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
      end, { desc = "Lint current file" })

      -- ── Toggle linting per-session ────────────────────────────────────────
      local linting_enabled = true
      vim.keymap.set("n", "<leader>tl", function()
        linting_enabled = not linting_enabled
        if linting_enabled then
          vim.api.nvim_clear_autocmds({ group = lint_augroup })
          vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
            group    = lint_augroup,
            callback = function()
              if vim.bo.buftype == "" then safe_lint() end
            end,
          })
          vim.notify("Linting enabled", vim.log.levels.INFO)
        else
          vim.api.nvim_clear_autocmds({ group = lint_augroup })
          vim.notify("Linting disabled", vim.log.levels.WARN)
        end
      end, { desc = "Toggle linting" })
    end,
  },
}
