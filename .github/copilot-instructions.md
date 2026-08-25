# Copilot instructions for this repository

## Build, test, and lint commands

This repository is a dotfiles collection, so there is no repo-wide build, lint, or test runner.

For the Neovim config in `nvim-mini/.config/nvim`, use a headless startup smoke test after changes:

```sh
XDG_CONFIG_HOME=$PWD/nvim-mini/.config XDG_DATA_HOME=$HOME/.local/share nvim --headless '+quitall'
```

To exercise the code path that loads file-aware plugins via `Config.now_if_args`, open a file during startup:

```sh
XDG_CONFIG_HOME=$PWD/nvim-mini/.config XDG_DATA_HOME=$HOME/.local/share nvim --headless '+edit init.lua' '+quitall'
```

There is no automated single-test command in this repo. For targeted validation, start Neovim against the specific config file or filetype you changed.

Useful maintenance commands already referenced by the config:

```vim
:lua vim.pack.update()
:TSUpdate
:TSInstall <language>
```

## High-level architecture

- Top-level directories are mostly independent app-specific dotfiles (`fish`, `ghostty`, `niri`, `nvim-mini`, `nvim-lazyvim`, `starship`, `yazi`, `zathura`). Treat each subtree as its own config instead of assuming shared abstractions.
- `nvim-mini/.config/nvim` is the main hand-written Neovim config in this repo. It is a MiniMax-style setup built around `mini.nvim` and Neovim's built-in `vim.pack`.
- `nvim-lazyvim/.config/nvim` is a separate LazyVim starter config. Do not mix its LazyVim conventions into `nvim-mini`.
- `nvim-mini/.config/nvim/init.lua` bootstraps a global `Config` table, defines shared helpers (`Config.new_autocmd`, `Config.on_packchanged`, `Config.now`, `Config.later`, `Config.now_if_args`), and installs `mini.nvim` early so later files can rely on those helpers.
- `nvim-mini/.config/nvim/plugin/` is the main startup pipeline and depends on numeric load order:
  - `10_options.lua`: core Neovim options and diagnostics defaults
  - `20_keymaps.lua`: general mappings and leader groups
  - `30_mini.lua`: nearly all `mini.nvim` module setup
  - `40_plugins.lua`: non-`mini.nvim` plugins such as treesitter, LSP config, formatting, snippets, Copilot, and markdown helpers
- `nvim-mini/.config/nvim/after/` contains targeted overrides that Neovim loads by convention:
  - `after/ftplugin/markdown.lua`: markdown-only behavior, plugin activation, and buffer-local mappings
  - `after/lsp/lua_ls.lua`: Lua LSP configuration
  - `after/snippets/*.json`: higher-priority language-specific snippets
- `nvim-mini/.config/nvim/snippets/global.json` holds snippets available everywhere; `friendly-snippets` is layered underneath via `mini.snippets`.
- `nvim-mini/.config/nvim/nvim-pack-lock.json` is the plugin lockfile for `vim.pack`; plugin source or version changes should stay consistent with it.
- `plugin/30_mini.lua` also contains the main UI polish for explorer and key hints: `mini.files` is customized there with explorer-local mappings and window styling, and `mini.clue` is intentionally narrowed to leader and window hints.
- `plugin/40_plugins.lua` owns the extra UI integrations that are outside `mini.nvim`. In particular, the floating `:` cmdline comes from a deliberately minimal `noice.nvim` setup, while its popupmenu/message/LSP UI features stay disabled.

## Key conventions

- In `nvim-mini`, keep startup work split between `Config.now`, `Config.later`, and `Config.now_if_args` instead of eagerly loading everything at startup.
- Add new startup files under `nvim-mini/.config/nvim/plugin/` with numeric prefixes so their load order is explicit.
- Use the global `Config` table for cross-file coordination instead of ad hoc globals. Example: `Config.leader_group_clues` is defined in `20_keymaps.lua` and consumed later by `mini.clue` in `30_mini.lua`.
- New leader mappings should follow the existing two-key grouping scheme (`<Leader>f*`, `<Leader>g*`, etc.), include `desc`, and update `Config.leader_group_clues` when introducing a new group.
- Prefer `30_mini.lua` for behavior implemented with `mini.nvim` modules; reserve `40_plugins.lua` for plugins outside `mini.nvim` or for external tooling integrations.
- Filetype-, LSP-, and snippet-specific behavior belongs under `after/ftplugin/`, `after/lsp/`, and `after/snippets/` instead of being hard-coded into the global startup files.
- `mini.files` is intentionally kept instead of replacing it with a tree plugin. Explorer polish should build on its existing setup in `30_mini.lua` using module config plus `MiniFilesBufferCreate` / `MiniFilesWindowOpen` autocommands.
- Markdown support is intentionally layered: `40_plugins.lua` installs `bullets.vim`, `autolist.nvim`, and `render-markdown.nvim`, while `after/ftplugin/markdown.lua` explicitly `packadd`s and configures them for markdown buffers.
- LSP support is only partially wired by default: `nvim-lspconfig` is installed and `after/lsp/lua_ls.lua` exists, but `vim.lsp.enable({...})` is still commented out in `40_plugins.lua`. If you add or debug language servers, check both places.
- Autocomplete and suggestion features are intentionally disabled in `nvim-mini`: there is no `mini.completion`/`mini.cmdline` setup, and `copilot.vim` remains installed but globally disabled unless explicitly re-enabled.
- The floating command line is intentionally limited to `noice.nvim`'s cmdline popup. If you adjust it, preserve the current goal: centered popup `:` UI without re-enabling Noice popupmenu completions, command suggestions, or extra LSP/message overlays.
- `mini.clue` is intentionally scoped to `<Leader>` and `<C-w>` so the popup behaves more like a focused which-key panel instead of a general-purpose hint system.
