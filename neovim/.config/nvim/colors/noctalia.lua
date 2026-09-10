-- Noctalia colorscheme for Neovim (matches Ghostty & Noctalia theme with transparency)
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "noctalia"
vim.o.termguicolors = true

local ok_matugen, matugen = pcall(require, "matugen")
if ok_matugen and matugen.setup then
  matugen.setup()
else
  local ok_b16, b16 = pcall(require, "base16-colorscheme")
  if ok_b16 then
    b16.setup({
      base00 = "#32302f",
      base01 = "#3c3836",
      base02 = "#474240",
      base03 = "#7f7873",
      base04 = "#d4be98",
      base05 = "#ddc7a1",
      base06 = "#ddc7a1",
      base07 = "#ebdbb2",
      base08 = "#ea6962",
      base09 = "#89b482",
      base0A = "#e78a4e",
      base0B = "#a9b665",
      base0C = "#7daea3",
      base0D = "#7daea3",
      base0E = "#d3869b",
      base0F = "#d8a657",
    })
  end
end

-- Custom UI Highlights for LazyVim integration & Ghostty transparency
local hl = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local bg1 = "#3c3836"
local bg2 = "#474240"
local fg0 = "#ddc7a1"
local fg_dim = "#7f7873"
local green = "#a9b665"
local orange = "#e78a4e"
local red = "#ea6962"
local blue = "#7daea3"
local aqua = "#89b482"
local yellow = "#d8a657"

-- Core Neovim UI: transparent backgrounds to preserve Ghostty opacity & blur
hl("Normal", { fg = fg0, bg = "NONE" })
hl("NormalNC", { fg = fg0, bg = "NONE" })
hl("SignColumn", { fg = fg_dim, bg = "NONE" })
hl("FoldColumn", { fg = fg_dim, bg = "NONE" })
hl("LineNr", { fg = fg_dim, bg = "NONE" })
hl("CursorLineNr", { fg = yellow, bg = "NONE", bold = true })
hl("EndOfBuffer", { fg = "NONE", bg = "NONE" })
hl("CursorLine", { bg = "#383533" })
hl("Visual", { bg = bg2 })
hl("NormalFloat", { fg = fg0, bg = "NONE" })
hl("FloatBorder", { fg = fg_dim, bg = "NONE" })
hl("WinSeparator", { fg = bg2, bg = "NONE" })

-- Neo-Tree transparent
hl("NeoTreeNormal", { fg = fg0, bg = "NONE" })
hl("NeoTreeNormalNC", { fg = fg0, bg = "NONE" })
hl("NeoTreeEndOfBuffer", { fg = "NONE", bg = "NONE" })
hl("NeoTreeWinSeparator", { fg = bg2, bg = "NONE" })
hl("NeoTreeDirectoryName", { fg = blue, bold = true })
hl("NeoTreeDirectoryIcon", { fg = blue })
hl("NeoTreeFileName", { fg = fg0 })
hl("NeoTreeFileNameOpened", { fg = green, bold = true })
hl("NeoTreeRootName", { fg = orange, bold = true })
hl("NeoTreeGitAdded", { fg = green })
hl("NeoTreeGitModified", { fg = yellow })
hl("NeoTreeGitDeleted", { fg = red })
hl("NeoTreeGitUntracked", { fg = aqua, italic = true })
hl("NeoTreeIndentMarker", { fg = bg2 })

-- Bufferline transparent
hl("BufferLineFill", { bg = "NONE" })
hl("BufferLineBackground", { fg = fg_dim, bg = "NONE" })
hl("BufferLineBufferSelected", { fg = fg0, bg = bg1, bold = true })
hl("BufferLineBufferVisible", { fg = fg0, bg = "NONE" })
hl("BufferLineSeparator", { fg = bg2, bg = "NONE" })
hl("BufferLineSeparatorSelected", { fg = bg2, bg = bg1 })
hl("BufferLineIndicatorSelected", { fg = green, bg = bg1 })

-- Diagnostics
hl("DiagnosticError", { fg = red })
hl("DiagnosticWarn", { fg = yellow })
hl("DiagnosticInfo", { fg = blue })
hl("DiagnosticHint", { fg = aqua })

-- Minimap
hl("NeominimapCurrentLine", { bg = bg2 })
hl("NeominimapBorder", { fg = fg_dim })
