-- Autocmds are automatically loaded on the VeryLazy event

local augroup = function(name)
  return vim.api.nvim_create_augroup("noctalia_" .. name, { clear = true })
end

-- 1. Auto-save on focus change (FocusLost) and buffer switch (BufLeave)
vim.opt.autowrite = true
vim.opt.autowriteall = true

vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  group = augroup("autosave_on_focus_change"),
  desc = "Automatically save modified file when switching focus or buffers",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if
      vim.api.nvim_buf_is_valid(buf)
      and vim.bo[buf].modified
      and not vim.bo[buf].readonly
      and vim.fn.expand("%") ~= ""
      and vim.bo[buf].buftype == ""
    then
      vim.cmd("silent! noautocmd write")
    end
  end,
})

-- 2. Markdown buffer settings: 88-character hard wrap & spell off
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("markdown_settings"),
  pattern = { "markdown", "md", "pandoc" },
  desc = "Configure markdown textwidth and formatting",
  callback = function()
    vim.opt_local.spell = false
    vim.opt_local.textwidth = 88
    vim.opt_local.colorcolumn = "89"
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.formatoptions:append("t")
  end,
})

-- 3. Dynamic Responsive Sidebar Layout Controller
-- Wide / Fullscreen (>= 125 columns):
--   - For Markdown: Document Outline (Aerial) on left + Minimap on right
--   - For Coding Projects: File Explorer (Neo-tree scoped to project folder) on left + Minimap on right
-- Tiled / Half-screen (< 125 columns):
--   - Closes all sidebars (Neo-tree, Aerial, Minimap) to give 100% window width to editor
local is_updating = false

local function find_win_by_ft(ft)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == ft then
        return win
      end
    end
  end
  return nil
end

local function get_main_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local bt = vim.bo[buf].buftype
      local ft = vim.bo[buf].filetype
      if bt == "" and ft ~= "" and ft ~= "aerial" and ft ~= "neo-tree" and ft ~= "neominimap" then
        return win
      end
    end
  end
  return vim.api.nvim_get_current_win()
end

local function get_project_dir(buf)
  local filepath = vim.api.nvim_buf_get_name(buf)
  if filepath == "" then
    return vim.fn.getcwd()
  end
  local root = vim.fs.root(filepath, {
    ".git",
    "Cargo.toml",
    "CMakeLists.txt",
    "Makefile",
    "pom.xml",
    "build.gradle",
    "pyproject.toml",
    "package.json",
    ".clang-format",
  })
  if root and root ~= "/home/mark" and root ~= "/" then
    return root
  end
  return vim.fn.fnamemodify(filepath, ":p:h")
end

local function close_sidebars()
  pcall(require("aerial").close)
  pcall(require("neominimap.api").disable)
  pcall(vim.cmd, "Neotree close")
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(w) then
      local b = vim.api.nvim_win_get_buf(w)
      local ft = vim.bo[b].filetype
      if ft == "aerial" or ft == "neominimap" or ft == "neo-tree" then
        pcall(vim.api.nvim_win_close, w, true)
      end
    end
  end
end

local function open_sidebars()
  local main_win = get_main_win()
  local main_buf = vim.api.nvim_win_get_buf(main_win)
  local ft = vim.bo[main_buf].filetype

  -- Enable Minimap on the right for all files
  pcall(require("neominimap.api").enable)

  local is_markdown = (ft == "markdown" or ft == "md" or ft == "pandoc")

  if is_markdown then
    -- Markdown files: Show Document Outline on left, close Neo-tree
    if find_win_by_ft("neo-tree") then
      pcall(vim.cmd, "Neotree close")
    end
    if not find_win_by_ft("aerial") then
      if main_win and vim.api.nvim_win_is_valid(main_win) then
        pcall(vim.api.nvim_set_current_win, main_win)
      end
      local ok, aerial = pcall(require, "aerial")
      if ok then
        aerial.open()
        if main_win and vim.api.nvim_win_is_valid(main_win) then
          pcall(vim.api.nvim_set_current_win, main_win)
        end
      end
    end
  else
    -- Coding projects (Rust, C, C++, Java, Python, etc.):
    -- Show File Explorer (Neo-tree) scoped to project/file directory on left, close Aerial
    if find_win_by_ft("aerial") then
      pcall(require("aerial").close)
    end
    if not find_win_by_ft("neo-tree") then
      local proj_dir = get_project_dir(main_buf)
      pcall(vim.cmd, "Neotree show dir=" .. vim.fn.fnameescape(proj_dir))
      if main_win and vim.api.nvim_win_is_valid(main_win) then
        pcall(vim.api.nvim_set_current_win, main_win)
      end
    end
  end
end

local function update_layout()
  if is_updating then return end
  is_updating = true

  local cols = vim.o.columns
  local threshold = 125

  local main_win = get_main_win()
  local main_buf = vim.api.nvim_win_get_buf(main_win)
  local ft = vim.bo[main_buf].filetype

  if ft == "lazy" or ft == "mason" or ft == "help" then
    is_updating = false
    return
  end

  if cols < threshold then
    close_sidebars()
  else
    open_sidebars()
  end

  is_updating = false
end

-- Debounced resize listener: handles window manager animation/tiling smoothly
local resize_timer = nil
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("responsive_sidebar_resize"),
  desc = "Dynamically toggle sidebars when window is resized or tiled",
  callback = function()
    if resize_timer then
      resize_timer:stop()
      resize_timer:close()
    end
    resize_timer = vim.uv.new_timer()
    resize_timer:start(50, 0, vim.schedule_wrap(function()
      update_layout()
      if resize_timer then
        resize_timer:stop()
        resize_timer:close()
        resize_timer = nil
      end
    end))
  end,
})

-- Startup layout check
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("responsive_sidebar_startup"),
  desc = "Apply initial sidebar layout on editor start",
  callback = function()
    vim.defer_fn(update_layout, 150)
  end,
})

-- Filetype check when opening documents
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("responsive_filetype_open"),
  pattern = "*",
  desc = "Set appropriate left sidebar (outline for markdown, neotree for code) if window is wide",
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == "lazy" or ft == "mason" or ft == "help" or ft == "aerial" or ft == "neo-tree" or ft == "neominimap" then
      return
    end
    if vim.o.columns >= 125 then
      vim.defer_fn(update_layout, 80)
    end
  end,
})

-- 4. Re-apply Noctalia theme on SIGUSR1 (triggered when Noctalia changes theme)
if _G.__noctalia_signal then
  _G.__noctalia_signal:stop()
  _G.__noctalia_signal:close()
end
local signal = vim.uv.new_signal()
_G.__noctalia_signal = signal
signal:start(
  "sigusr1",
  vim.schedule_wrap(function()
    package.loaded["matugen"] = nil
    local ok, matugen = pcall(require, "matugen")
    if ok and matugen.setup then
      matugen.setup()
    end
    pcall(vim.cmd.colorscheme, "noctalia")
  end)
)
