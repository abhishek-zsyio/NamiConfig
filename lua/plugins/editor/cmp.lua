-- nvim-cmp: autocomplete (NvChad-style with lspkind icons)
return {
  {
    "hrsh7th/nvim-cmp",
    event        = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      {
        "L3MON4D3/LuaSnip",
        version      = "v2.*",
        build        = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config       = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = "menu,menuone" },
        window = {
          completion = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            local has_supermaven, supermaven = pcall(require, "supermaven-nvim.completion_preview")
            if has_supermaven and supermaven.has_suggestion() then
              supermaven.on_accept_suggestion()
            elseif cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "lazydev", group_index = 0 }, -- Skip loading LuaLS completions
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "nvim_lua", priority = 500 },
        }, {
          { name = "buffer", priority = 250 },
          { name = "path",   priority = 100 },
        }),
        formatting = {
          fields = { "abbr", "kind" },
          format = function(entry, vim_item)
            -- 1. Use manual Nerd Font icons for guaranteed stability
            local icons = {
              Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "",
              Field = "󰜢", Variable = "󰀫", Class = "󰠱", Interface = "",
              Module = "", Property = "󰜢", Unit = "󰑭", Value = "󰎠",
              Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
              File = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "",
              Constant = "󰏿", Struct = "󰙅", Event = "", Operator = "󰆕",
              TypeParameter = "󰊄", Supermaven = "",
            }
            local icon = icons[vim_item.kind] or "󰍪"
            vim_item.kind = string.format("%s %s", icon, vim_item.kind)

            -- 2. Clean up the menu text (removes [LSP] etc)
            vim_item.menu = ""

            -- 3. Apply color squares from nvim-highlight-colors if it's a color!
            local colors_ok, highlight_colors = pcall(require, "nvim-highlight-colors")
            if colors_ok then
              -- Pass a dummy item to not mess up our string
              local color_item = highlight_colors.format(entry, { kind = vim_item.kind })
              if color_item and color_item.abbr_hl_group then
                vim_item.kind_hl_group = color_item.abbr_hl_group
                vim_item.kind = color_item.abbr .. " Color"
              end
            end

            return vim_item
          end,
        },
      })
    end,
  },
}
