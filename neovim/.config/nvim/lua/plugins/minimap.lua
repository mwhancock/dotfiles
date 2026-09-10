return {
  {
    "Isrothy/neominimap.nvim",
    version = "v3.x.x",
    lazy = false,
    init = function()
      vim.g.neominimap = {
        auto_enable = false,
        log_level = vim.log.levels.OFF,
        notification_level = vim.log.levels.WARN,
        layout = "split",
        split = {
          direction = "right",
          minimap_width = 18,
          fix_width = true,
          persist = false,
        },
        exclude_filetypes = {
          "help",
          "bigfile",
          "neo-tree",
          "neo-tree-popup",
          "notify",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "aerial",
        },
        treesitter = {
          enabled = true,
          priority = 200,
        },
        git = {
          enabled = true,
          mode = "sign",
        },
        diagnostic = {
          enabled = true,
          severity = vim.diagnostic.severity.WARN,
          mode = "line",
        },
      }
    end,
    keys = {
      { "<leader>nm", "<cmd>Neominimap toggle<cr>", desc = "Toggle Minimap" },
      { "<leader>um", "<cmd>Neominimap toggle<cr>", desc = "Toggle Minimap" },
      { "<leader>no", "<cmd>Neominimap Enable<cr>", desc = "Enable Minimap" },
      { "<leader>nc", "<cmd>Neominimap Disable<cr>", desc = "Disable Minimap" },
      { "<leader>nr", "<cmd>Neominimap Refresh<cr>", desc = "Refresh Minimap" },
    },
  },
}
