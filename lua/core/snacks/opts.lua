-- core/snacks/opts.lua — Snacks.nvim base options
local ok, settings = pcall(require, "settings")
local s = ok and settings or {}

return {
  zen      = { 
    enabled = true,
    win = { width = 0 },
    on_open = function(win)
      win.zen_indicator = Snacks.win({
        text = " 󱗼 ZEN MODE ",
        minimal = true,
        enter = false,
        focusable = false,
        width = 14,
        height = 1,
        row = 0,
        col = -1,
        backdrop = false,
        zindex = win.opts.zindex + 1,
        wo = { winhighlight = "NormalFloat:DiagnosticInfo" },
      })
    end,
    on_close = function(win)
      if win.zen_indicator then
        win.zen_indicator:close()
      end
    end,
  },
  dim      = { enabled = s.dim_inactive == true },
  explorer = { enabled = true },

  -- ── Indent guides ──────────────────────────────────────────────────────────
  indent = {
    enabled = s.show_indent_guides ~= false,
    indent = {
      char = "\u{2502}",          -- │  thin vertical bar
      hl   = "SnacksIndent",
    },
    scope = {
      enabled      = true,
      char         = "\u{2503}",  -- ┃  thick vertical bar (active scope)
      underline    = false,
      only_current = false,
      hl           = "SnacksIndentScope",
    },
    chunk = {
      enabled = true,
      char = {
        corner_top    = "\u{250c}",  -- ┌
        corner_bottom = "\u{2514}",  -- └
        horizontal    = "\u{2500}",  -- ─
        vertical      = "\u{2502}",  -- │
        arrow         = "\u{25ba}",  -- ► right-pointing triangle
      },
      hl = "SnacksIndentChunk",
    },
    animate = {
      enabled  = true,
      style    = "out",
      easing   = "linear",
      duration = { step = 20, total = 500 },
    },
  },

  -- ── Buffer delete ─────────────────────────────────────────────────────────
  bufdelete = { enabled = true },

  -- ── Smooth scroll ─────────────────────────────────────────────────────────
  scroll = { enabled = s.smooth_scroll ~= false },

  -- ── Scratch buffer ────────────────────────────────────────────────────────
  scratch = { enabled = true },

  -- ── Notifier ─────────────────────────────────────────────────────────────
  notifier = {
    enabled = true,
    timeout = 2500,
    width   = { min = 40, max = 0.4 },
    height  = { min = 1,  max = 0.6 },
    margin  = { top = 1, right = 1, bottom = 0 },
    padding = true,
    sort    = { "level", "added" },
    level   = vim.log.levels.TRACE,
    icons = {
      error = "\u{f0028} ",  -- nf-md-close_circle
      warn  = "\u{f0026} ",  -- nf-md-alert
      info  = "\u{f0625} ",  -- nf-md-information
      debug = "\u{f0545} ",  -- nf-md-bug
      trace = "\u{f17a7} ",  -- nf-md-magnify
    },
    style    = "fancy",
    top_down = true,
  },

  -- ── Word highlight ────────────────────────────────────────────────────────
  words = { enabled = true },

  -- ── Terminal ──────────────────────────────────────────────────────────────
  terminal = {
    enabled = true,
    win = {
      border       = s.menu_border or "rounded",
      winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
      wo = {
        winbar      = "",
        statuscolumn = "  ",
      },
    },
  },

  -- ── Git integrations ─────────────────────────────────────────────────────
  lazygit   = { enabled = true },
  gitbrowse = { enabled = true },

  -- ── Other ────────────────────────────────────────────────────────────────
  rename    = { enabled = true },
  input     = { enabled = true },
  quickfile = { enabled = true },

  -- ── Image preview ─────────────────────────────────────────────────────────
  image = {
    enabled = true,
    force   = true,
    formats = {
      "png", "jpg", "jpeg", "gif", "bmp", "webp",
      "tiff", "heic", "avif", "mp4", "mov", "avi",
      "mkv", "webm", "pdf", "icns", "svg",
    },
    convert = { notify = true },
  },
}
