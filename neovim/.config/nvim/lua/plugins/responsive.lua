return {
  -- Aerial: Document Outline & Table of Contents browser
  {
    "stevearc/aerial.nvim",
    opts = {
      backends = { "treesitter", "markdown", "lsp" },
      layout = {
        default_direction = "left",
        width = 30,
        min_width = 24,
      },
      show_guides = true,
      filter_kind = false,
    },
    keys = {
      { "<leader>co", "<cmd>AerialToggle<cr>", desc = "Document Outline (Aerial)" },
      { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Document Outline (Aerial)" },
    },
  },
}
