-- Editor utilities: auto-save, hyprland syntax, Python venv selector
return {
  -- Auto Save
  {
    "okuuva/auto-save.nvim",
    cmd   = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    opts  = function()
      local ok, settings = pcall(require, "settings")
      local s = ok and settings or {}
      return {
        enabled      = s.auto_save == true,
        trigger_events = {
          immediate_save    = { "BufLeave", "FocusLost" },
          defer_save        = { "InsertLeave", "TextChanged" },
          cancel_deferred_save = { "InsertEnter" },
        },
      condition          = nil,
      write_all_buffers  = false,
      noautocmd          = false,
      lockmarks          = false,
      debounce_delay     = 1000,
      debug              = false,
      }
    end,
  },



  -- Hyprland Syntax Highlighting
  {
    "theRealCarneiro/hyprland-vim-syntax",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = "hypr",
  },
}
