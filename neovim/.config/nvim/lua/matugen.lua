 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#16130f',
    base01 = '#221f1a',
    base02 = '#2d2925',
    base03 = '#998f81',
    base04 = '#d1c5b5',
    base05 = '#e9e1da',
    base06 = '#e9e1da',
    base07 = '#e9e1da',
    base08 = '#ffb4ab',
    base09 = '#becd91',
    base0A = '#d8c4a5',
    base0B = '#e6c181',
    base0C = '#becd91',
    base0D = '#e6c181',
    base0E = '#d8c4a5',
    base0F = '#f5e0bf',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e9e1da',          bg = '#16130f' })
  hi('TelescopeBorder',         { fg = '#998f81',             bg = '#16130f' })
  hi('TelescopePromptNormal',   { fg = '#e9e1da',          bg = '#16130f' })
  hi('TelescopePromptBorder',   { fg = '#998f81',             bg = '#16130f' })
  hi('TelescopePromptPrefix',   { fg = '#e6c181',             bg = '#16130f' })
  hi('TelescopePromptCounter',  { fg = '#d1c5b5',  bg = '#16130f' })
  hi('TelescopePromptTitle',    { fg = '#16130f',             bg = '#e6c181' })
  hi('TelescopePreviewTitle',   { fg = '#16130f',             bg = '#d8c4a5' })
  hi('TelescopeResultsTitle',   { fg = '#16130f',             bg = '#becd91' })
  hi('TelescopeSelection',      { fg = '#e9e1da',          bg = '#2d2925' })
  hi('TelescopeSelectionCaret', { fg = '#e6c181',             bg = '#2d2925' })
  hi('TelescopeMatching',       { fg = '#e6c181',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e9e1da',          bg = '#16130f' })
  hi('MiniPickBorder',         { fg = '#998f81',             bg = '#16130f' })
  hi('MiniPickPrompt',   { fg = '#e9e1da',          bg = '#16130f' })
  hi('MiniPickPromptPrefix',   { fg = '#e6c181',             bg = '#16130f' })
  hi('MiniPickBorderText',    { fg = '#16130f',             bg = '#e6c181' })
  hi('MiniPickMatchCurrent',      { fg = '#e9e1da',          bg = '#2d2925' })
  hi('MiniPickPromptCaret', { fg = '#e6c181',             bg = '#2d2925' })
  hi('MiniPickMatchRanges',       { fg = '#e6c181',             bold = true })
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
