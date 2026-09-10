return {
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      pcall(vim.cmd.colorscheme, "noctalia")
    end,
  },

  -- Keep Ghostty's transparency throughout all Neovim UI elements
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      extra_groups = {
        "Normal",
        "NormalNC",
        "NormalFloat",
        "FloatBorder",
        "SignColumn",
        "LineNr",
        "EndOfBuffer",
        "NeoTreeNormal",
        "NeoTreeNormalNC",
        "NeoTreeEndOfBuffer",
        "NeoTreeWinSeparator",
        "BufferLineFill",
        "BufferLineBackground",
        "BufferLineBufferVisible",
        "BufferLineSeparator",
        "BufferLineSeparatorVisible",
        "WhichKeyFloat",
        "WhichKeyNormal",
        "SnacksDashboardNormal",
        "SnacksPickerNormal",
        "TelescopeNormal",
        "TelescopeBorder",
        "NoNeckPain",
        "NoNeckPainLeft",
        "NoNeckPainRight",
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "noctalia",
      news = {
        lazyvim = false,
        neovim = false,
      },
    },
  },
}
