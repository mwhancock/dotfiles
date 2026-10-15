return {
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          position = "right",
          width = 0.4,
          on_win = function()
            local ok, minimap = pcall(require, "neominimap.api")
            if ok and minimap.enabled() then
              vim.g.minimap_reopen = true
              minimap.disable()
            end
          end,
          on_close = function()
            if vim.g.minimap_reopen then
              vim.g.minimap_reopen = false
              local ok, minimap = pcall(require, "neominimap.api")
              if ok then
                minimap.enable()
              end
            end
          end,
        },
      },
    },
  },
}
