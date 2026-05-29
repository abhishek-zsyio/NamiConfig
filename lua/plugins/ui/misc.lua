-- Misc UI: icons, devicons, inline colors, markdown render, discord, code screenshot
return {
  -- Core icon sets
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "echasnovski/mini.icons", version = false, lazy = false },


  -- Inline color highlighting
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-highlight-colors").setup({
        render = "virtual",
        virtual_symbol = "■",
        virtual_symbol_position = "inline",
        enable_tailwind = true, -- Also enables UnoCSS LSP color support
        enable_short_hex = true,
      })
    end,
  },

  -- Markdown rendering inside Neovim
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft           = { "markdown", "norg", "rmd", "org" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts         = {},
  },

  -- Code screenshot
  {
    "michaelrommel/nvim-silicon",
    lazy = true,
    cmd  = "Silicon",
    config = function()
      require("silicon").setup({
        font          = "JetBrainsMono NFM=15;Apple Color Emoji=15",
        theme         = "gruvbox-dark",
        to_clipboard  = true,
        background    = "#8D6479",
        output        = "~/Pictures/Screenshots/code.png",
        window_title  = function()
          return vim.fn.fnamemodify(
            vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":t"
          )
        end,
      })
    end,
  },

  -- Discord rich presence
  {
    "IogaMaster/neocord",
    event = "VeryLazy",
    opts  = {
      logo            = "auto",
      main_image      = "language",
      show_time       = true,
      global_timer    = false,
      editing_text    = "Editing %s",
      file_explorer_text = "Browsing %s",
      workspace_text  = "Working on %s",
    },
  },


  -- Premium Floating Glow Markdown Previewer with real-time autoupdates and fullscreen support
  {
    dir = vim.fn.stdpath("config"),
    name = "glow-preview",
    lazy = false,
    config = function()
      local previews = {} -- active previews indexed by buffer number: { win = win, buf = buf, augroup = augroup, toggle_fs = function }

      local function toggle_glow()
        local src_buf = vim.api.nvim_get_current_buf()
        local file = vim.api.nvim_buf_get_name(src_buf)

        if file == "" or vim.bo[src_buf].filetype ~= "markdown" then
          vim.notify("GlowPreview: Not a markdown file", vim.log.levels.WARN, { title = "Glow" })
          return
        end

        -- If already open, close it
        if previews[src_buf] then
          local p = previews[src_buf]
          if p.win and vim.api.nvim_win_is_valid(p.win) then
            pcall(vim.api.nvim_win_close, p.win, true)
          end
          pcall(vim.api.nvim_del_augroup_by_id, p.augroup)
          previews[src_buf] = nil
          vim.notify("Glow Preview closed", vim.log.levels.INFO, { title = "Glow" })
          return
        end

        local src_win = vim.api.nvim_get_current_win()

        -- Geometry for right-side floating HUD panel
        local columns = vim.o.columns
        local lines = vim.o.lines
        local width = math.floor(columns * 0.45)
        local height = math.floor(lines * 0.82)
        local row = math.floor((lines - height) / 2) - 1
        local col = columns - width - 4

        -- Unique preview window
        local glow_win = vim.api.nvim_open_win(0, false, {
          relative  = "editor",
          style     = "minimal",
          border    = "rounded",
          width     = width,
          height    = height,
          row       = row,
          col       = col,
          title     = " 📝 Glow Preview [q: Close] ",
          title_pos = "center",
        })

        local glow_buf = nil
        local ag = vim.api.nvim_create_augroup("GlowPreview_" .. src_buf, { clear = true })

        local function cleanup()
          if previews[src_buf] then
            local p = previews[src_buf]
            pcall(vim.api.nvim_del_augroup_by_id, p.augroup)
            if p.win and vim.api.nvim_win_is_valid(p.win) then
              pcall(vim.api.nvim_win_close, p.win, true)
            end
            if glow_buf and vim.api.nvim_buf_is_valid(glow_buf) then
              pcall(vim.api.nvim_buf_delete, glow_buf, { force = true })
            end
            previews[src_buf] = nil
          end
        end

        local function render()
          if not vim.api.nvim_win_is_valid(glow_win) then
            return
          end

          local old_buf = glow_buf
          glow_buf = vim.api.nvim_create_buf(false, true)
          vim.bo[glow_buf].buflisted = false
          vim.api.nvim_win_set_buf(glow_win, glow_buf)

          if old_buf and vim.api.nvim_buf_is_valid(old_buf) then
            pcall(vim.api.nvim_buf_delete, old_buf, { force = true })
          end

          local term_width = vim.api.nvim_win_get_width(glow_win) - 4
          vim.api.nvim_buf_call(glow_buf, function()
            vim.fn.termopen(string.format(
              "glow --style dark --width %d %s",
              term_width, vim.fn.shellescape(file)
            ))
          end)

          local wo = vim.wo[glow_win]
          wo.number         = false
          wo.relativenumber = false
          wo.signcolumn     = "no"
          wo.statuscolumn   = ""
          wo.foldcolumn     = "0"
          wo.winhighlight   = "Normal:NormalFloat,FloatBorder:FloatBorder"
          wo.winfixwidth    = true

          -- Bind local keymaps inside the new terminal scratch buffer
          local key_opts = { buffer = glow_buf, silent = true, nowait = true }
          vim.keymap.set("n", "f", function()
            if previews[src_buf] and previews[src_buf].toggle_fs then
              previews[src_buf].toggle_fs()
            end
          end, key_opts)
          vim.keymap.set("n", "<C-f>", function()
            if previews[src_buf] and previews[src_buf].toggle_fs then
              previews[src_buf].toggle_fs()
            end
          end, key_opts)

          -- Fast close keys
          vim.keymap.set("n", "q", cleanup, key_opts)
          vim.keymap.set("t", "q", cleanup, key_opts)
          vim.keymap.set("t", "<Esc>", cleanup, key_opts)
        end

        -- Initial render
        render()

        -- Focus back to code window
        vim.cmd("stopinsert")
        if vim.api.nvim_win_is_valid(src_win) then
          vim.api.nvim_set_current_win(src_win)
        end

        -- Dynamic fullscreen toggler (truly covers the whole editor window)
        local is_fullscreen = false
        local function toggle_fs()
          if not previews[src_buf] or not vim.api.nvim_win_is_valid(glow_win) then
            return
          end

          local term_cols = vim.o.columns
          local term_lines = vim.o.lines

          if not is_fullscreen then
            vim.api.nvim_win_set_config(glow_win, {
              relative = "editor",
              width    = term_cols,
              height   = term_lines,
              row      = 0,
              col      = 0,
              title    = " 🖥️ Fullscreen Preview [q: Close] ",
              title_pos = "center",
            })
            is_fullscreen = true
            vim.notify("Glow Preview: Fullscreen Mode 🖥️", vim.log.levels.INFO, { title = "Glow" })
          else
            local s_width = math.floor(term_cols * 0.45)
            local s_height = math.floor(term_lines * 0.82)
            local s_row = math.floor((term_lines - s_height) / 2) - 1
            local s_col = term_cols - s_width - 4

            vim.api.nvim_win_set_config(glow_win, {
              relative = "editor",
              width    = s_width,
              height   = s_height,
              row      = s_row,
              col      = s_col,
              title    = " 📝 Glow Preview [q: Close] ",
              title_pos = "center",
            })
            is_fullscreen = false
            vim.notify("Glow Preview: Sidebar Mode 📋", vim.log.levels.INFO, { title = "Glow" })
          end

          render()
        end

        vim.api.nvim_create_autocmd("BufWritePost", {
          group    = ag,
          buffer   = src_buf,
          callback = render,
        })

        vim.api.nvim_create_autocmd({ "BufUnload", "VimLeave" }, {
          group    = ag,
          buffer   = src_buf,
          callback = cleanup,
        })

        vim.api.nvim_create_autocmd("WinClosed", {
          group    = ag,
          pattern  = tostring(glow_win),
          callback = cleanup,
        })

        previews[src_buf] = { win = glow_win, buf = glow_buf, augroup = ag, toggle_fs = toggle_fs }
        vim.notify("Glow HUD Preview launched 🚀", vim.log.levels.INFO, { title = "Glow" })
      end

      -- Expose a global user command for fullscreen toggle
      vim.api.nvim_create_user_command("GlowPreviewFullscreen", function()
        local buf = vim.api.nvim_get_current_buf()
        if previews[buf] and previews[buf].toggle_fs then
          previews[buf].toggle_fs()
        else
          toggle_glow()
          vim.defer_fn(function()
            if previews[buf] and previews[buf].toggle_fs then
              previews[buf].toggle_fs()
            end
          end, 200)
        end
      end, {})

      vim.api.nvim_create_user_command("GlowPreview", toggle_glow, {})

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.keymap.set("n", "<leader>op", toggle_glow, {
            buffer = true,
            silent = true,
            desc   = "Toggle Glow HUD Preview",
          })
          vim.keymap.set("n", "<leader>of", "<cmd>GlowPreviewFullscreen<cr>", {
            buffer = true,
            silent = true,
            desc   = "Toggle Glow Fullscreen",
          })
        end,
      })
    end,
  },


  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = {
      preset = "modern",
      plugins = { spelling = { enabled = true, suggestions = 20 } },
      win  = { border = "rounded" },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      -- ── Register ALL <leader> group prefixes ──────────────────────────────
      wk.add({
        -- Top-level navigation / editor
        { "<leader>e",  group = "\u{f0645} Explorer" },
        { "<leader>x",  group = "\u{f05ad} Close Buffer" },
        { "<leader>n",  group = "\u{f03a6} Numbers / Notifications" },
        { "<leader>nh", desc = "Noice message history" },
        { "<leader>nd", desc = "Dismiss Noice messages" },
        { "<leader>nl", desc = "Show last message" },

        -- Find / Files / Telescope
        { "<leader>f",  group = "\u{f0349} Find" },
        { "<leader>ff", desc = "Find files" },
        { "<leader>fw", desc = "Live grep" },
        { "<leader>fb", desc = "Find buffers" },
        { "<leader>fh", desc = "Help tags" },
        { "<leader>fo", desc = "Recent files" },
        { "<leader>fz", desc = "Fuzzy in buffer" },

        -- Git
        { "<leader>g",  group = "\u{f02a2} Git" },
        { "<leader>gg", desc = "LazyGit" },
        { "<leader>gd", desc = "Diffview toggle" },
        { "<leader>gt", desc = "Git status" },
        { "<leader>gc", desc = "Git commits" },
        { "<leader>gT", desc = "Go: Test (Go files only)" },

        -- Code / LSP
        { "<leader>c",  group = "\u{f0171} Code / LSP" },
        { "<leader>ca", desc = "Code action" },
        { "<leader>cf", desc = "Format buffer" },
        { "<leader>cl", desc = "Lint file" },
        { "<leader>cn", desc = "Dismiss notification" },

        -- Rename / Refactor
        { "<leader>r",  group = "\u{f0455} Rename / Refactor" },
        { "<leader>ra", desc = "LSP rename" },
        { "<leader>rn", desc = "Toggle relative numbers" },

        -- Diagnostics
        { "<leader>d",  group = "\u{f00e4} Diagnostics / Debug" },
        { "<leader>ds", desc = "Diagnostics list" },
        { "<leader>db", desc = "DAP: Toggle breakpoint" },
        { "<leader>dc", desc = "DAP: Continue" },
        { "<leader>dso",desc = "DAP: Step over" },
        { "<leader>dsi",desc = "DAP: Step in" },
        { "<leader>dt", desc = "DAP: Terminate" },

        -- Format
        { "<leader>fm", desc = "LSP format" },

        -- Toggle / UI
        { "<leader>t",  group = "\u{f0521} Toggles" },
        { "<leader>tl", desc = "Toggle linting" },
        { "<leader>th", desc = "Select theme" },

        -- Testing (neotest extra)
        { "<leader>T",  group = "\u{f0668} Tests" },
        { "<leader>Tr", desc = "Run nearest test" },
        { "<leader>Tf", desc = "Run file tests" },
        { "<leader>Ta", desc = "Run all tests" },
        { "<leader>Td", desc = "Debug nearest test" },
        { "<leader>Ts", desc = "Stop tests" },
        { "<leader>To", desc = "Test output" },
        { "<leader>TS", desc = "Test summary" },
        { "<leader>Tw", desc = "Watch file tests" },

        -- Database (sql extra)
        { "<leader>D",  group = "\u{f01bc} Database" },
        { "<leader>Du", desc = "DB: Toggle UI" },
        { "<leader>Da", desc = "DB: Add connection" },
        { "<leader>Df", desc = "DB: Find buffer" },

        -- Session
        { "<leader>q",  group = "\u{f04ce} Session" },

        -- Zen Mode
        { "<leader>z",  desc = "Toggle Zen Mode" },

        -- Misc
        { "<leader>ma", desc = "Find marks" },
        { "<leader>op", desc = "Toggle Glow HUD Preview" },
        { "<leader>of", desc = "Toggle Glow Fullscreen" },
        { "<leader>sc", desc = "Screenshot code" },
        { "<leader>vs", desc = "Select Python venv" },
        { "<leader>/",  desc = "Toggle comment" },
      })
    end,
  },
}

