-- Live PDF export: keep the exported PDF in step with the buffer.
--
-- On every save of a markdown buffer, `md-export <file> pdf` is run in the
-- background. Zathura reloads a document automatically when its file changes
-- on disk, so a PDF open beside the editor follows every `:w` with no extra
-- keypress -- the two-pane "write on the left, read on the right" setup.
--
-- Only files that already have a PDF next to them are re-exported. That keeps
-- saving an ordinary note from littering the directory with one; press
-- <leader>op once to produce the first PDF, and it stays current from then on.
--
-- Runs are debounced and serialised: a save shortly after another coalesces,
-- and a save during a running export queues exactly one follow-up rather than
-- racing two md-export processes at the same output path.
--
-- Disable for a session with :MdLiveExport off, or <leader>ol.

local M = {}

local api = vim.api

-- Whether saving a markdown buffer re-exports its PDF.
M.enabled = true

-- Re-export only when a PDF already exists; flip to true to create it on the
-- first save instead.
M.create = false

local debounce_ms = 800

local timers = {}
local running = {}
local queued = {}

local function notify(msg, level)
  vim.notify(msg, level, { title = "Live PDF" })
end

local function pdf_of(filepath)
  return (filepath:gsub("%.[Mm][Dd]$", "")) .. ".pdf"
end

local function export(bufnr, filepath)
  running[bufnr] = true
  vim.system({ "md-export", filepath, "pdf" }, { text = true }, function(obj)
    vim.schedule(function()
      running[bufnr] = false
      if obj.code ~= 0 then
        local err = (obj.stderr ~= "" and obj.stderr) or obj.stdout or "unknown error"
        notify("md-export failed:\n" .. err, vim.log.levels.ERROR)
      end
      if queued[bufnr] then
        queued[bufnr] = false
        export(bufnr, filepath)
      end
    end)
  end)
end

--- Queue a re-export of the buffer, after a short quiet period.
---@param bufnr integer?
function M.schedule(bufnr)
  if not M.enabled then
    return
  end
  bufnr = bufnr or api.nvim_get_current_buf()

  if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].modified then
    return
  end
  local filepath = api.nvim_buf_get_name(bufnr)
  if filepath == "" or vim.fn.executable("md-export") ~= 1 then
    return
  end
  if not M.create and vim.fn.filereadable(pdf_of(filepath)) ~= 1 then
    return
  end

  if timers[bufnr] then
    timers[bufnr]:stop()
    timers[bufnr]:close()
  end
  timers[bufnr] = vim.uv.new_timer()
  timers[bufnr]:start(
    debounce_ms,
    0,
    vim.schedule_wrap(function()
      if timers[bufnr] then
        timers[bufnr]:stop()
        timers[bufnr]:close()
        timers[bufnr] = nil
      end
      if not api.nvim_buf_is_valid(bufnr) then
        return
      end
      if running[bufnr] then
        queued[bufnr] = true
        return
      end
      export(bufnr, api.nvim_buf_get_name(bufnr))
    end)
  )
end

--- Turn live export on, off, or toggle it.
---@param state boolean?
---@return boolean enabled
function M.toggle(state)
  M.enabled = state == nil and not M.enabled or state
  notify("Live PDF export " .. (M.enabled and "on" or "off"), vim.log.levels.INFO)
  return M.enabled
end

function M.setup()
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = api.nvim_create_augroup("noctalia_markdown_live_export", { clear = true }),
    pattern = { "*.md", "*.markdown", "*.pandoc" },
    desc = "Re-export the markdown buffer's PDF so a viewer can reload it",
    callback = function(args)
      M.schedule(args.buf)
    end,
  })

  api.nvim_create_user_command("MdLiveExport", function(opts)
    local arg = opts.args
    if arg == "on" then
      M.toggle(true)
    elseif arg == "off" then
      M.toggle(false)
    else
      M.toggle()
    end
  end, {
    nargs = "?",
    desc = "Live PDF export on save (on|off|toggle)",
    complete = function()
      return { "on", "off", "toggle" }
    end,
  })
end

return M
