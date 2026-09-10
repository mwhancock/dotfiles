-- Markdown buffer settings: 88-character textwidth & hard wrapping
vim.opt_local.textwidth = 88
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.colorcolumn = "89"
vim.opt_local.spell = false

-- Formatoptions:
-- 't' auto-wraps text using textwidth as you type
-- 'c' auto-wraps comments
-- 'r' auto-inserts comment leader
-- 'q' enables formatting with 'gq'
-- 'n' recognizes numbered lists
-- 'j' removes comment leader when joining lines
vim.opt_local.formatoptions = "tcroqnj"

-- Silence all virtual text error messages, signs, and underlines in markdown
vim.diagnostic.config({
  virtual_text = false,
  signs = false,
  underline = false,
}, vim.api.nvim_get_current_buf())
