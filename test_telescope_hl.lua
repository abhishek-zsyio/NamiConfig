local function set_telescope_nvchad_hl()
  local get_hl = vim.api.nvim_get_hl
  local set_hl = vim.api.nvim_set_hl

  -- Helper to get background of a group
  local function get_bg(group)
    local hl = get_hl(0, { name = group, link = false })
    return hl and hl.bg or nil
  end

  local function get_fg(group)
    local hl = get_hl(0, { name = group, link = false })
    return hl and hl.fg or nil
  end

  local bg = get_bg("Normal") or get_bg("NormalFloat")
  local fg = get_fg("Normal")
  local alt_bg = get_bg("CursorLine") or get_bg("ColorColumn") or get_bg("StatusLine")

  if not bg then return end
  if not alt_bg then alt_bg = bg end

  -- Telescope highlights
  set_hl(0, "TelescopePromptNormal", { bg = alt_bg, fg = fg })
  set_hl(0, "TelescopePromptBorder", { bg = alt_bg, fg = alt_bg })
  set_hl(0, "TelescopeResultsNormal", { bg = bg, fg = fg })
  set_hl(0, "TelescopeResultsBorder", { bg = bg, fg = bg })
  set_hl(0, "TelescopePreviewNormal", { bg = alt_bg, fg = fg })
  set_hl(0, "TelescopePreviewBorder", { bg = alt_bg, fg = alt_bg })

  -- Titles
  local accent = get_fg("Function") or get_fg("Keyword") or get_fg("String")
  set_hl(0, "TelescopePromptTitle", { bg = accent, fg = bg, bold = true })
  set_hl(0, "TelescopePreviewTitle", { bg = alt_bg, fg = alt_bg }) -- Hide preview title background? No, NvChad has it like the prompt
  set_hl(0, "TelescopeResultsTitle", { bg = bg, fg = bg }) -- Usually hidden
end
