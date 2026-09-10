return {
  -- Treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "c",
        "cpp",
        "rust",
        "ron",
        "java",
        "python",
        "ninja",
        "rst",
        "markdown",
        "markdown_inline",
        "bash",
        "lua",
        "toml",
        "json",
        "yaml",
        "latex",
        "cmake",
        "make",
      })
    end,
  },

  -- Mason ensure installed tools
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "codelldb",
        "jdtls",
        "clangd",
        "marksman",
        "java-debug-adapter",
        "java-test",
        "pyright",
        "ruff",
        "debugpy",
      })
    end,
  },

  -- Disable markdown style linting for markdown documents (no line-length, blank-line, or HTML errors)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
        ["markdown.mdx"] = {},
      },
    },
  },

  -- Clean formatters for markdown
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
      },
    },
  },
}
