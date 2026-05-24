-- ToggleTerm: floating terminal (A-i) and horizontal (A-h)
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<A-i>", desc = "Toggle floating terminal" },
      { "<A-h>", desc = "Toggle horizontal terminal" },
      { "<A-v>", desc = "Toggle vertical terminal" },
    },
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping     = nil,   -- we define manual bindings below
        hide_numbers     = true,
        shade_filetypes  = {},
        autochdir        = false,
        shade_terminals  = false,
        start_in_insert  = true,
        insert_mappings  = true,
        terminal_mappings = true,
        persist_size     = true,
        persist_mode     = true,
        direction        = "float",
        close_on_exit    = true,
        shell            = vim.o.shell,
        auto_scroll      = true,
        float_opts = {
          border        = "curved",    -- 'single'|'double'|'shadow'|'curved'
          winblend      = 0,
          width         = function() return math.floor(vim.o.columns * 0.85) end,
          height        = function() return math.floor(vim.o.lines * 0.80) end,
          highlights    = {
            border      = "FloatBorder",
            background  = "NormalFloat",
          },
        },
        winbar = {
          enabled      = false,
          name_formatter = function(term) return term.name end,
        },
      })

      -- Highlight the float border with catppuccin lavender
      vim.api.nvim_set_hl(0, "ToggleTermFloatBorder", { fg = "#b4befe", bg = "NONE" })
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.api.nvim_set_hl(0, "ToggleTermFloatBorder", { fg = "#b4befe", bg = "NONE" })
        end,
      })

      -- Key mappings
      local map = vim.keymap.set

      -- Floating terminal  <A-i>
      local float_term = require("toggleterm.terminal").Terminal:new({
        direction = "float",
        float_opts = { border = "curved" },
        on_open = function(t)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(t.bufnr, "n", "q",    "<cmd>close<CR>", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(t.bufnr, "t", "<A-i>","<cmd>close<CR>", { noremap = true, silent = true })
        end,
      })
      map({ "n", "t" }, "<A-i>", function() float_term:toggle() end, { desc = "Toggle floating terminal" })

      -- Horizontal terminal  <A-h>
      local h_term = require("toggleterm.terminal").Terminal:new({
        direction = "horizontal",
        on_open = function(t)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(t.bufnr, "t", "<A-h>","<cmd>close<CR>", { noremap = true, silent = true })
        end,
      })
      map({ "n", "t" }, "<A-h>", function() h_term:toggle() end, { desc = "Toggle horizontal terminal" })

      -- Vertical terminal  <A-v>
      local v_term = require("toggleterm.terminal").Terminal:new({
        direction = "vertical",
        on_open = function(t)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(t.bufnr, "t", "<A-v>","<cmd>close<CR>", { noremap = true, silent = true })
        end,
      })
      map({ "n", "t" }, "<A-v>", function() v_term:toggle() end, { desc = "Toggle vertical terminal" })

      -- <Esc><Esc> to exit terminal insert mode
      map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
    end,
  },
}
