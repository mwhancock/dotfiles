-- Inline suggestions from a local Ollama model, offline.
--
-- Minuet renders suggestions as virtual text rather than in the completion menu.
-- That is deliberate: the menu is already configured to stay closed until asked
-- for (lua/plugins/completion.lua sets menu.auto_show = false), and ghost text
-- keeps that distinction -- AI suggestions appear inline, the menu stays shut.
--
-- Model: qwen2.5-coder:7b, not qwen3.5:4b. Measured on this machine through this
-- exact code path (median of 3, warm):
--
--                        end of line      mid-file
--   qwen2.5-coder:7b FIM      150ms          ~450ms
--   qwen3.5:4b chat           399ms          555ms
--
-- The 7b is faster despite generating tokens more slowly (15 vs 29 tok/s),
-- because it supports fill-in-the-middle: this goes to /completions with a bare
-- prefix+suffix prompt instead of /chat/completions with a system prompt and
-- few-shot examples, and it processes prompts at roughly twice the rate (932 vs
-- 438 tok/s). It is also not a thinking model, so there is no reasoning step to
-- suppress -- with qwen3.5 the equivalent config needed reasoning_effort = "none"
-- or every request took 15s+ and returned empty content.
--
-- Each of the three facts above matters; swapping the model back means changing
-- all of: provider, end_point, model, and dropping `stop`.
return {
  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    opts = {
      provider = "openai_fim_compatible",
      -- One completion per request. Anything more multiplies the work on an
      -- integrated GPU for no benefit.
      n_completions = 1,
      -- Characters, not tokens. Smaller means less prompt to process per
      -- keystroke burst, and prompt processing is the latency here.
      context_window = 4000,
      context_ratio = 0.75,
      debounce = 400,
      throttle = 1500,
      request_timeout = 8,
      notify = "warn",
      provider_options = {
        openai_fim_compatible = {
          model = "qwen2.5-coder:7b",
          end_point = "http://127.0.0.1:11434/v1/completions",
          -- Ollama ignores the value but the field has to be present. A function
          -- avoids inventing an environment variable just to hold a placeholder.
          api_key = function()
            return "ollama"
          end,
          name = "Ollama",
          stream = true,
          optional = {
            max_tokens = 48,
            temperature = 0.2,
            top_p = 0.95,
            -- One line only. With no stop, a 7b FIM model runs on and appends a
            -- duplicate `end` for the closed function below the cursor, so the
            -- ghost text reads as a correct answer that would break the code if
            -- accepted. minuet's after_cursor_filter_length does not trim it
            -- (tried 4 and 10; both still returned "b\nend"). Multi-line is still
            -- reachable by changing this to { "\n\n" } and accepting line by line
            -- with <C-Down>, at the cost of that trailing `end`.
            stop = { "\n" },
          },
        },
      },
      virtualtext = {
        -- Code only. Completing prose in markdown, or keys in json/toml/yaml,
        -- is mostly noise; those filetypes can still be completed on demand
        -- with the next/prev key below.
        auto_trigger_ft = {
          "c",
          "cpp",
          "rust",
          "java",
          "kotlin",
          "python",
          "lua",
          "sh",
          "bash",
          "nix",
          "php",
          "sql",
          "cmake",
        },
        keymap = {
          accept = "<M-l>",
          accept_line = "<C-Down>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<M-e>",
        },
      },
    },
    keys = {
      {
        "<leader>uA",
        "<cmd>Minuet virtualtext toggle<cr>",
        desc = "Toggle AI inline suggestions (buffer)",
      },
    },
  },
}
