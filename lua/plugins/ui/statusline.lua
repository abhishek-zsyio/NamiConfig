-- plugins/ui/statusline.lua
-- Theme-aware lualine — flat design, zero mixed separators, uniform padding.
return {
  {
    "nvim-lualine/lualine.nvim",
    event        = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()

      -- ── Highlight helpers ─────────────────────────────────────────────────
      local function get_hl(name)
        local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        return ok and h or {}
      end
      local function hex(name, attr)
        local v = get_hl(name)[attr]
        return v and ("#%06x"):format(v) or nil
      end

      -- ── Theme builder ─────────────────────────────────────────────────────
      -- All sections share the same bg so the bar is one flat strip.
      -- Only the mode pill (lualine_a) gets an accent colour.
      local function build_theme()
        local bg      = hex("Normal",     "bg") or "#1e1e2e"
        local fg      = hex("Normal",     "fg") or "#cdd6f4"
        local fg_dim  = hex("Comment",    "fg") or "#6c7086"
        local bg_pill = hex("CursorLine", "bg") or "#313244"

        local accent = {
          normal  = hex("Function",  "fg") or "#89b4fa",
          insert  = hex("String",    "fg") or "#a6e3a1",
          visual  = hex("Keyword",   "fg") or "#cba6f7",
          replace = hex("ErrorMsg",  "fg") or "#f38ba8",
          command = hex("WarningMsg","fg") or "#f9e2af",
          term    = hex("Special",   "fg") or "#94e2d5",
        }

        local function pill(color)
          return { bg = color, fg = bg, gui = "bold" }
        end
        local flat     = { bg = bg, fg = fg_dim }
        local flat_fg  = { bg = bg, fg = fg }
        local elevated = { bg = bg_pill, fg = fg }

        return {
          normal   = { a = pill(accent.normal),  b = elevated, c = flat, x = flat, y = flat_fg, z = flat_fg },
          insert   = { a = pill(accent.insert),  b = elevated, c = flat, x = flat, y = flat_fg, z = flat_fg },
          visual   = { a = pill(accent.visual),  b = elevated, c = flat, x = flat, y = flat_fg, z = flat_fg },
          replace  = { a = pill(accent.replace), b = elevated, c = flat, x = flat, y = flat_fg, z = flat_fg },
          command  = { a = pill(accent.command), b = elevated, c = flat, x = flat, y = flat_fg, z = flat_fg },
          terminal = { a = pill(accent.term),    b = elevated, c = flat, x = flat, y = flat_fg, z = flat_fg },
          inactive = {
            a = { bg = bg, fg = fg_dim },
            b = { bg = bg, fg = fg_dim },
            c = { bg = bg, fg = fg_dim },
          },
        }
      end

      -- ── Components ────────────────────────────────────────────────────────

      local MODE = {
        n   = { icon = "󰋜 ", label = "NORMAL"  },
        i   = { icon = "󰏫 ", label = "INSERT"  },
        v   = { icon = "󰒉 ", label = "VISUAL"  },
        V   = { icon = "󰒉 ", label = "V-LINE"  },
        ["\22"] = { icon = "󰒉 ", label = "V-BLOCK" },
        c   = { icon = "󰞷 ", label = "COMMAND" },
        R   = { icon = "󰛔 ", label = "REPLACE" },
        t   = { icon = "󰆍 ", label = "TERM"    },
        s   = { icon = "󰒉 ", label = "SELECT"  },
        S   = { icon = "󰒉 ", label = "S-LINE"  },
        no  = { icon = "󰋜 ", label = "PENDING" },
      }
      local function mode_comp()
        local m     = vim.api.nvim_get_mode().mode
        local entry = MODE[m] or { icon = "  ", label = m:upper() }
        if vim.o.columns < 80 then
          return entry.icon:gsub("%s+$", "")
        end
        return entry.icon .. entry.label
      end

      local function filename_comp()
        local buf  = vim.api.nvim_get_current_buf()
        local name = vim.api.nvim_buf_get_name(buf)

        if name == "" then return "󰈤  [No Name]" end

        local icon = ""
        local ok, devicons = pcall(require, "nvim-web-devicons")
        if ok then
          local ic = devicons.get_icon(vim.fn.fnamemodify(name, ":t"),
                                        vim.fn.fnamemodify(name, ":e"),
                                        { default = true })
          icon = (ic or "󰈤") .. "  "
        end

        local rel   = vim.fn.fnamemodify(name, ":~:.")
        local parts = vim.split(rel, "/", { plain = true })
        if #parts > 3 then
          rel = "\u{2026}/" .. parts[#parts - 1] .. "/" .. parts[#parts]
        end

        local flags = ""
        if vim.bo[buf].modified then flags = "  \u{25cf}" end
        if vim.bo[buf].readonly then flags = flags .. "  \u{f023}" end

        return icon .. rel .. flags
      end

      local function search_count()
        if vim.v.hlsearch == 0 then return "" end
        local ok, r = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 50 })
        if not ok or (r.total or 0) == 0 then return "" end
        local total = r.incomplete == 1 and "?" or tostring(r.total)
        return ("\u{f04b4}  %d/%s"):format(r.current, total)
      end

      local function macro_rec()
        local r = vim.fn.reg_recording()
        if r == "" then return "" end
        return "\u{f044a}  @" .. r
      end

      local function lsp_comp()
        local names, seen = {}, {}
        for _, cl in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          if cl.name ~= "null-ls" and cl.name ~= "copilot" and not seen[cl.name] then
            seen[cl.name] = true
            table.insert(names, cl.name)
          end
        end
        local ok_c, conform = pcall(require, "conform")
        if ok_c then
          for _, f in ipairs(conform.list_formatters_for_buffer(0) or {}) do
            if not seen[f] then seen[f] = true; table.insert(names, f) end
          end
        end
        local ok_l, lint = pcall(require, "lint")
        if ok_l then
          for _, l in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
            if not seen[l] then seen[l] = true; table.insert(names, l) end
          end
        end
        if #names == 0 then return "" end
        if #names > 2 then
          return "\u{f0e8}  " .. names[1] .. " +" .. (#names - 1)
        end
        return "\u{f0e8}  " .. table.concat(names, "  ")
      end

      local function supermaven_comp()
        local ok, api = pcall(require, "supermaven-nvim.api")
        if not ok or not api.is_running() then return "" end
        return "\u{f06e8}  SM"
      end

      local PROSE = { markdown = true, text = true, org = true, norg = true }
      local function word_count()
        if not PROSE[vim.bo.filetype] then return "" end
        return "\u{f0248}  " .. vim.fn.wordcount().words .. "w"
      end

      local function indent_comp()
        if vim.bo.expandtab then
          local sw = vim.bo.shiftwidth
          return sw ~= 2 and ("\u{eb62}  " .. sw) or ""
        end
        return "\u{eb63}  tab"
      end

      local function noice_cmd()
        if not package.loaded["noice"] then return "" end
        local noice = require("noice")
        return noice.api.status.mode.has() and noice.api.status.mode.get() or ""
      end

      -- ── Setup ────────────────────────────────────────────────────────────
      require("lualine").setup({
        options = {
          theme  = build_theme(),
          globalstatus = true,
          section_separators   = { left = "",         right = ""         },
          component_separators = { left = "\u{2502}", right = "\u{2502}" },
          refresh            = { statusline = 500 },
          disabled_filetypes = {
            statusline = { "dashboard", "alpha", "snacks_dashboard", "lazy", "mason" },
          },
        },

        sections = {
          lualine_a = {
            { mode_comp, padding = { left = 2, right = 2 } },
          },

          lualine_b = {
            {
              "branch",
              icon = "\u{e725} ",
              padding = { left = 2, right = 1 },
              fmt = function(name)
                if name == "" then return "" end
                return #name > 24 and (name:sub(1, 22) .. "\u{2026}") or name
              end,
            },
            {
              "diff",
              symbols = {
                added    = "\u{f0417}  ",
                modified = "\u{f0419}  ",
                removed  = "\u{f0418}  ",
              },
              padding = { left = 1, right = 2 },
            },
          },

          lualine_c = {
            { filename_comp, padding = { left = 2, right = 2 } },
            {
              "diagnostics",
              sources = { "nvim_lsp" },
              symbols = {
                error = "\u{f0028}  ",
                warn  = "\u{f0026}  ",
                hint  = "\u{f0335}  ",
                info  = "\u{f0625}  ",
              },
              padding = { left = 1, right = 1 },
            },
            {
              search_count,
              cond    = function() return vim.v.hlsearch == 1 end,
              padding = { left = 1, right = 1 },
            },
            {
              macro_rec,
              cond  = function() return vim.fn.reg_recording() ~= "" end,
              color = function()
                local bg = hex("Normal", "bg") or "#1e1e2e"
                return { bg = bg, fg = "#f38ba8", gui = "bold" }
              end,
              padding = { left = 1, right = 1 },
            },
            {
              noice_cmd,
              cond = function()
                return package.loaded["noice"]
                  and require("noice").api.status.mode.has()
              end,
              padding = { left = 1, right = 1 },
            },
          },

          lualine_x = {
            {
              supermaven_comp,
              cond    = function()
                local ok, api = pcall(require, "supermaven-nvim.api")
                return ok and api.is_running()
              end,
              padding = { left = 1, right = 1 },
            },
            {
              word_count,
              cond    = function() return PROSE[vim.bo.filetype] == true end,
              padding = { left = 1, right = 1 },
            },
            {
              lsp_comp,
              cond    = function() return lsp_comp() ~= "" end,
              padding = { left = 1, right = 1 },
            },
            {
              indent_comp,
              cond    = function() return indent_comp() ~= "" end,
              padding = { left = 1, right = 1 },
            },
            {
              "encoding",
              cond = function()
                return vim.bo.fileencoding ~= ""
                  and vim.bo.fileencoding ~= "utf-8"
              end,
              padding = { left = 1, right = 1 },
            },
            { "filetype", padding = { left = 1, right = 2 } },
          },

          lualine_y = {
            {
              "location",
              fmt = function(str)
                local l, col = str:match("%s*(%d+):%s*(%d+)")
                return l and ("\u{f0311}  %s : %s"):format(l, col) or str
              end,
              padding = { left = 2, right = 1 },
            },
          },

          lualine_z = {
            {
              "progress",
              fmt = function(s)
                if s == "Top" then return "\u{f062}  TOP" end
                if s == "Bot" then return "\u{f063}  BOT" end
                return "\u{f0295}  " .. s
              end,
              padding = { left = 1, right = 2 },
            },
          },
        },

        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              "filename",
              path    = 1,
              symbols = {
                modified = "  \u{25cf}",
                readonly = "  \u{f023}",
                unnamed  = "[No Name]",
              },
              padding = { left = 2, right = 1 },
            },
          },
          lualine_x = {
            { "location", padding = { left = 1, right = 2 } },
          },
          lualine_y = {},
          lualine_z = {},
        },

        extensions = {
          "lazy", "mason", "neo-tree", "quickfix", "trouble", "fugitive",
        },
      })

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern  = "*",
        callback = function()
          local ok, lualine = pcall(require, "lualine")
          if not ok then return end
          vim.defer_fn(function()
            lualine.setup({ options = { theme = build_theme() } })
          end, 10)
        end,
      })
    end,
  },
}