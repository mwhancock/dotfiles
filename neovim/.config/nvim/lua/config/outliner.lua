-- Logseq-style list editing for markdown buffers.
--
-- Attached per buffer by the FileType autocmd in config/autocmds.lua, so every
-- mapping here is buffer-local and no other filetype is touched.
--
--   <CR>        continue the list. Numbered items increment, task items get a
--               fresh unchecked box, bullets repeat. Enter on an item with no
--               text removes the marker instead, which is how you leave a list.
--   <Tab>       indent the current item (visual mode: the selected lines).
--   <S-Tab>     outdent one level.
--   o / O       open a new sibling item below / above.
--   <leader>mt  toggle the checkbox on the current line / selection.
--
-- Ordered lists are renumbered after anything that adds or moves an item.
-- Normal-mode <Tab>/<S-Tab> off a list item still fall back to the global
-- buffer navigation in config/keymaps.lua.

local M = {}

local api = vim.api
local fn = vim.fn

-- Feed literal keys, never re-triggering our own mappings.
local function feed(keys)
  api.nvim_feedkeys(api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

-- One shiftwidth of spaces, or a tab when expandtab is off. shiftwidth 0 means
-- "follow tabstop".
local function indent_unit(buf)
  if not vim.bo[buf].expandtab then
    return "\t"
  end
  local sw = vim.bo[buf].shiftwidth
  if sw == 0 then
    sw = vim.bo[buf].tabstop
  end
  return string.rep(" ", sw)
end

-- Split a list line into indent + marker + text, or nil when it is not one.
-- A bare "*" only counts when followed by whitespace, so **bold** is left alone.
local function parse_item(line)
  local indent, bullet, text = line:match("^(%s*)([-*+])%s+(.*)$")
  if bullet then
    return { indent = indent, kind = "bullet", bullet = bullet, text = text }
  end
  local ind, num, delim, txt = line:match("^(%s*)(%d+)([.)])%s+(.*)$")
  if num then
    return { indent = ind, kind = "ordered", num = tonumber(num), delim = delim, text = txt }
  end
  return nil
end

-- Whether a task item, and if so the text after its "[ ]".
local function task_body(text)
  return text:match("^%[[ xX]%]%s*(.*)$")
end

-- Leading whitespace of a line.
local function indent_of(line)
  return line:match("^(%s*)") or ""
end

-- Width in columns of a line's leading whitespace, expanding tabs to tabstop.
local function indent_cols(line, tabstop)
  local col = 0
  for ch in line:gmatch(".") do
    if ch == " " then
      col = col + 1
    elseif ch == "\t" then
      col = col + tabstop - (col % tabstop)
    else
      break
    end
  end
  return col
end

-- Last line belonging to the item rooted at `start`: the item itself plus every
-- following line indented deeper than it. A blank line or a line at the same or
-- shallower indent ends the item.
local function subtree_end(start)
  local buf = api.nvim_get_current_buf()
  local last = api.nvim_buf_line_count(buf)
  local depth = #indent_of(api.nvim_buf_get_lines(buf, start - 1, start, false)[1])
  local i = start
  while i < last do
    local nxt = api.nvim_buf_get_lines(buf, i, i + 1, false)[1]
    if nxt == nil or nxt:match("^%s*$") or #indent_of(nxt) <= depth then
      break
    end
    i = i + 1
  end
  return i
end

-- The marker that opens the next sibling item.
local function next_marker(item)
  if item.kind == "ordered" then
    return item.indent .. tostring((item.num or 0) + 1) .. item.delim .. " "
  end
  if task_body(item.text) then
    return item.indent .. item.bullet .. " [ ] "
  end
  return item.indent .. item.bullet .. " "
end

-- Renumber the run of ordered items at `row`'s indent level. Deeper lines
-- (sub-items, indented continuations) are skipped rather than ending the run,
-- so renumbering survives a nested list sitting between two siblings.
local function renumber_ordered_block(row)
  local buf = api.nvim_get_current_buf()
  local last = api.nvim_buf_line_count(buf)

  local function line_at(i)
    if i < 1 or i > last then
      return nil
    end
    return api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
  end

  local base_line = line_at(row)
  local base = base_line and parse_item(base_line)
  if not base or base.kind ~= "ordered" then
    return
  end
  local indent = base.indent
  local depth = #indent

  -- "member": an ordered sibling that gets numbered; "skip": deeper, left
  -- alone; "stop": the run has ended.
  local function classify(i)
    local line = line_at(i)
    if not line or line:match("^%s*$") then
      return "stop"
    end
    local item = parse_item(line)
    if not item then
      local ind = line:match("^(%s*)")
      return #ind > depth and "skip" or "stop"
    end
    local d = #item.indent
    if d > depth then
      return "skip"
    elseif d < depth then
      return "stop"
    elseif item.kind == "ordered" then
      return "member"
    end
    return "stop"
  end

  local top = row
  while classify(top - 1) ~= "stop" do
    top = top - 1
  end
  local bottom = row
  while classify(bottom + 1) ~= "stop" do
    bottom = bottom + 1
  end

  local n = 0
  for i = top, bottom do
    if classify(i) == "member" then
      local it = parse_item(line_at(i))
      n = n + 1
      api.nvim_buf_set_lines(buf, i - 1, i, false, { indent .. tostring(n) .. it.delim .. " " .. it.text })
    end
  end
end

-- <CR> in insert mode.
local function on_enter()
  if fn.pumvisible() == 1 then
    feed("<C-y>")
    return
  end

  local row, col = unpack(api.nvim_win_get_cursor(0))
  local line = api.nvim_get_current_line()

  -- Mid-line Enter splits as usual; only continue at the end of the item.
  if col ~= #line then
    feed("<CR>")
    return
  end

  local item = parse_item(line)
  if not item then
    feed("<CR>")
    return
  end

  local body = task_body(item.text) or item.text
  if body:match("^%s*$") then
    -- Empty item: drop the marker and leave the cursor on the blank line.
    api.nvim_buf_set_lines(0, row - 1, row, false, { "" })
    return
  end

  -- Insert the next marker on a fresh line directly rather than feeding a
  -- <CR>, so the ordered-list renumber below sees the new line. We stay in
  -- insert mode with the cursor parked after the marker.
  local marker = next_marker(item)
  api.nvim_buf_set_lines(0, row, row, false, { marker })
  api.nvim_win_set_cursor(0, { row + 1, #marker })
  if item.kind == "ordered" then
    renumber_ordered_block(row + 1)
  end
end

-- Open a new sibling item below (dir = 1) or above (dir = -1).
local function on_open(dir)
  local buf = api.nvim_get_current_buf()
  local row = api.nvim_win_get_cursor(0)[1]
  local line = api.nvim_get_current_line()
  local item = parse_item(line)

  if not item then
    feed(dir > 0 and "o" or "O")
    return
  end

  local marker = next_marker(item)
  local at = dir > 0 and row or row - 1
  api.nvim_buf_set_lines(buf, at, at, false, { marker })
  api.nvim_win_set_cursor(0, { at + 1, #marker })

  if item.kind == "ordered" then
    renumber_ordered_block(at + 1)
  end

  vim.cmd("startinsert!")
end

-- Move the item under the cursor (with its whole subtree) up (dir = -1) or
-- down (dir = 1) past its adjacent sibling. Ordered lists are renumbered.
-- Off a list item the bare line is nudged instead.
local function move_item(dir)
  local buf = api.nvim_get_current_buf()
  local row = api.nvim_win_get_cursor(0)[1]
  local col = api.nvim_win_get_cursor(0)[2]
  local line = api.nvim_get_current_line()
  local item = parse_item(line)

  if not item then
    vim.cmd(row .. (dir > 0 and "move +1" or "move -2"))
    return
  end

  local depth = #item.indent
  local send = subtree_end(row)
  local get = function(a, b)
    return api.nvim_buf_get_lines(buf, a - 1, b, false)
  end

  local sib_start, sib_end
  if dir > 0 then
    local k = send + 1
    local kline = get(k, k)[1]
    if not kline or kline:match("^%s*$") or #indent_of(kline) ~= depth then
      return
    end
    sib_start, sib_end = k, subtree_end(k)
  else
    local j = row - 1
    while j >= 1 do
      local jline = get(j, j)[1]
      if not jline or jline:match("^%s*$") then
        return
      end
      local d = #indent_of(jline)
      if d == depth then
        break
      elseif d < depth then
        return
      end
      j = j - 1
    end
    if j < 1 then
      return
    end
    sib_start, sib_end = j, row - 1
  end

  local cur_block = get(row, send)
  local sib_block = get(sib_start, sib_end)
  local new_lines, new_row
  if dir > 0 then
    new_lines = vim.list_extend(vim.list_extend({}, sib_block), cur_block)
    new_row = row + #sib_block
  else
    new_lines = vim.list_extend(vim.list_extend({}, cur_block), sib_block)
    new_row = sib_start
  end

  local from = math.min(row, sib_start)
  local to = math.max(send, sib_end)
  api.nvim_buf_set_lines(buf, from - 1, to, false, new_lines)
  api.nvim_win_set_cursor(0, { new_row, math.min(col, #new_lines[new_row - from + 1]) })

  renumber_ordered_block(new_row)
end

-- Shift one line by one indent level. Returns true when the line changed.
local function shift_line(row, dir, unit, expand)
  local line = api.nvim_buf_get_lines(0, row - 1, row, false)[1]
  if line:match("^%s*$") then
    return false
  end

  local new
  if dir > 0 then
    new = unit .. line
  elseif expand then
    if unit ~= "" and line:sub(1, #unit) == unit then
      new = line:sub(#unit + 1)
    elseif line:sub(1, 1) == " " then
      new = line:sub(2)
    else
      return false
    end
  elseif line:sub(1, 1) == "\t" then
    new = line:sub(2)
  else
    return false
  end

  if new == line then
    return false
  end
  api.nvim_buf_set_lines(0, row - 1, row, false, { new })
  return true
end

-- <Tab> / <S-Tab>. In normal mode, falling off a list item keeps the global
-- buffer navigation.
local function on_shift(mode, dir)
  local buf = api.nvim_get_current_buf()
  local unit = indent_unit(buf)
  local expand = vim.bo[buf].expandtab

  local first, last
  if mode == "v" then
    first = fn.line("'<")
    last = fn.line("'>")
  else
    first = api.nvim_win_get_cursor(0)[1]
    last = first
    local item = parse_item(api.nvim_buf_get_lines(buf, first - 1, first, false)[1])
    if not item then
      if dir > 0 then
        vim.cmd("bnext")
      else
        vim.cmd("bprevious")
      end
      return
    end
  end

  local changed = false
  for row = first, last do
    changed = shift_line(row, dir, unit, expand) or changed
  end

  if changed then
    renumber_ordered_block(first)
    renumber_ordered_block(last + 1)
  end
end

-- Toggle a checkbox on every line in the range, adding one to bullet items
-- that do not have one yet.
local function toggle_checkbox(first, last)
  for row = first, last do
    local line = api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local new
    if line:match("%[ %]") then
      new = line:gsub("%[ %]", "[x]", 1)
    elseif line:match("%[[xX]%]") then
      new = line:gsub("%[[xX]%]", "[ ]", 1)
    else
      local item = parse_item(line)
      if item and item.kind == "bullet" then
        new = item.indent .. item.bullet .. " [ ] " .. item.text
      end
    end
    if new and new ~= line then
      api.nvim_buf_set_lines(0, row - 1, row, false, { new })
    end
  end
end

local function on_toggle(mode)
  if mode == "v" then
    toggle_checkbox(fn.line("'<"), fn.line("'>"))
  else
    local row = api.nvim_win_get_cursor(0)[1]
    toggle_checkbox(row, row)
  end
end

-- Folding -------------------------------------------------------------------
--
-- List items are foldable with the native zc / zo / za: each item is a fold
-- that hides its own subtree. Levels come from indentation (independent of
-- shiftwidth) and are cached per changedtick, so the buffer is walked once per
-- edit rather than once per displayed line.
local fold_cache = { buf = nil, tick = -1, levels = {} }

local function compute_fold_levels(buf)
  local tick = api.nvim_buf_get_changedtick(buf)
  if fold_cache.buf == buf and fold_cache.tick == tick then
    return fold_cache.levels
  end

  local tabstop = vim.bo[buf].tabstop
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local levels = {}
  local stack = {}
  for i, line in ipairs(lines) do
    if line:match("^%s*$") then
      levels[i] = 0
    else
      local ind = indent_cols(line, tabstop)
      while #stack > 0 and stack[#stack] >= ind do
        table.remove(stack)
      end
      -- Fold level = number of enclosing items. Top-level content is 0 (the
      -- same convention as indent folding), so a parent's fold stops at the
      -- next top-level sibling instead of running to the end of the buffer.
      levels[i] = #stack
      if parse_item(line) then
        stack[#stack + 1] = ind
      end
    end
  end

  fold_cache = { buf = buf, tick = tick, levels = levels }
  return levels
end

-- foldexpr entry point, called as v:lua.__noctalia_outliner_fold(v:lnum).
function M.foldlevel(lnum)
  return compute_fold_levels(api.nvim_get_current_buf())[lnum] or 0
end

_G.__noctalia_outliner_fold = function(lnum)
  return M.foldlevel(lnum)
end

-- Turn on list folding for a window. foldmethod/foldexpr are window-local, and
-- are set on a schedule so they win over LazyVim's treesitter foldexpr, which
-- is applied from its own FileType autocmd.
local function fold_setup(win)
  if not win or not api.nvim_win_is_valid(win) then
    return
  end
  vim.wo[win].foldcolumn = "1"
  vim.wo[win].foldlevel = 99
  vim.wo[win].foldenable = true
  vim.schedule(function()
    if api.nvim_win_is_valid(win) then
      vim.wo[win].foldmethod = "expr"
      vim.wo[win].foldexpr = "v:lua.__noctalia_outliner_fold(v:lnum)"
    end
  end)
end

function M.attach(buf)
  buf = buf or api.nvim_get_current_buf()
  local win = api.nvim_get_current_win()
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
  end

  map("i", "<CR>", function()
    on_enter()
  end, "Continue list item")

  map({ "n", "v" }, "<Tab>", function()
    on_shift(vim.fn.mode(), 1)
  end, "Indent list item")
  map({ "n", "v" }, "<S-Tab>", function()
    on_shift(vim.fn.mode(), -1)
  end, "Outdent list item")

  map("n", "o", function()
    on_open(1)
  end, "New list item below")
  map("n", "O", function()
    on_open(-1)
  end, "New list item above")

  map("n", "<A-Down>", function()
    move_item(1)
  end, "Move list item down")
  map("n", "<A-Up>", function()
    move_item(-1)
  end, "Move list item up")

  map({ "n", "v" }, "<leader>mt", function()
    on_toggle(vim.fn.mode())
  end, "Toggle markdown checkbox")

  fold_setup(win)
end

-- Pure helpers exposed so the outliner logic can be exercised headlessly
-- without simulating keystrokes.
M._internal = {
  parse_item = parse_item,
  task_body = task_body,
  next_marker = next_marker,
  renumber_ordered_block = renumber_ordered_block,
  shift_line = shift_line,
  toggle_checkbox = toggle_checkbox,
  subtree_end = subtree_end,
  move_item = move_item,
  compute_fold_levels = compute_fold_levels,
}

return M
