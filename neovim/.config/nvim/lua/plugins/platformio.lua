return {
  "anurag3301/nvim-platformio.lua",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    "akinsho/toggleterm.nvim",
  },
  config = function()
    require("platformio").setup({
      lsp = "clangd",
    })
  end,
}
