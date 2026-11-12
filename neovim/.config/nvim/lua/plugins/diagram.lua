-- Inline mermaid rendering in markdown buffers via diagram.nvim.
--
-- Renders ```mermaid fences as PNG images floating over the code, powered by
-- image.nvim's kitty-graphics backend (Ghostty speaks the protocol). mmdc
-- (mermaid-cli, in modules/packages/default.nix) does the actual rendering;
-- its palette comes from ~/.config/omarchy/mermaid-mmdc.json, regenerated
-- from the active Omarchy theme by the theme-set hook
-- ~/.config/omarchy/hooks/theme-set.d/mermaid-mmdc. No `theme` is set here
-- so diagram.nvim does not pass `-t` and override that config.
--
-- <leader>m] / <leader>m[ raise and lower the render scale at runtime.
--
-- opts is a function, not a table: the integrations require runs inside it,
-- and a table-valued opts is evaluated while lazy.nvim parses the spec --
-- before the plugin is installed on a first run -- which makes the whole
-- spec file error and the plugin never installs.

local state = { scale = 2 }

-- mmdc's cache keys on the diagram source only, never on the flags it was
-- rendered with, so a scale change would keep serving the old PNG forever.
-- A .scale marker in the cache dir records what the PNGs were rendered at;
-- when the wanted scale differs, every render is dropped and the next call
-- regenerates it at the new size.
local bust_cache_for_scale = function(scale)
  local dir = vim.fn.resolve(vim.fn.stdpath("cache") .. "/diagram-cache/mermaid")
  local marker = dir .. "/.scale"
  local want = string.format("%g", scale)
  local have = ""
  if vim.fn.filereadable(marker) == 1 then
    have = vim.trim(table.concat(vim.fn.readfile(marker), ""))
  end
  if have == want then return end
  for _, png in ipairs(vim.fn.glob(dir .. "/*.png", false, true)) do
    vim.fn.delete(png)
  end
  vim.fn.writefile({ want }, marker)
end

-- diagram.nvim reads mmdc flags from the options table it merged during
-- setup(), which is a local it never exposes, so the scale cannot be changed
-- through its API. Wrapping the renderer module (the same table every caller
-- holds) keeps all renders -- inline events, hover, later buffers -- on the
-- live scale instead.
--
-- The table must be reached through the integration our opts created:
-- diagram.nvim requires the renderer with slash paths
-- ("diagram/renderers/mermaid") and Neovim keys package.loaded on the name
-- as given, so a freshly dotted require would hand back a *second* module
-- instance that no caller ever uses (and wrap it to no effect).
local install_scale_wrapper = function()
  -- The integration lists renderers as an array of tables with an `id` field,
  -- not as a map keyed by name.
  local mermaid = nil
  for _, renderer in ipairs(require("diagram.integrations.markdown").renderers) do
    if renderer.id == "mermaid" then
      mermaid = renderer
      break
    end
  end
  if not mermaid then
    vim.notify("mermaid renderer not found; runtime scaling disabled", vim.log.levels.WARN, {
      title = "Diagram.nvim",
    })
    return
  end
  if mermaid.scale_wrapped then return end
  local render = mermaid.render
  mermaid.render = function(source, options)
    bust_cache_for_scale(state.scale)
    return render(
      source,
      vim.tbl_deep_extend("force", {}, options or {}, { scale = state.scale })
    )
  end
  mermaid.scale_wrapped = true
end

local change_scale = function(delta)
  state.scale = math.max(0.5, math.min(6, state.scale + delta))
  vim.notify("mermaid scale: " .. string.format("%g", state.scale), vim.log.levels.INFO, {
    title = "Diagram.nvim",
  })
  -- Re-render the current buffer right away; other markdown buffers pick the
  -- new scale up on their next render event (switching to them, insert leave),
  -- since their cached PNGs were just dropped.
  pcall(function()
    require("diagram").render()
  end)
end

return {
  "3rd/diagram.nvim",
  dependencies = {
    -- The magick luarock is only used by image.nvim's :ImageInfo command;
    -- dimensions are parsed natively and the kitty backend needs no rock.
    -- lazy.nvim's rocks installer is disabled globally in config/lazy.lua.
    {
      "3rd/image.nvim",
      opts = {
        -- image.nvim's default squeezes any image past 50% of the window
        -- height, which halved mermaid's text on screen (an ER diagram's
        -- 13px glyphs were drawn at ~8px). Let diagrams use the full window;
        -- the 100% window caps still stop them overflowing it.
        max_height_window_percentage = 100,
      },
    },
  },
  ft = { "markdown" },
  opts = function()
    return {
      integrations = {
        require("diagram.integrations.markdown"),
      },
      renderer_options = {
        mermaid = {
          -- Transparent page so the diagram floats over the buffer background
          -- at any theme; the palette itself lives in the -c config below.
          background = "transparent",
          -- mmdc fit-shrinks wide diagrams onto its ~784px page, taking mermaid's
          -- 16px text down to ~13px before image.nvim even sees it. Rasterizing
          -- at 2x doubles the text pixels, so diagrams land at roughly terminal
          -- font size instead of a smudge. This is only the starting value:
          -- <leader>m] / <leader>m[ change it at runtime and drop the stale
          -- renders automatically (see bust_cache_for_scale above).
          scale = 2,
          cli_args = {
            -- -c (lowercase) is mermaid's theme config; -C is --cssFile.
            -- No --no-sandbox: nixpkgs' mermaid-cli wrapper already points
            -- Puppeteer at its own Chromium, which runs sandboxless on NixOS.
            "-c",
            vim.fn.expand("~/.config/omarchy/mermaid-mmdc.json"),
          },
        },
      },
    }
  end,
  keys = {
    {
      "<leader>mh",
      function()
        require("diagram").show_diagram_hover()
      end,
      mode = "n",
      ft = { "markdown" },
      desc = "Show diagram in new tab",
    },
    {
      "<leader>m]",
      function()
        change_scale(0.5)
      end,
      mode = "n",
      ft = { "markdown" },
      desc = "Increase mermaid diagram scale",
    },
    {
      "<leader>m[",
      function()
        change_scale(-0.5)
      end,
      mode = "n",
      ft = { "markdown" },
      desc = "Decrease mermaid diagram scale",
    },
  },
  config = function(_, opts)
    local mermaid_opts = opts.renderer_options and opts.renderer_options.mermaid
    if mermaid_opts and mermaid_opts.scale then state.scale = mermaid_opts.scale end

    -- Wrap before setup(): setup() performs the first render inline, and it
    -- should already go through the marker check.
    install_scale_wrapper()
    require("diagram").setup(opts)

    -- The first render runs mid-startup: lazy loads this plugin on FileType,
    -- before the UI is up, and nvim's initial screen clear wipes the
    -- kitty-protocol image placement right after it is drawn. Re-render once
    -- after startup (the PNG is cached, so this is instant); every later
    -- render is driven by diagram.nvim's own InsertLeave/BufWinEnter/TextChanged
    -- autocmds, which fire once the UI is live.
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("DiagramPostStartupRender", { clear = true }),
      callback = function()
        vim.defer_fn(function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "markdown" then
            require("diagram").render()
          end
        end, 150)
      end,
    })
  end,
}
