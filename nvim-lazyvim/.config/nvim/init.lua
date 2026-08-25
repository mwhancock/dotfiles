-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.opt.tabstop = 4 -- Number of visual spaces per tab
vim.opt.shiftwidth = 4 -- Number of spaces to use for autoindent
vim.opt.expandtab = true -- Convert tabs to spaces

-- autosave settings
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
  pattern = "*",
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! update")
    end
  end,
})
