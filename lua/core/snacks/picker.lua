-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  snacks/picker.lua  ·  Unified flat edition                              ║
-- ║  Same visual language as bufferline + lualine: flat, no chrome, accent   ║
-- ║  via fg weight only. Explorer is clean — no chevron prefix clutter.      ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local function get_settings()
  local ok, settings = pcall(require, "settings")
  return ok and settings or {}
end

-- ── Layout preset resolution ──────────────────────────────────────────────
local PRESET_MAP = {
  horizontal = "default",
  vertical   = "vertical",
  telescope  = "telescope",
  ivy        = "ivy",
  dropdown   = "dropdown",
  vscode     = "vscode",
}

local function L(opts)
  local settings = get_settings()
  local ps = (settings.ui and settings.ui.picker) or {}
  local user_preset = ps.layout or settings.picker_layout or "telescope"
  local preset = PRESET_MAP[user_preset] or user_preset or "telescope"
  return vim.tbl_deep_extend("force", {
    preset   = preset,
    width    = ps.width  or settings.picker_width  or 0.85,
    height   = ps.height or settings.picker_height or 0.80,
    backdrop = 60,
  }, opts or {})
end

-- ── Shared window config ──────────────────────────────────────────────────
local function win_config(extra_keys)
  local settings = get_settings()
  local ps = (settings.ui and settings.ui.picker) or {}
  local border = ps.border or settings.menu_border or "rounded"
  return {
    border = border,
    input = {
      border = border,
      keys = {
        ["<Esc>"] = "close",   ["<C-c>"] = "close", ["ZZ"] = "close",
        ["<C-j>"] = "list_down", ["<C-k>"] = "list_up",
        ["<C-u>"] = "preview_scroll_up", ["<C-d>"] = "preview_scroll_down",
        ["<C-s>"] = "flash",   ["<C-t>"] = "tab",
        ["<C-v>"] = "vertical", ["<C-x>"] = "horizontal",
        ["<C-q>"] = "qflist",  ["<M-p>"] = "toggle_preview",
        ["<M-h>"] = "toggle_hidden", ["<M-i>"] = "toggle_ignored",
      },
    },
    list = {
      border = border,
      keys = vim.tbl_extend("force", {
        ["<Tab>"]   = "select_and_next",
        ["<S-Tab>"] = "select_and_prev",
        ["<C-a>"]   = "select_all",
        ["ZZ"]      = "close",
      }, extra_keys or {}),
    },
    preview = { border = border },
  }
end

-- ── Icon definitions ──────────────────────────────────────────────────────
local ICONS = {
  kinds = {
    Array         = "󰅪 ", Class       = "󰌗 ", Constant    = "󰏿 ",
    Constructor   = "󰆧 ", Enum        = "󰖽 ", EnumMember  = "󰖽 ",
    Event         = "󱐋 ", Field       = "󰜢 ", File        = "󰈔 ",
    Folder        = "󰉋 ", Function    = "󰊕 ", Interface   = "󰌗 ",
    Key           = "󰌋 ", Keyword     = "󰌻 ", Method      = "󰆧 ",
    Module        = "󰏗 ", Namespace   = "󰦮 ", Null        = "󰟢 ",
    Number        = "󰎠 ", Object      = "󰅩 ", Operator    = "󰆕 ",
    Package       = "󰏗 ", Property    = "󰖷 ", Reference   = "󰈇 ",
    Snippet       = "󰘦 ", String      = "󰉾 ", Struct      = "󰌼 ",
    TypeParameter = "󰊄 ", Unit        = "󰑭 ", Value       = "󰎠 ",
    Variable      = "󰀫 ", Boolean     = "󰨙 ", Color       = "󰏘 ",
  },
  selected   = "󰄬 ",
  unselected = "󰄱 ",
  ui = {
    live = "󱐋 ", hidden = "󰵛 ", ignored = "󰷎 ",
    follow = "󰓾 ", modified = "󰝶 ", readonly = "󰌾 ",
  },
  git = {
    untracked = "󰇶 ", modified = "󰏬 ", staged   = "󰄬 ",
    conflict  = "󰅙 ", deleted  = "󰍵 ", renamed  = "󰅂 ",
    ignored   = "󰛐 ", added    = "󰄬 ",
  },
  diagnostics = {
    error = "󰅙 ", warn = "󰗖 ", info = "󰋼 ", hint = "󰌶 ",
  },
}

-- ── Explorer: transform + formatter ──────────────────────────────────────
local function explorer_format(item, picker)
  local ret = require("snacks.picker.format").file(item, picker)

  for _, hl in ipairs(ret) do
    if hl.virtual and type(hl[1]) == "string" and not hl[1]:match("^%s*$") then
      if item.dir then
        local chevron = item.open and "\u{25be}" or "\u{25b8}"
        hl[1] = chevron .. " " .. hl[1]
      else
        hl[1] = "  " .. hl[1]   -- align files under their dir
      end
      break
    end
  end

  if item.git_status then
    local badge = ICONS.git[item.git_status]
    if badge then
      table.insert(ret, { badge, hl = "SnacksPickerGitStatus" })
    end
  end
  return ret
end

local function get_explorer_options()
  local settings = get_settings()
  local ex = settings.explorer or {}
  local show_hidden = ex.show_hidden
  if show_hidden == nil then show_hidden = settings.show_hidden_files end
  if show_hidden == nil then show_hidden = true end
  return {
    show_hidden = show_hidden,
    position    = ex.position or settings.file_explorer_position or "left",
  }
end

-- ── Hot-reload on settings.lua save ──────────────────────────────────────
vim.api.nvim_create_autocmd("BufWritePost", {
  group   = vim.api.nvim_create_augroup("SnacksPickerHotReload", { clear = true }),
  pattern = "*/settings.lua",
  callback = function()
    vim.schedule(function()
      if _G.Snacks and _G.Snacks.config and _G.Snacks.config.picker then
        package.loaded["core.snacks.picker"] = nil
        local new_cfg = require("core.snacks.picker")
        _G.Snacks.config.picker = vim.tbl_deep_extend("force", _G.Snacks.config.picker, new_cfg)
        vim.notify("󰑓  Snacks Picker reloaded", vim.log.levels.INFO)
      end
    end)
  end,
})

-- ── Main config ───────────────────────────────────────────────────────────
return {
  enabled   = true,
  ui_select = true,

  icons  = ICONS,
  win    = win_config(),
  layout = L(),

  matcher = {
    frecency   = true,
    history    = true,
    sort_empty = false,
  },

  sources = {

    -- ── File Explorer ────────────────────────────────────────────────────
    -- Visual contract: same bg as bufferline fill (TabLine), flat, no border.
    -- Cursor line uses Visual so it shares the accent colour palette.
    -- WinSeparator is invisible — the bufferline offset creates the boundary.
    explorer = {
      format    = explorer_format,
      hidden    = get_explorer_options().show_hidden,
      follow    = true,
      layout = {
        preset = "sidebar",
        hidden = { "input" },
        layout = { position = get_explorer_options().position },
        width  = 32,
        title  = "",   -- no heading
      },

      -- ── Inline actions: prompts appear in the cmdline bar, no float ───
      actions = {
        -- Add a file or directory using vim.fn.input at the cmdline bar.
        -- End the name with / to create a directory instead of a file.
        explorer_add_inline = function(picker)
          local dir = picker:dir()
          vim.api.nvim_echo({ { " Add (end with / for dir): ", "Question" } }, false, {})
          local name = vim.fn.input("")
          vim.api.nvim_echo({ { "", "Normal" } }, false, {})
          if name == nil or name == "" then return end
          local uv   = vim.uv or vim.loop
          local Tree = require("snacks.explorer.tree")
          local ExA  = require("snacks.explorer.actions")
          local path = vim.fs.normalize(dir .. "/" .. name)
          local is_file = name:sub(-1) ~= "/"
          local target_dir = is_file and vim.fs.dirname(path) or path
          
          if uv.fs_stat(path) then
            vim.notify((is_file and "File" or "Directory") .. " already exists: " .. path, vim.log.levels.WARN)
            return
          end

          local stat = uv.fs_stat(target_dir)
          if stat and stat.type ~= "directory" then
            vim.notify("Cannot create directory, file exists: " .. target_dir, vim.log.levels.ERROR)
            return
          elseif not stat then
            local ok, err = pcall(vim.fn.mkdir, target_dir, "p")
            if not ok then
              vim.notify("Failed to create directory: " .. target_dir .. "\n" .. tostring(err), vim.log.levels.ERROR)
              return
            end
          end
          
          if is_file then
            local f = io.open(path, "w")
            if f then f:close() end
          end
          Tree:open(target_dir)
          Tree:refresh(target_dir)
          ExA.update(picker, { target = path })
        end,

        -- Rename in place: pre-fills current filename at the cmdline bar.
        explorer_rename_inline = function(picker, item)
          if not item then return end
          local old      = item.file
          local basename = vim.fn.fnamemodify(old, ":t")
          vim.api.nvim_echo({ { " Rename: ", "Question" } }, false, {})
          local new_name = vim.fn.input("", basename)
          vim.api.nvim_echo({ { "", "Normal" } }, false, {})
          if new_name == nil or new_name == "" or new_name == basename then return end
          local new_path = vim.fs.normalize(vim.fs.dirname(old) .. "/" .. new_name)
          local Tree     = require("snacks.explorer.tree")
          local ExA      = require("snacks.explorer.actions")
          local ok, err  = pcall(vim.fn.rename, old, new_path)
          if not ok or err ~= 0 then
            vim.notify("Rename failed", vim.log.levels.ERROR)
            return
          end
          -- Update any open buffers pointing at the old path
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_name(buf) == old then
              vim.api.nvim_buf_set_name(buf, new_path)
            end
          end
          Tree:refresh(vim.fs.dirname(old))
          Tree:refresh(vim.fs.dirname(new_path))
          ExA.update(picker, { target = new_path })
        end,

        -- Delete with a cmdline y/n confirm — no floating dialog.
        explorer_del_inline = function(picker)
          local ExA   = require("snacks.explorer.actions")
          local Tree  = require("snacks.explorer.tree")
          local items = picker:selected({ fallback = true })
          local paths = vim.tbl_map(require("snacks.picker.util").path, items)
          if #paths == 0 then return end
          local what  = #paths == 1
            and vim.fn.fnamemodify(paths[1], ":p:~:.") or (#paths .. " files")
          local choice = vim.fn.confirm("Delete " .. what .. "?", "&Yes\n&No", 2)
          if choice ~= 1 then return end
          for _, path in ipairs(paths) do
            local ok, err = ExA.trash(path)
            if ok then
              pcall(function() Snacks.bufdelete({ file = path, force = true }) end)
            else
              vim.notify("Delete failed: " .. (err or ""), vim.log.levels.ERROR)
            end
            Tree:refresh(vim.fs.dirname(path))
          end
          picker.list:set_selected()
          ExA.update(picker)
        end,
      },

      win = {
        list = {
          border = "none",
          -- Matches bufferline fill bg exactly so they read as one surface
          winhighlight = table.concat({
            "Normal:TabLine",
            "NormalNC:TabLine",
            "FloatBorder:TabLine",
            "CursorLine:Visual",
            "WinSeparator:TabLine",
            "SignColumn:TabLine",
            "FoldColumn:TabLine",
          }, ","),
          keys = {
            ["<C-n>"]   = "close",
            ["r"]       = "explorer_rename_inline",   -- cmdline rename
            ["a"]       = "explorer_add_inline",      -- cmdline add
            ["d"]       = "explorer_del_inline",      -- cmdline confirm delete
            ["y"]       = "explorer_yank",
            ["p"]       = "explorer_paste",
            ["c"]       = "explorer_copy",
            ["m"]       = "explorer_move",
            ["o"]       = "explorer_open",
            ["<space>"] = "confirm",
            ["R"]       = "explorer_update",
            ["."]       = "toggle_hidden",
          },
        },
      },
      icons = {
        tree = {
          vertical = "  ",
          middle   = "  ",
          last     = "  ",
        },
      },
    },

    -- ── Files ────────────────────────────────────────────────────────────
    files = {
      layout  = L(),
      hidden  = true,
      ignored = false,
      format  = "file",
      exclude = { ".git", "node_modules", ".cache", "dist", "build", "__pycache__", ".next" },
    },

    -- ── Grep ─────────────────────────────────────────────────────────────
    grep = {
      layout  = L(),
      hidden  = true,
      ignored = false,
      args    = { "--smart-case", "--hidden", "--glob=!.git/*" },
    },

    -- ── LSP ──────────────────────────────────────────────────────────────
    lsp_references        = { layout = L({ height = 0.6 }) },
    lsp_definitions       = { layout = L({ height = 0.6 }) },
    lsp_implementations   = { layout = L({ height = 0.6 }) },
    lsp_type_definitions  = { layout = L({ height = 0.6 }) },
    lsp_symbols           = { layout = L({ width  = 0.7 }) },
    lsp_workspace_symbols = { layout = L({ width  = 0.7 }) },

    -- ── Diagnostics ──────────────────────────────────────────────────────
    diagnostics = {
      layout = L({ height = 0.55 }),
      format = "diagnostic",
      filter = { severity = nil },
    },

    -- ── Buffers ──────────────────────────────────────────────────────────
    buffers = {
      layout        = L({ height = 0.55, width = 0.65 }),
      current       = false,
      sort_lastused = true,
    },

    -- ── Git ──────────────────────────────────────────────────────────────
    git_status = {
      layout = L(),
      win = win_config({
        ["gs"] = "git_stage", ["gu"] = "git_unstage",
        ["gr"] = "git_revert", ["gp"] = "git_diff",
      }),
    },
    git_log      = { layout = L() },
    git_diff     = { layout = L() },
    git_branches = {
      layout = L({ height = 0.5, width = 0.55 }),
      win = win_config({
        ["<CR>"]  = "git_checkout",
        ["<C-b>"] = "git_branch_create",
        ["<C-d>"] = "git_branch_delete",
      }),
    },
    git_stash = { layout = L({ height = 0.5 }) },

    -- ── Misc ─────────────────────────────────────────────────────────────
    help            = { layout = L() },
    recent          = { layout = L(), filter = { cwd = true } },
    lines           = { layout = L({ preset = "dropdown", height = 0.4 }) },
    marks           = { layout = L({ height = 0.5 }) },
    jumps           = { layout = L({ height = 0.5 }) },
    registers       = { layout = L({ preset = "dropdown", height = 0.5, width = 0.55 }) },
    commands        = { layout = L({ preset = "dropdown", height = 0.55 }) },
    command_history = { layout = L({ preset = "dropdown", height = 0.5 }) },
    search_history  = { layout = L({ preset = "dropdown", height = 0.5 }) },
    keymaps         = { layout = L({ width = 0.7 }) },
    spelling        = { layout = L({ preset = "dropdown", height = 0.4, width = 0.4 }) },
    undo            = { layout = L() },
    colorschemes    = { layout = L({ preset = "dropdown", height = 0.55, width = 0.45 }) },
  },
}