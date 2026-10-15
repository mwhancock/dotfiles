-- Format every ```mermaid fenced block in a buffer with mermaidfmt.
--
-- On demand rather than on save: mermaid-formatter flattens the indentation
-- inside an ER `entity { ... }` block, so running it automatically would make a
-- relational diagram less readable on every write. Sequence and flowchart
-- blocks it handles well. Invoke only when wanted, then `u` undoes it.
--
-- The binary comes from modules/packages/mermaid-formatter.nix.

local M = {}

---@class MermaidFormatResult
---@field changed integer  blocks rewritten
---@field total integer    mermaid blocks found

---@param bufnr integer?
---@return boolean ok
---@return MermaidFormatResult|string  result on success, error message on failure
function M.format_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.fn.executable("mermaidfmt") ~= 1 then
    return false, "mermaidfmt not found on PATH (see modules/packages/mermaid-formatter.nix)."
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Collect the fence ranges first; edit afterwards so line numbers stay valid.
  local blocks = {}
  local i = 1
  while i <= #lines do
    if lines[i]:match("^%s*```+%s*mermaid%s*$") then
      local j = i + 1
      while j <= #lines and not lines[j]:match("^%s*```+%s*$") do
        j = j + 1
      end
      if j <= #lines then
        table.insert(blocks, { start = i, stop = j })
        i = j
      end
    end
    i = i + 1
  end

  local changed = 0
  -- Bottom-up, so replacing one block does not shift the lines of the next.
  for b = #blocks, 1, -1 do
    local block = blocks[b]
    local content = vim.list_slice(lines, block.start + 1, block.stop - 1)
    local input = table.concat(content, "\n") .. "\n"

    local ok, obj = pcall(function()
      return vim.system({ "mermaidfmt" }, { stdin = input, text = true }):wait()
    end)

    if not ok then
      return false, "mermaid block at line " .. block.start .. " could not run: " .. tostring(obj)
    end
    if obj.code ~= 0 then
      local err = (obj.stderr ~= "" and obj.stderr) or obj.stdout or "unknown error"
      return false, "mermaid block at line " .. block.start .. " failed:\n" .. err
    end

    local formatted = vim.split(obj.stdout, "\n", { plain = true })
    if formatted[#formatted] == "" then
      table.remove(formatted)
    end

    if not vim.deep_equal(content, formatted) then
      vim.api.nvim_buf_set_lines(bufnr, block.start, block.stop - 1, false, formatted)
      changed = changed + 1
    end
  end

  return true, { changed = changed, total = #blocks }
end

return M
