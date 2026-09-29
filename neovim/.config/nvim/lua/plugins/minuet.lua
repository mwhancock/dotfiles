return {
  "milanglacier/minuet-ai.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = "InsertEnter",
  keys = {
    {
      "<leader>ua",
      function()
        vim.cmd("Minuet virtualtext toggle")
        vim.notify("Toggled AI Autocomplete (Minuet)", vim.log.levels.INFO, { title = "Minuet AI" })
      end,
      desc = "Toggle AI Autocomplete",
    },
    {
      "<leader>ta",
      function()
        vim.cmd("Minuet virtualtext toggle")
        vim.notify("Toggled AI Autocomplete (Minuet)", vim.log.levels.INFO, { title = "Minuet AI" })
      end,
      desc = "Toggle AI Autocomplete",
    },
  },
  opts = {
    virtualtext = {
      auto_trigger_ft = { "*" },
      keymap = {
        accept = "<M-l>", -- Alt+l to accept (same muscle memory as copilot.lua)
        accept_line = "<M-a>",
        prev = "<M-[>",
        next = "<M-]>",
        dismiss = "<M-e>",
      },
    },
    provider = "openai_fim_compatible",
    provider_options = {
      openai_fim_compatible = {
        api_key = "TERM",
        name = "Ollama",
        end_point = "http://localhost:11434/v1/completions",
        model = "qwen2.5-coder:1.5b",
        optional = {
          max_tokens = 256,
          top_p = 0.9,
        },
      },
    },
  },
}
