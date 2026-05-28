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
        font          = "JetBrainsMono NFM=15;Noto Color Emoji=15",
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


  -- Markdown preview: glow in a real terminal vsplit (full ANSI color + styling)
  -- No external plugin needed — glow is a system binary (brew install glow)
  {
    dir = vim.fn.stdpath("config"),  -- points to ~/.config/nvim; no remote fetch
    name = "glow-preview",
    lazy = false,
    config = function()
      local glow_win = nil
      local glow_buf = nil

      local function open_glow()
        local file = vim.fn.expand("%:p")
        if file == "" or vim.bo.filetype ~= "markdown" then
          vim.notify("GlowPreview: not a markdown file", vim.log.levels.WARN)
          return
        end

        -- Toggle: close if already open
        if glow_win and vim.api.nvim_win_is_valid(glow_win) then
          vim.api.nvim_win_close(glow_win, true)
          glow_win, glow_buf = nil, nil
          return
        end

        local src_win = vim.api.nvim_get_current_win()

        -- Open a vertical split on the right
        vim.cmd("botright vsplit")
        glow_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_width(glow_win, math.floor(vim.o.columns * 0.45))

        -- Run glow inside a real terminal buffer → ANSI colors preserved
        local width = vim.api.nvim_win_get_width(glow_win) - 2
        vim.cmd(string.format(
          "terminal glow --style dark --width %d %s",
          width, vim.fn.shellescape(file)
        ))
        glow_buf = vim.api.nvim_get_current_buf()

        -- Minimal, distraction-free look
        local wo = vim.wo[glow_win]
        wo.number         = false
        wo.relativenumber = false
        wo.signcolumn     = "no"
        wo.statuscolumn   = ""
        wo.winfixwidth    = true
        vim.bo[glow_buf].buflisted = false

        -- Brief terminal-mode start so glow renders, then return focus
        vim.cmd("startinsert")
        vim.defer_fn(function()
          vim.cmd("stopinsert")
          if vim.api.nvim_win_is_valid(src_win) then
            vim.api.nvim_set_current_win(src_win)
          end
        end, 80)

        -- q closes the preview
        vim.keymap.set("n", "q", function()
          if glow_win and vim.api.nvim_win_is_valid(glow_win) then
            vim.api.nvim_win_close(glow_win, true)
          end
          glow_win, glow_buf = nil, nil
        end, { buffer = glow_buf, nowait = true, silent = true })

        vim.api.nvim_create_autocmd("WinClosed", {
          pattern  = tostring(glow_win),
          once     = true,
          callback = function() glow_win, glow_buf = nil, nil end,
        })
      end

      vim.api.nvim_create_user_command("GlowPreview", open_glow, {})

      vim.api.nvim_create_autocmd("FileType", {
        pattern  = "markdown",
        callback = function()
          vim.keymap.set("n", "<leader>op", open_glow, {
            buffer = true,
            silent = true,
            desc   = "Toggle Markdown preview (glow split)",
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
        { "<leader>e",  group = "󰙅 Explorer" },
        { "<leader>x",  group = " Close Buffer" },
        { "<leader>n",  group = "󰎦 Numbers" },

        -- Find / Files / Telescope
        { "<leader>f",  group = "󰍉 Find" },
        { "<leader>ff", desc = "Find files" },
        { "<leader>fw", desc = "Live grep" },
        { "<leader>fb", desc = "Find buffers" },
        { "<leader>fh", desc = "Help tags" },
        { "<leader>fo", desc = "Recent files" },
        { "<leader>fz", desc = "Fuzzy in buffer" },

        -- Git
        { "<leader>g",  group = " Git" },
        { "<leader>gg", desc = "LazyGit" },
        { "<leader>gd", desc = "Diffview toggle" },
        { "<leader>gt", desc = "Git status" },
        { "<leader>gc", desc = "Git commits" },
        { "<leader>gT", desc = "Go: Test (Go files only)" },

        -- Code / LSP
        { "<leader>c",  group = " Code / LSP" },
        { "<leader>ca", desc = "Code action" },
        { "<leader>cf", desc = "Format buffer" },
        { "<leader>cl", desc = "Lint file" },
        { "<leader>cn", desc = "Dismiss notification" },

        -- Rename / Refactor
        { "<leader>r",  group = "󰑕 Rename / Refactor" },
        { "<leader>ra", desc = "LSP rename" },
        { "<leader>rn", desc = "Toggle relative numbers" },

        -- Diagnostics
        { "<leader>d",  group = "󰃤 Diagnostics / Debug" },
        { "<leader>ds", desc = "Diagnostics list" },
        { "<leader>db", desc = "DAP: Toggle breakpoint" },
        { "<leader>dc", desc = "DAP: Continue" },
        { "<leader>dso",desc = "DAP: Step over" },
        { "<leader>dsi",desc = "DAP: Step in" },
        { "<leader>dt", desc = "DAP: Terminate" },

        -- Format
        { "<leader>fm", desc = "LSP format" },

        -- Toggle / UI
        { "<leader>t",  group = "󰔡 Toggles" },
        { "<leader>tl", desc = "Toggle linting" },
        { "<leader>th", desc = "Select theme" },

        -- Testing (neotest extra)
        { "<leader>T",  group = "󰙨 Tests" },
        { "<leader>Tr", desc = "Run nearest test" },
        { "<leader>Tf", desc = "Run file tests" },
        { "<leader>Ta", desc = "Run all tests" },
        { "<leader>Td", desc = "Debug nearest test" },
        { "<leader>Ts", desc = "Stop tests" },
        { "<leader>To", desc = "Test output" },
        { "<leader>TS", desc = "Test summary" },
        { "<leader>Tw", desc = "Watch file tests" },

        -- Database (sql extra)
        { "<leader>D",  group = "󰆼 Database" },
        { "<leader>Du", desc = "DB: Toggle UI" },
        { "<leader>Da", desc = "DB: Add connection" },
        { "<leader>Df", desc = "DB: Find buffer" },

        -- Session
        { "<leader>q",  group = "󰆓 Session" },

        -- Zen Mode
        { "<leader>z",  desc = "Toggle Zen Mode" },

        -- Misc
        { "<leader>ma", desc = "Find marks" },
        { "<leader>op", desc = "Preview Markdown (glow)" },
        { "<leader>sc", desc = "Screenshot code" },
        { "<leader>vs", desc = "Select Python venv" },
        { "<leader>/",  desc = "Toggle comment" },
      })
    end,
  },
}

