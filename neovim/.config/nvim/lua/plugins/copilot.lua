return {
  "zbirenbaum/copilot.lua",
  enabled = false, -- Disabled: set to true if you ever want to install and enable GitHub Copilot
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = false,
      keymap = {
        accept = "<M-l>",
        toggle_copilot = "<M-o>",
      },
    },
  },
}
