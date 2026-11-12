local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Ensure user binaries are on PATH, and JAVA_HOME only when there is a JDK.
--
-- This used to set JAVA_HOME to ~/.local/opt/jdk unconditionally. That directory
-- does not exist on this machine, and both kotlin-language-server and jdtls
-- launch through a script that refuses to start when JAVA_HOME is set but wrong:
--
--   ERROR: JAVA_HOME is set to an invalid directory: /home/mark/.local/opt/jdk
--
-- The JDK here comes from nixpkgs (modules/packages/default.nix installs `jdk`,
-- so `java` is on PATH). Leaving JAVA_HOME unset is what lets those wrappers
-- find java for themselves, so it is only worth setting when the directory is
-- really there.
local local_bin = vim.fn.expand("$HOME") .. "/.local/bin"
local jdk_home = vim.env.JAVA_HOME or (vim.fn.expand("$HOME") .. "/.local/opt/jdk")
if vim.fn.isdirectory(jdk_home) == 1 then
  vim.env.JAVA_HOME = jdk_home
  local jdk_bin = jdk_home .. "/bin"
  if not vim.env.PATH:find(jdk_bin, 1, true) then
    vim.env.PATH = jdk_bin .. ":" .. vim.env.PATH
  end
end
if not vim.env.PATH:find(local_bin, 1, true) then
  vim.env.PATH = local_bin .. ":" .. vim.env.PATH
end
vim.env.PUPPETEER_EXECUTABLE_PATH = vim.env.PUPPETEER_EXECUTABLE_PATH or (vim.fn.expand("$HOME") .. "/.local/bin/chrome-headless-shell")

require("lazy").setup({
  spec = {
    -- LazyVim core
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- Language extras
    { import = "lazyvim.plugins.extras.lang.rust" },
    { import = "lazyvim.plugins.extras.lang.clangd" },
    { import = "lazyvim.plugins.extras.lang.java" },
    { import = "lazyvim.plugins.extras.lang.kotlin" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    -- The rest of the languages this machine actually edits: the NixOS flake in
    -- /etc/nixos, shell scripts, and the JSON/TOML/LaTeX that show up around
    -- them. There is no lang.bash extra in LazyVim, so bashls is added by hand
    -- in lua/plugins/languages.lua.
    { import = "lazyvim.plugins.extras.lang.nix" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.toml" },
    { import = "lazyvim.plugins.extras.lang.tex" },
    -- QoL extras
    { import = "lazyvim.plugins.extras.editor.aerial" },
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.ui.mini-indentscope" },
    -- Custom user plugins
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "noctalia", "habamax" } },
  -- image.nvim ships a rockspec, so lazy.nvim tries to build the optional
  -- `magick` luarock via hererocks -- which fails on NixOS (no system luarocks).
  -- Only :ImageInfo needs that rock; disable rocks support globally.
  -- This must be a top-level lazy option: rockspec package detection is gated
  -- on it, so a per-plugin `rocks = { enabled = false }` in a spec has no effect.
  rocks = { enabled = false },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
