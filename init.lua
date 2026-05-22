-- Suppress deprecation warnings (lspconfig v2 → v3 transition)
vim.deprecate = function() end

-- Leader keys must be set BEFORE lazy loads plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core options immediately
require("core.options")

-- ── Bootstrap lazy.nvim ─────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugin setup ────────────────────────────────────────────────────────────
require("lazy").setup({
  { import = "plugins" },
}, {
  defaults = { lazy = true },
  install  = { colorscheme = { "catppuccin" } },
  ui = {
    icons = {
      ft        = "",
      lazy      = "󰂠 ",
      loaded    = "",
      not_loaded = "",
    },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin", "tohtml", "getscript", "getscriptPlugin",
        "gzip", "logipat", "netrw", "netrwPlugin", "netrwSettings",
        "netrwFileHandlers", "matchit", "tar", "tarPlugin",
        "rrhelper", "spellfile_plugin", "vimball", "vimballPlugin",
        "zip", "zipPlugin", "tutor", "rplugin", "syntax",
        "synmenu", "optwin", "compiler", "bugreport", "ftplugin",
      },
    },
  },
})

-- ── Load keymaps & autocmds after plugins ────────────────────────────────────
vim.schedule(function()
  require("core.keymaps")
  require("core.autocmds")
end)
