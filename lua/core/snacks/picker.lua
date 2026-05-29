-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  snacks/picker.lua  ·  Obsidian Pro Edition                              ║
-- ║  Precision-tuned, zero-noise, dynamic settings, hot-reload supported     ║
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

--- Returns a complete layout table, with optional per-call overrides.
local function L(opts)
  local settings = get_settings()
  local picker_settings = (settings.ui and settings.ui.picker) or {}

  local user_preset = picker_settings.layout or settings.picker_layout or "telescope"
  local preset = PRESET_MAP[user_preset] or user_preset or "telescope"

  local width = picker_settings.width or settings.picker_width or 0.85
  local height = picker_settings.height or settings.picker_height or 0.80

  return vim.tbl_deep_extend("force", {
    preset   = preset,
    width    = width,
    height   = height,
    backdrop = 60,
  }, opts or {})
end

-- ── Shared window config ──────────────────────────────────────────────────
--- @param extra_keys table?  Additional key mappings merged into list win.
--- @return table
local function win_config(extra_keys)
  local settings = get_settings()
  local picker_settings = (settings.ui and settings.ui.picker) or {}
  local border = picker_settings.border or settings.menu_border or "rounded"

  return {
    border = border,
    input = {
      border = border,
      keys = {
        ["<Esc>"]   = "close",
        ["<C-c>"]   = "close",
        ["<C-j>"]   = "list_down",
        ["<C-k>"]   = "list_up",
        ["<C-u>"]   = "preview_scroll_up",
        ["<C-d>"]   = "preview_scroll_down",
        ["<C-s>"]   = "flash",            -- flash.nvim jump
        ["<C-t>"]   = "tab",              -- open in new tab
        ["<C-v>"]   = "vertical",         -- vertical split
        ["<C-x>"]   = "horizontal",       -- horizontal split
        ["<C-q>"]   = "qflist",           -- send to quickfix
        ["<M-p>"]   = "toggle_preview",
        ["<M-h>"]   = "toggle_hidden",
        ["<M-i>"]   = "toggle_ignored",
      },
    },
    list = {
      border = border,
      keys = vim.tbl_extend("force", {
        ["<Tab>"]   = "select_and_next",
        ["<S-Tab>"] = "select_and_prev",
        ["<C-a>"]   = "select_all",
      }, extra_keys or {}),
    },
    preview = { border = border },
  }
end

-- ── Icon definitions ──────────────────────────────────────────────────────
local ICONS = {
  kinds = {
    Array          = "󰅪 ",   Class    = "󰌗 ",   Constant = "󰏿 ",
    Constructor    = "󰆧 ",   Enum     = "󰖽 ",   EnumMember = "󰖽 ",
    Event          = "󱐋 ",   Field    = "󰜢 ",   File     = "󰈔 ",
    Folder         = "󰉋 ",   Function = "󰊕 ",   Interface = "󰌗 ",
    Key            = "󰌋 ",   Keyword  = "󰌻 ",   Method   = "󰆧 ",
    Module         = "󰏗 ",   Namespace = "󰦮 ", Null     = "󰟢 ",
    Number         = "󰎠 ",   Object   = "󰅩 ",   Operator = "󰆕 ",
    Package        = "󰏗 ",   Property = "󰖷 ",   Reference = "󰈇 ",
    Snippet        = "󰘦 ",   String   = "󰉾 ",   Struct   = "󰌼 ",
    TypeParameter  = "󰊄 ",   Unit     = "󰑭 ",   Value    = "󰎠 ",
    Variable       = "󰀫 ",   Boolean  = "󰨙 ",   Color    = "󰏘 ",
  },

  selected   = "󰄬 ",
  unselected = "󰄱 ",

  ui = {
    live     = "󱐋 ",  hidden  = "󰵛 ",  ignored  = "󰷎 ",
    follow   = "󰓾 ",  modified = "󰝶 ", readonly = "󰌾 ",
  },

  git = {
    untracked = "󰇶 ",
    modified  = "󰏬 ",
    staged    = "󰄬 ",
    conflict  = "󰅙 ",
    deleted   = "󰍵 ",
    renamed   = "󰅂 ",
    ignored   = "󰛐 ",
    added     = "󰄬 ",
  },

  diagnostics = {
    error = "󰅙 ",
    warn  = "󰗖 ",
    info  = "󰋼 ",
    hint  = "󰌶 ",
  },
}

-- ── File explorer: custom transform + formatter ───────────────────────────
local function explorer_transform(item)
  -- Hide virtual root node that snacks renders as a blank line
  if item.dir and item.parent == nil then return false end
  return item
end

local function explorer_format(item, picker)
  local ret = require("snacks.picker.format").file(item, picker)
  for _, hl in ipairs(ret) do
    if hl.virtual and type(hl[1]) == "string" and not hl[1]:match("^%s*$") then
      if item.dir then
        -- ▾ open  ▸ closed — solid filled carets
        local chevron = item.open and "\u{25be}" or "\u{25b8}"
        hl[1] = chevron .. "  " .. hl[1]   -- two spaces between chevron and dir name
      else
        hl[1] = "    " .. hl[1]            -- align files under dir label
      end
      break
    end
  end
  -- Overlay git badge on the icon column when available
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
  local explorer_settings = settings.explorer or {}
  local show_hidden = explorer_settings.show_hidden
  if show_hidden == nil then
    show_hidden = settings.show_hidden_files
  end
  if show_hidden == nil then
    show_hidden = true
  end

  local position = explorer_settings.position or settings.file_explorer_position or "left"

  return {
    show_hidden = show_hidden,
    position = position,
  }
end

-- ── Hot-Reload Autocommand ─────────────────────────────────────────────────
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("SnacksPickerHotReload", { clear = true }),
  pattern = "*/settings.lua",
  callback = function()
    vim.schedule(function()
      if _G.Snacks and _G.Snacks.config and _G.Snacks.config.picker then
        package.loaded["core.snacks.picker"] = nil
        local new_cfg = require("core.snacks.picker")
        _G.Snacks.config.picker = vim.tbl_deep_extend("force", _G.Snacks.config.picker, new_cfg)
        vim.notify("🌊 Snacks Picker config hot-reloaded", vim.log.levels.INFO)
      end
    end)
  end,
})

-- ── Main config ───────────────────────────────────────────────────────────
return {
  enabled   = true,
  ui_select = true,

  icons = ICONS,
  win   = win_config(),
  layout = L(),

  matcher = {
    frecency   = true,
    history    = true,
    sort_empty = false,
  },

  sources = {

    -- ── File Explorer ──────────────────────────────────────────────────────
    explorer = {
      transform = explorer_transform,
      format    = explorer_format,
      hidden    = get_explorer_options().show_hidden,
      follow    = true,
      layout = {
        preset  = "sidebar",
        layout  = { position = get_explorer_options().position },
        width   = 34,
        title   = "",        -- remove the "Explorer" heading
        -- NOTE: "input" is intentionally NOT in hidden = {} so that
        -- rename / add / delete prompts appear inline in the sidebar.
      },
      win = {
        list = {
          border = "none",
          winhighlight = table.concat({
            "Normal:TabLine",
            "NormalNC:TabLine",
            "FloatBorder:TabLine",
            "CursorLine:Visual",
            "WinSeparator:TabLine",
          }, ","),
          keys = {
            ["<C-n>"]   = "close",
            ["r"]       = "explorer_rename",
            ["a"]       = "explorer_add",
            ["d"]       = "explorer_del",
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
        dir_open = " ",
        dir      = " ",
        file     = " ",
        symlink  = "󰌷 ",
      },
    },

    -- ── Files ──────────────────────────────────────────────────────────────
    files = {
      layout  = L(),
      hidden  = true,
      ignored = false,
      format  = "file",
      exclude = { ".git", "node_modules", ".cache", "dist", "build", "__pycache__", ".next" },
    },

    -- ── Grep ───────────────────────────────────────────────────────────────
    grep = {
      layout  = L(),
      hidden  = true,
      ignored = false,
      args    = { "--smart-case", "--hidden", "--glob=!.git/*" },
    },

    -- ── LSP sources ────────────────────────────────────────────────────────
    lsp_references        = { layout = L({ height = 0.6 }) },
    lsp_definitions       = { layout = L({ height = 0.6 }) },
    lsp_implementations   = { layout = L({ height = 0.6 }) },
    lsp_type_definitions  = { layout = L({ height = 0.6 }) },
    lsp_symbols           = { layout = L({ width = 0.7 }) },
    lsp_workspace_symbols = { layout = L({ width = 0.7 }) },

    -- ── Diagnostics ──────────────────────────────────────────────────────
    diagnostics = {
      layout = L({ height = 0.55 }),
      format = "diagnostic",
      filter = { severity = nil },
    },

    -- ── Buffers ──────────────────────────────────────────────────────────
    buffers = {
      layout = L({ height = 0.55, width = 0.65 }),
      current = false,
      sort_lastused = true,
    },

    -- ── Git sources ───────────────────────────────────────────────────────
    git_status = {
      layout = L(),
      win = win_config({
        ["gs"] = "git_stage",
        ["gu"] = "git_unstage",
        ["gr"] = "git_revert",
        ["gp"] = "git_diff",
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

    -- ── Misc sources ──────────────────────────────────────────────────────
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