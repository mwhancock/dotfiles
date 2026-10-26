-- MySQL support for the `lang.sql` extra.
--
-- The extra already brings in the `sql` tree-sitter parser, vim-dadbod and
-- sqlfluff. What it does not do is pick a dialect, and sqlfluff's default is
-- `ansi`. That default cannot parse MySQL-isms such as backtick-quoted
-- identifiers, AUTO_INCREMENT or ENGINE=InnoDB, so every MySQL script reports
-- a PRS parse error and the formatter refuses to run. Fix the dialect here.
--
-- Two smaller gaps are covered as well:
--
--   * `*.mysql` is not in Neovim's filetype table, even though the runtime
--     ships syntax/mysql.vim. Register the extension.
--   * syntax/sql.vim defaults to "sqloracle" for its regex fallback. Point it
--     at mysql so the regions tree-sitter leaves uncovered -- DELIMITER blocks
--     in stored-procedure scripts, for instance -- still highlight as MySQL.
--     Tree-sitter remains the primary highlighter.

vim.filetype.add({ extension = { mysql = "mysql" } })

-- Serve the `mysql` filetype with the `sql` parser.
vim.treesitter.language.register("sql", "mysql")

-- Regex-syntax fallback for both ft=sql and ft=mysql.
vim.g.sql_type_default = "mysql"

return {
  -- Lint with the MySQL dialect. The args replace nvim-lint's built-in list,
  -- so keep `--format=json`; the linter's parser expects it.
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        sqlfluff = {
          args = { "lint", "--format=json", "--dialect=mysql", "-" },
        },
      },
    },
  },

  -- Same dialect for formatting.
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        sqlfluff = {
          args = { "format", "--dialect=mysql", "-" },
        },
      },
    },
  },
}
