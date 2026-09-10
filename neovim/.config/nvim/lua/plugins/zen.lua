return {
  -- No-neck-pain: centers buffer / constrains width to 2/3 of the screen
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    event = "VeryLazy",
    opts = function()
      local cols = vim.o.columns
      -- Target 2/3 (67%) of the screen width, with minimum 80 columns
      local target_width = math.max(80, math.floor(cols * 0.67))

      return {
        width = target_width,
        minSideBufferWidth = 8,
        autocmds = {
          enableOnVimEnter = false,
          enableOnTabEnter = false,
          reloadOnFileSizeChange = false,
          skipEnteringNoNeckPainBuffer = true,
        },
        integrations = {
          neoTree = {
            position = "left",
            reopen = true,
          },
        },
        buffers = {
          -- Transparent side buffers to keep Ghostty's blur and opacity
          colors = {
            background = "NONE",
            blend = 0,
          },
          bo = {
            filetype = "no-neck-pain",
            buftype = "nofile",
          },
          wo = {
            fillchars = "eob: ",
            winhighlight = "Normal:Normal,NormalNC:NormalNC",
          },
        },
      }
    end,
    keys = {
      { "<leader>uz", "<cmd>NoNeckPain<cr>", desc = "Toggle 2/3 Width View (NoNeckPain)" },
      { "<leader>nn", "<cmd>NoNeckPain<cr>", desc = "Toggle 2/3 Width View (NoNeckPain)" },
      { "<leader>nl", "<cmd>lua require('no-neck-pain').toggle_side('left')<cr>", desc = "Toggle Left Margin (Left-align / Center)" },
    },
    config = function(_, opts)
      local nnp = require("no-neck-pain")
      nnp.setup(opts)

      -- Dynamically update width on window resize so it always stays ~2/3 of screen
      vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("no_neck_pain_auto_resize", { clear = true }),
        callback = function()
          local target = math.max(80, math.floor(vim.o.columns * 0.67))
          if _G.NoNeckPain and _G.NoNeckPain.state and _G.NoNeckPain.state.enabled then
            pcall(nnp.resize, target)
          end
        end,
      })
    end,
  },

  -- Also configure Snacks.zen to 2/3 width
  {
    "folke/snacks.nvim",
    opts = {
      zen = {
        win = {
          width = math.max(80, math.floor(vim.o.columns * 0.67)),
        },
      },
    },
  },
}
