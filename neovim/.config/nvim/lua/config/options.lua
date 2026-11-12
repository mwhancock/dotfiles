-- Options are automatically loaded before lazy.nvim startup

-- Four space tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- ftplugins override the globals above per buffer (Arduino asks for 2 spaces,
-- Go and Make for real tabs, ...). after/plugin/four-space-indent.lua puts them
-- back to 4 spaces once those scripts have run, for every filetype.

-- Dynamic text wrapping depending on window size
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↳ "

-- Line numbers & UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.termguicolors = true
vim.opt.cursorline = true

-- Global statusline
vim.opt.laststatus = 3

-- Project-local configuration. Nvim 0.12 only executes .nvim.lua/.nvimrc/.exrc
-- files that are in its trust database (manage with :trust), so this is safe.
-- The iso_mist project uses it to set the rust_analyzer target.
vim.opt.exrc = true
