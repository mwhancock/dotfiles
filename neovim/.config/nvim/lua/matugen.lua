 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#17130b',
    base01 = '#241f17',
    base02 = '#2f2921',
    base03 = '#9a8f80',
    base04 = '#d1c5b4',
    base05 = '#ece1d4',
    base06 = '#ece1d4',
    base07 = '#ece1d4',
    base08 = '#ffb4ab',
    base09 = '#b2cfa7',
    base0A = '#d9c4a0',
    base0B = '#ecc06c',
    base0C = '#b2cfa7',
    base0D = '#ecc06c',
    base0E = '#d9c4a0',
    base0F = '#f6e0bb',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#ece1d4',          bg = '#17130b' })
  hi('TelescopeBorder',         { fg = '#9a8f80',             bg = '#17130b' })
  hi('TelescopePromptNormal',   { fg = '#ece1d4',          bg = '#17130b' })
  hi('TelescopePromptBorder',   { fg = '#9a8f80',             bg = '#17130b' })
  hi('TelescopePromptPrefix',   { fg = '#ecc06c',             bg = '#17130b' })
  hi('TelescopePromptCounter',  { fg = '#d1c5b4',  bg = '#17130b' })
  hi('TelescopePromptTitle',    { fg = '#17130b',             bg = '#ecc06c' })
  hi('TelescopePreviewTitle',   { fg = '#17130b',             bg = '#d9c4a0' })
  hi('TelescopeResultsTitle',   { fg = '#17130b',             bg = '#b2cfa7' })
  hi('TelescopeSelection',      { fg = '#ece1d4',          bg = '#2f2921' })
  hi('TelescopeSelectionCaret', { fg = '#ecc06c',             bg = '#2f2921' })
  hi('TelescopeMatching',       { fg = '#ecc06c',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
