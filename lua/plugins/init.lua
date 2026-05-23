return {
  -- UI
  { import = "plugins.ui.theme" },
  { import = "plugins.ui.statusline" },
  { import = "plugins.ui.bufferline" },
  { import = "plugins.ui.filetree" },
  { import = "plugins.ui.telescope" },
  { import = "plugins.ui.noice" },
  { import = "plugins.ui.terminal" },
  { import = "plugins.ui.misc" },
  { import = "plugins.ui.alpha" },
  -- Editor
  { import = "plugins.editor.treesitter" },
  { import = "plugins.editor.cmp" },
  { import = "plugins.editor.autopairs" },
  { import = "plugins.editor.comment" },
  { import = "plugins.editor.indent" },
  { import = "plugins.editor.utils" },
  { import = "plugins.editor.neoconf" },   -- project-local LSP config
  -- Git
  { import = "plugins.git.gitsigns" },
  { import = "plugins.git.lazygit" },
  { import = "plugins.git.diffview" },
  -- AI
  { import = "plugins.ai.supermaven" },
  -- LSP
  { import = "plugins.lsp.mason" },
  { import = "plugins.lsp.lspconfig" },
  { import = "plugins.lsp.dap" },
  -- Formatting
  { import = "plugins.formatting.conform" },
  -- Linting (async, registry-driven)
  { import = "plugins.linting.lint" },
  -- Lang
  { import = "plugins.lang.django" },
}
