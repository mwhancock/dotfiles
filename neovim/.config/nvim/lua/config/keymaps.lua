-- Keymaps are automatically loaded on the VeryLazy event

-- Markdown export function
local function export_markdown(format)
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.bo[bufnr].filetype

  if filepath == "" then
    vim.notify("Please save the file first before exporting.", vim.log.levels.WARN, {
      title = "Markdown Export",
    })
    return
  end

  if filetype ~= "markdown" and not filepath:match("%.md$") then
    vim.notify("Current buffer is not a markdown file!", vim.log.levels.WARN, {
      title = "Markdown Export",
    })
    return
  end

  -- Save buffer if modified
  if vim.bo[bufnr].modified then
    vim.cmd("silent write")
  end

  local ext = format == "pdf" and ".pdf" or ".docx"
  local output_path = filepath:gsub("%.%w+$", "") .. ext
  local basename = vim.fs.basename(filepath)
  local outname = vim.fs.basename(output_path)

  vim.notify("Exporting " .. basename .. " to " .. format:upper() .. " (with diagrams & LaTeX)...", vim.log.levels.INFO, {
    title = "Markdown Export",
  })

  local cmd = { "md-export", filepath, format, output_path }

  vim.system(cmd, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code == 0 then
        vim.notify("✓ Successfully exported " .. outname, vim.log.levels.INFO, {
          title = "Markdown Export",
          timeout = 5000,
        })
      else
        local err = obj.stderr or obj.stdout or "Export failed"
        vim.notify("✗ Export failed (" .. format:upper() .. "):\n" .. err, vim.log.levels.ERROR, {
          title = "Markdown Export",
          timeout = 8000,
        })
      end
    end)
  end)
end

-- Keybindings for Markdown Export
vim.keymap.set("n", "<leader>op", function() export_markdown("pdf") end, { desc = "Export Markdown to PDF" })
vim.keymap.set("n", "<leader>od", function() export_markdown("docx") end, { desc = "Export Markdown to DOCX" })

-- Buffer navigation convenience
vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })

-- Floating cheatsheet viewer
local function open_formatting_cheatsheet()
  local path = vim.fn.expand("~/.config/nvim/formatting_cheatsheet.md")
  local buf = vim.fn.bufnr(path, false)
  if buf == -1 then
    buf = vim.fn.bufadd(path)
  end
  vim.fn.bufload(buf)

  local width = math.min(120, math.floor(vim.o.columns * 0.85))
  local height = math.min(40, math.floor(vim.o.lines * 0.85))
  local row = math.max(1, math.floor((vim.o.lines - height) / 2))
  local col = math.max(1, math.floor((vim.o.columns - width) / 2))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " 󰈙 Formatting Cheatsheet (Markdown / Mermaid / LaTeX) — Press 'q' to close ",
    title_pos = "center",
  })

  vim.bo[buf].modifiable = false
  local close_win = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.keymap.set("n", "q", close_win, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "<Esc>", close_win, { buffer = buf, nowait = true, silent = true })
end

vim.keymap.set("n", "<leader>ch", open_formatting_cheatsheet, { desc = "Formatting Cheatsheet (Float)" })
vim.keymap.set("n", "<leader>?", open_formatting_cheatsheet, { desc = "Formatting Cheatsheet (Float)" })

