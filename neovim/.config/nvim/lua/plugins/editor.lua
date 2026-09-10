return {
  -- Neo-tree file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
      },
      window = {
        width = 32,
      },
    },
  },

  -- Oil.nvim for fast buffer-style file operations
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory (Oil)" },
    },
    opts = {
      view_options = {
        show_hidden = true,
      },
    },
  },

  -- Which-key group labels
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>o", group = "export/open", icon = " " },
        { "<leader>n", group = "minimap", icon = "󰍍 " },
      },
    },
  },
}
