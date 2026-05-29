-- Auto pairs for brackets, quotes etc.
return {
  {
    "windwp/nvim-autopairs",
    event  = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")

      autopairs.setup({
        check_ts = true, -- use treesitter
        ts_config = {
          lua  = { "string" },
          javascript = { "template_string" },
        },
        fast_wrap = {
          map      = "<M-e>",
          chars    = { "{", "[", "(", '"', "'" },
          pattern  = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
          offset   = 0,
          keys     = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma  = true,
          highlight    = "PmenuSel",
          highlight_grey = "LineNr",
        },
      })

      -- Integrate with cmp so pairs are added on confirm
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Bulletproof HTML/JSX/TSX auto-closing
  {
    "alvan/vim-closetag",
    event = "InsertEnter",
    init = function()
      vim.g.closetag_filenames = "*.html,*.xhtml,*.phtml,*.js,*.jsx,*.ts,*.tsx,*.vue"
      vim.g.closetag_emptyTags_caseSensitive = 1
      vim.g.closetag_regions = {
        ["typescript.tsx"] = "jsxRegion,tsxRegion",
        ["javascript.jsx"] = "jsxRegion",
      }
      vim.g.closetag_shortcut = ">"
    end
  },

  -- Auto rename tags (and auto close) using treesitter
  {
    "windwp/nvim-ts-autotag",
    event = { "InsertEnter" },
    opts = {
      opts = {
        enable_close = true,           -- Auto close tags
        enable_rename = true,          -- Auto rename pairs of tags
        enable_close_on_slash = false  -- Auto close on trailing </
      },
    }
  },
}
