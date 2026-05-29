return {
  "okuuva/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" }, -- lazy load on these events
  opts = {
    enabled = true, -- start auto-save when the plugin is loaded
    trigger_events = { -- See :h events
      immediate_save = { "BufLeave", "FocusLost" }, -- vim events that trigger an immediate save
      defer_save = { "InsertLeave", "TextChanged" }, -- vim events that trigger a deferred save (saves after `debounce_delay`)
      cancel_deferred_save = { "InsertEnter" }, -- 'cancel_defered_save' was fixed to 'cancel_deferred_save' in the plugin
    },
    condition = function(buf)
      local fn = vim.fn
      local utils = require("auto-save.utils.data")
      
      -- Do not save if buffer is not modifiable or if it's a special filetype like neo-tree, etc.
      if fn.getbufvar(buf, "&modifiable") == 1 and
        utils.not_in(fn.getbufvar(buf, "&filetype"), { "snacks_picker_list", "snacks_picker_input" }) then
        return true
      end
      return false
    end,
    write_all_buffers = false, -- write to all buffers when triggering auto save
    debounce_delay = 1000, -- saves 1 second after you stop typing
  },
}
