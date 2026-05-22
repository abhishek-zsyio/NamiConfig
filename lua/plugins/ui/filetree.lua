-- NvimTree: polished file explorer matching NvChad's look
return {
  {
    "nvim-tree/nvim-tree.lua",
    cmd          = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeOpen" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      -- Disable netrw (NvChad does this)
      vim.g.loaded_netrw       = 1
      vim.g.loaded_netrwPlugin = 1

      -- Custom highlights to match catppuccin mocha
      local function setup_highlights()
        local hi = vim.api.nvim_set_hl
        hi(0, "NvimTreeNormal",         { bg = "NONE" })          -- transparent bg
        hi(0, "NvimTreeNormalNC",        { bg = "NONE" })
        hi(0, "NvimTreeWinSeparator",    { fg = "#313244", bg = "NONE" })
        hi(0, "NvimTreeIndentMarker",    { fg = "#45475a" })
        hi(0, "NvimTreeFolderIcon",      { fg = "#89b4fa" })       -- catppuccin blue
        hi(0, "NvimTreeFolderName",      { fg = "#cdd6f4" })
        hi(0, "NvimTreeOpenedFolderName",{ fg = "#89b4fa", bold = true })
        hi(0, "NvimTreeRootFolder",      { fg = "#cba6f7", bold = true }) -- mauve
        hi(0, "NvimTreeGitDirty",        { fg = "#f9e2af" })       -- yellow
        hi(0, "NvimTreeGitNew",          { fg = "#a6e3a1" })       -- green
        hi(0, "NvimTreeGitDeleted",      { fg = "#f38ba8" })       -- red
        hi(0, "NvimTreeGitStaged",       { fg = "#a6e3a1" })
        hi(0, "NvimTreeGitMerge",        { fg = "#fab387" })
        hi(0, "NvimTreeGitRenamed",      { fg = "#cba6f7" })
        hi(0, "NvimTreeGitIgnored",      { fg = "#6c7086" })
        hi(0, "NvimTreeSymlink",         { fg = "#94e2d5" })
        hi(0, "NvimTreeExecFile",        { fg = "#a6e3a1", bold = true })
        hi(0, "NvimTreeSpecialFile",     { fg = "#f5c2e7", underline = true })
        hi(0, "NvimTreeCursorLine",      { bg = "#313244" })
      end

      setup_highlights()

      -- Re-apply after colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = setup_highlights,
      })

      -- Pre-define the signs nvim-tree diagnostics needs
      -- (prevents "Unknown sign: NvimTreeDiagnosticXxxIcon" errors)
      local signs = {
        NvimTreeDiagnosticErrorIcon = " ",
        NvimTreeDiagnosticWarnIcon  = " ",
        NvimTreeDiagnosticWarningIcon = " ",
        NvimTreeDiagnosticInfoIcon  = " ",
        NvimTreeDiagnosticHintIcon  = " ",
      }
      for name, text in pairs(signs) do
        vim.fn.sign_define(name, { text = text, texthl = name })
      end

      require("nvim-tree").setup({
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          -- default mappings
          api.config.mappings.default_on_attach(bufnr)
          -- override/add custom ones
          local opts = function(desc)
            return { desc = "NvimTree: " .. desc, buffer = bufnr, noremap = true, silent = true }
          end
          vim.keymap.set("n", "l", api.node.open.edit,            opts("Open"))
          vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close dir"))
          vim.keymap.set("n", "v", api.node.open.vertical,         opts("Open vertical split"))
        end,

        sort = {
          sorter    = "case_sensitive",
          folders_first = true,
        },

        view = {
          width           = 30,
          side            = "left",
          preserve_window_proportions = false,
          number          = false,
          relativenumber  = false,
          signcolumn      = "yes",
        },

        renderer = {
          add_trailing        = false,
          group_empty         = true,
          highlight_git       = true,
          highlight_opened_files = "none",
          root_folder_label   = false,
          indent_width        = 2,
          indent_markers = {
            enable  = true,
            inline_arrows = true,
            icons   = {
              corner  = "└",
              edge    = "│",
              item    = "│",
              bottom  = "─",
              none    = " ",
            },
          },
          icons = {
            webdev_colors   = true,
            git_placement   = "before",
            modified_placement = "after",
            padding         = " ",
            symlink_arrow   = " ➛ ",
            show = {
              file          = true,
              folder        = true,
              folder_arrow  = true,
              git           = true,
              modified      = true,
            },
            glyphs = {
              default   = "󰈚",
              symlink   = "",
              bookmark  = "󰆤",
              modified  = "●",
              folder = {
                arrow_closed = "",
                arrow_open   = "",
                default      = "",
                open         = "",
                empty        = "",
                empty_open   = "",
                symlink      = "",
                symlink_open = "",
              },
              git = {
                unstaged  = "",
                staged    = "",
                unmerged  = "",
                renamed   = "➜",
                untracked = "",
                deleted   = "",
                ignored   = "",
              },
            },
          },
        },

        filters = {
          dotfiles = false,
          git_ignored = false,
          custom   = { ".DS_Store", "node_modules/.cache" },
          exclude  = {},
        },

        git = {
          enable  = true,
          ignore  = false,
          show_on_dirs = true,
          timeout = 400,
        },

        actions = {
          use_system_clipboard = true,
          change_dir = {
            enable     = true,
            global     = false,
            restrict_above_cwd = false,
          },
          expand_all = {
            max_folder_discovery = 300,
            exclude = { ".git", "target", "build", "node_modules" },
          },
          file_popup = {
            open_win_config = {
              col      = 1,
              row      = 1,
              relative = "cursor",
              border   = "shadow",
              style    = "minimal",
            },
          },
          open_file = {
            quit_on_open      = false,
            eject             = true,
            resize_window     = true,
            window_picker = {
              enable   = true,
              picker   = "default",
              chars    = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
              exclude  = {
                filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                buftype  = { "nofile", "terminal", "help" },
              },
            },
          },
        },

        update_focused_file = {
          enable      = true,
          update_root = false,
          ignore_list = {},
        },

        diagnostics = {
          enable            = true,
          show_on_dirs      = true,
          show_on_open_dirs = true,
          debounce_delay    = 50,
          severity = {
            min = vim.diagnostic.severity.HINT,
            max = vim.diagnostic.severity.ERROR,
          },
          icons = {
            hint    = " ",
            info    = " ",
            warning = " ",
            error   = " ",
          },
        },

        ui = {
          confirm = {
            remove = true,
            trash  = true,
          },
        },
      })
    end,
  },
}
