-- Django/Jinja template support
return {
  {
    "lepture/vim-jinja",
    ft = { "htmldjango", "html" },
  },
  {
    "tweekmonster/django-plus.vim",
    ft   = { "htmldjango", "python" },
    cond = function()
      return vim.fn.filereadable(vim.fn.getcwd() .. "/manage.py") == 1
    end,
  },
}
