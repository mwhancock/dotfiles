-- Sourced after the runtime ftplugin/indent scripts, so this FileType autocmd
-- is registered last and wins over their per-buffer settings.
vim.api.nvim_create_autocmd({ "FileType", "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("FourSpaceIndent", { clear = true }),
  pattern = "*",
  callback = function()
    -- Make recipes are tabs by definition; overriding them breaks builds.
    if vim.bo.filetype == "make" then
      return
    end
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
    vim.bo.shiftwidth = 4
  end,
})
