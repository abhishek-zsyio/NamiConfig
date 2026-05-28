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

  -- Markdown preview (Peek)
  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup({
        app = "webview",
        theme = vim.o.background == "light" and "light" or "dark",
      })
      
      -- Theme sync generator
      local function generate_peek_theme()
        local function get_hex(hlgroup, attr)
            local hl = vim.api.nvim_get_hl(0, { name = hlgroup, link = false })
            local color = hl[attr]
            if color then
                return string.format("#%06x", color)
            end
            return nil
        end
        
        local bg = get_hex("Normal", "bg") or "#0a0a0f"
        local fg = get_hex("Normal", "fg") or "#d4d4d4"
        local title = get_hex("Title", "fg") or fg
        local link = get_hex("String", "fg") or "#82aaff"
        local code_bg = get_hex("CursorLine", "bg") or "#1a1a24"
        local code_fg = get_hex("String", "fg") or fg
        local border = get_hex("FloatBorder", "fg") or "#333333"
        local accent = get_hex("Keyword", "fg") or "#c678dd"
        
        local css = string.format([[
:root {
  --nvim-bg: %s;
  --nvim-fg: %s;
  --nvim-title: %s;
  --nvim-link: %s;
  --nvim-code-bg: %s;
  --nvim-code-fg: %s;
  --nvim-border: %s;
  --nvim-accent: %s;
}
]], bg, fg, title, link, code_bg, code_fg, border, accent)

        local file = io.open(vim.fn.stdpath("config") .. "/peek-theme-vars.css", "w")
        if file then
          file:write(css)
          file:close()
        end
        
        -- Tell peek to reload theme if running
        pcall(function()
          local peek_app = require("peek.app")
          if peek_app.update_theme then
            peek_app.update_theme()
          end
        end)
      end
      
      -- Generate immediately
      generate_peek_theme()
      
      -- Generate on ColorScheme change
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("PeekThemeSync", { clear = true }),
        callback = generate_peek_theme,
      })
      
      -- Remove the ugly hardcoded "Peek preview" window title for a clean, frameless look
      local index_html = vim.fn.stdpath("data") .. "/lazy/peek.nvim/public/index.html"
      if vim.fn.filereadable(index_html) == 1 then
        vim.fn.system("sed -i '' \"s/<title>Peek preview<\\/title>/<title> <\\/title>/\" " .. index_html)
      end
    end,
    keys = {
      {
        "<leader>op",
        function()
          local peek = require("peek")
          if peek.is_open() then
            peek.close()
          else
            peek.open()
          end
        end,
        desc = "Toggle Markdown Preview",
      },
    },
  },


  -- Which-key: show keybinding hints on leader press
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
        { "<leader>op", desc = "Toggle Markdown preview" },
        { "<leader>sc", desc = "Screenshot code" },
        { "<leader>vs", desc = "Select Python venv" },
        { "<leader>/",  desc = "Toggle comment" },
      })
    end,
  },
}

