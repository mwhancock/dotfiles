return {
  "nvim-mini/mini.nvim",
  version = false,
  config = function()
    local mini_map = require("mini.map")
    mini_map.setup({
      symbols = {
        encode = mini_map.gen_encode_symbols.dot("4x2"),
      },
      window = {
        width = 20,
      },
    })

    vim.keymap.set("n", "<leader>mc", mini_map.close, { desc = "Close Minimap" })
    vim.keymap.set("n", "<leader>mf", mini_map.toggle_focus, { desc = "Toggle Minimap Focus" })
    vim.keymap.set("n", "<leader>mm", mini_map.toggle, { desc = "Toggle Minimap" })
  end,
}
