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
local purple = "#d3869b"

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

-- ============================================================================
-- Complete Syntax & Treesitter Highlighting (Noctalia / Gruvbox-Material Palette)
-- ============================================================================

-- Comments
hl("Comment", { fg = fg_dim, italic = true })
hl("@comment", { link = "Comment" })
hl("@comment.documentation", { fg = fg_dim, italic = true })

-- Keywords & Control flow
hl("Keyword", { fg = red })
hl("@keyword", { fg = red })
hl("@keyword.coroutine", { fg = red })
hl("@keyword.function", { fg = red })
hl("@keyword.operator", { fg = orange })
hl("@keyword.return", { fg = red })
hl("@keyword.conditional", { fg = red })
hl("@keyword.repeat", { fg = red })
hl("@keyword.exception", { fg = red })

-- Types & classes
hl("Type", { fg = yellow })
hl("@type", { fg = yellow })
hl("@type.builtin", { fg = yellow, italic = true })
hl("@type.definition", { fg = yellow })
hl("@type.qualifier", { fg = orange })
hl("@keyword.type", { fg = orange })
hl("@keyword.modifier", { fg = orange })
hl("StorageClass", { fg = orange })
hl("Structure", { fg = orange })
hl("Typedef", { fg = yellow })

-- Functions & methods
hl("Function", { fg = green })
hl("@function", { fg = green })
hl("@function.call", { fg = green })
hl("@function.method", { fg = green })
hl("@function.method.call", { fg = green })
hl("@function.builtin", { fg = green })
hl("@function.macro", { fg = purple })

-- Identifiers & variables
hl("Identifier", { fg = fg0 })
hl("@variable", { fg = fg0 })
hl("@variable.builtin", { fg = red })
hl("@variable.parameter", { fg = fg0 })
hl("@variable.member", { fg = fg0 })
hl("@property", { fg = fg0 })

-- Constants, numbers, booleans
hl("Constant", { fg = purple })
hl("@constant", { fg = purple })
hl("@constant.builtin", { fg = purple })
hl("@constant.macro", { fg = purple })
hl("Number", { fg = purple })
hl("@number", { fg = purple })
hl("@number.float", { fg = purple })
hl("Boolean", { fg = purple })
hl("@boolean", { fg = purple })

-- Strings & Characters
hl("String", { fg = aqua })
hl("@string", { fg = aqua })
hl("@string.escape", { fg = orange })
hl("@string.regex", { fg = orange })
hl("Character", { fg = aqua })

-- Preprocessor directives (#include, #define, #ifdef, etc.)
hl("PreProc", { fg = purple })
hl("@keyword.import", { fg = purple })
hl("@keyword.directive", { fg = purple })
hl("@keyword.directive.define", { fg = purple })
hl("Include", { fg = purple })
hl("Define", { fg = purple })
hl("Macro", { fg = purple })

-- Operators & Punctuation
hl("Operator", { fg = orange })
hl("@operator", { fg = orange })
hl("@punctuation.delimiter", { fg = fg_dim })
hl("@punctuation.bracket", { fg = fg0 })
hl("@punctuation.special", { fg = orange })

-- ============================================================================
-- LSP Semantic Token Bindings
-- ============================================================================
hl("@lsp.type.class", { link = "@type" })
hl("@lsp.type.struct", { link = "@type" })
hl("@lsp.type.enum", { link = "@type" })
hl("@lsp.type.type", { link = "@type" })
hl("@lsp.type.typeParameter", { link = "@type" })
hl("@lsp.type.function", { link = "@function" })
hl("@lsp.type.method", { link = "@function.method" })
hl("@lsp.type.macro", { link = "@constant.macro" })
hl("@lsp.type.enumMember", { link = "@constant" })
hl("@lsp.type.property", { link = "@property" })
hl("@lsp.type.variable", { link = "@variable" })
hl("@lsp.type.parameter", { link = "@variable.parameter" })
hl("@lsp.type.namespace", { fg = blue })
hl("@lsp.type.modifier", { link = "@keyword.modifier" })

-- Clear LSP comment token so inactive #ifdef code doesn't get grayed out into an unreadable monochrome blob
hl("@lsp.type.comment", {})
hl("@lsp.type.comment.c", {})
hl("@lsp.type.comment.cpp", {})
