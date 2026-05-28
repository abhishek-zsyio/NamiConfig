-- lualine.lua — Polished Statusline (Auto Theme)
return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local MODE_LABELS = {
        n  = "NORMAL",  i  = "INSERT",   v  = "VISUAL",
        V  = "V-LINE",  c  = "COMMAND",  R  = "REPLACE",
        t  = "TERM",    s  = "SELECT",   S  = "S-LINE",
        no = "PENDING", [""] = "V-BLOCK",
      }
      local function mode_label()
        local m = vim.api.nvim_get_mode().mode
        local label = MODE_LABELS[m] or m:upper()
        return vim.o.columns < 80 and label:sub(1, 1) or label
      end

      local function lsp_clients()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        local names = {}
        for _, cl in ipairs(clients) do
          if cl.name ~= "null-ls" and cl.name ~= "copilot" then
            table.insert(names, cl.name)
          end
        end
        local ok_c, conform = pcall(require, "conform")
        if ok_c then
          for _, f in ipairs(conform.list_formatters_for_buffer(0) or {}) do
            table.insert(names, f)
          end
        end
        local ok_l, lint = pcall(require, "lint")
        if ok_l then
          for _, l in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
            table.insert(names, l)
          end
        end
        local seen, unique = {}, {}
        for _, v in ipairs(names) do
          if not seen[v] then unique[#unique + 1] = v; seen[v] = true end
        end
        if #unique == 0 then return "" end
        return table.concat(unique, " · ")
      end

      local function macro_rec()
        local r = vim.fn.reg_recording()
        return r ~= "" and ("󰑋 @" .. r) or ""
      end

      local function clock()
        return "󰔠 " .. os.date("%I:%M %p")
      end

      local PROSE = { markdown = true, text = true, org = true, norg = true }
      local function word_count()
        if not PROSE[vim.bo.filetype] then return "" end
        return ("󰦨 %dw"):format(vim.fn.wordcount().words)
      end

      local function supermaven()
        local ok, api = pcall(require, "supermaven-nvim.api")
        return (ok and api.is_running()) and "󱚣 SM" or ""
      end

      local function noice_mode()
        return package.loaded["noice"] and require("noice").api.status.mode.get() or ""
      end
      local function noice_mode_cond()
        return package.loaded["noice"] and require("noice").api.status.mode.has()
      end

      -- ── Setup ──────────────────────────────────────────────────────────────
      require("lualine").setup({
        options = {
          theme                = "auto",
          globalstatus         = true,
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          refresh = { statusline = 1000 },
          disabled_filetypes = {
            statusline = {
              "dashboard", "alpha", "neo-tree",
              "snacks_dashboard", "lazy", "mason",
            },
          },
        },

        sections = {
          lualine_a = {
            {
              mode_label,
              padding = { left = 2, right = 2 },
            },
          },

          lualine_b = {
            {
              "branch",
              icon    = " ",
              padding = { left = 1, right = 1 },
              fmt     = function(name)
                return #name > 20 and name:sub(1, 18) .. "…" or name
              end,
            },
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
              padding = { left = 1, right = 1 },
            },
          },

          lualine_c = {
            {
              "diagnostics",
              sources  = { "nvim_lsp" },
              symbols  = { error = " ", warn = " ", hint = " ", info = " " },
              padding = { left = 1, right = 1 },
            },
            {
              "filename",
              path    = 0,
              symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
              padding = { left = 2, right = 2 },
            },
          },

          lualine_x = {
            -- Macro recording pill (hidden when not recording)
            {
              macro_rec,
              cond    = function() return vim.fn.reg_recording() ~= "" end,
              color   = { fg = "#cca700", gui = "bold" },
              padding = { left = 1, right = 1 },
            },
            -- Noice command/search mode (hidden when not active)
            {
              noice_mode,
              cond    = noice_mode_cond,
              color   = { fg = "#cca700" },
              padding = { left = 1, right = 1 },
            },
            -- Supermaven AI
            {
              supermaven,
              cond    = function() return package.loaded["supermaven-nvim"] end,
              color   = { fg = "#4ec9b0" },
              padding = { left = 1, right = 1 },
            },
            -- Word count (prose only)
            {
              word_count,
              cond    = function() return PROSE[vim.bo.filetype] == true end,
              color   = { fg = "#c586c0" },
              padding = { left = 1, right = 1 },
            },
            -- LSP / formatters (hidden when none active)
            {
              lsp_clients,
              cond    = function() return lsp_clients() ~= "" end,
              icon    = "󰒍",
              color   = { fg = "#9cdcfe" },
              padding = { left = 1, right = 1 },
            },
            -- Encoding (hidden when utf-8)
            {
              "encoding",
              fmt     = function(s) return s ~= "utf-8" and s or "" end,
              cond    = function() return vim.bo.fileencoding ~= "utf-8" end,
              padding = { left = 1, right = 1 },
            },
            -- Filetype with icon
            {
              "filetype",
              padding = { left = 1, right = 1 },
            },
            -- Clock (subtle color)
            {
              clock,
              color   = { fg = "#858585" },
              padding = { left = 1, right = 2 },
            },
          },

          lualine_y = {
            {
              "location",
              fmt = function(str)
                local l, col = str:match("%s*(%d+):%s*(%d+)")
                return l and ("Ln %s Col %s"):format(l, col) or str
              end,
              padding = { left = 1, right = 1 },
            },
          },

          lualine_z = {
            {
              "progress",
              fmt = function(s)
                if s == "Top" then return "TOP" end
                if s == "Bot" then return "BOT" end
                return s
              end,
              padding = { left = 1, right = 2 },
            },
          },
        },

        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { "filename", path = 0 } },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },

        extensions = { "lazy", "mason", "neo-tree", "quickfix", "trouble", "fugitive" },
      })
    end,
  },
}