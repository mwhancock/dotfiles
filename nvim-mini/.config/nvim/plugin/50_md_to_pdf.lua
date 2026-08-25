-- ┌──────────────────────────────────────┐
-- │ Markdown to PDF Export Tool (Plugin) │
-- └──────────────────────────────────────┘
--
-- This plugin compiles markdown buffers (or ranges/visual selections) to PDF
-- in the background using pandoc combined with either:
-- 1. Headless Google Chrome/Chromium (for web-style modern CSS-based PDFs).
-- 2. LaTeX/Tectonic engines (for standard document/academic LaTeX PDFs).
--
-- Setup & Usage:
-- - Run `:MarkdownToPDF` to compile current buffer to a PDF.
-- - Select lines in visual mode and run `:MarkdownToPDF` to compile selection.
-- - Run `:MarkdownToPDFStyle` to choose a CSS style/theme (for Chrome engine).
-- - Run `:MarkdownToPDFEngine` to select the rendering engine.
-- - Run `:MarkdownToPDFAutoToggle` to toggle auto-compiling on save.
-- - Keymaps:
--   - `<Leader>op` to export current markdown buffer.
--   - `<Leader>op` (in Visual mode) to export selected lines.
--   - `<Leader>oa` to toggle auto-compilation on buffer save.

-- Initialize global configuration
_G.Config = _G.Config or {}
_G.Config.markdown_to_pdf = vim.tbl_deep_extend('keep', _G.Config.markdown_to_pdf or {}, {
  engine = 'chrome',         -- 'chrome', 'tectonic', 'xelatex', 'pdflatex', 'lualatex'
  style = 'modern',          -- 'modern', 'github', 'academic', or absolute path to a custom .css
  highlight_style = 'tango', -- pandoc code highlight style ('pygments', 'tango', 'kate', 'monochrome', 'espresso', 'zenburn')
  open_on_export = true,     -- open the PDF with default system viewer after export
  pdf_viewer = nil,          -- custom PDF viewer executable, e.g. 'zathura' (auto-detects zathura if nil)
  chrome_path = nil,         -- custom path to chrome/chromium binary (auto-detected if nil)
  pandoc_path = 'pandoc',    -- path to pandoc binary
})

-- Built-in CSS Stylesheets for the Chrome engine
local BUILTIN_CSS = {
  modern = [[
@charset "UTF-8";
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji";
  font-size: 16px;
  line-height: 1.6;
  color: #2D3748;
  max-width: 850px;
  margin: 0 auto;
  padding: 2.5rem;
  background-color: #ffffff;
}
@page {
  size: A4;
  margin: 25mm 20mm 20mm 20mm;
  @top-left {
    content: "{{TITLE}}";
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    font-size: 9pt;
    color: #a0aec0;
  }
  @top-right {
    content: counter(page);
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    font-size: 9pt;
    color: #a0aec0;
  }
}
@page:first {
  @top-left {
    content: none !important;
  }
  @top-right {
    content: none !important;
  }
}
h1, h2, h3, h4, h5, h6 {
  color: #1A202C;
  font-weight: 600;
  margin-top: 1.6em;
  margin-bottom: 0.6em;
  line-height: 1.3;
}
h1 { font-size: 2.2em; border-bottom: 2px solid #E2E8F0; padding-bottom: 0.3em; }
h2 { font-size: 1.65em; border-bottom: 1px solid #E2E8F0; padding-bottom: 0.3em; }
h3 { font-size: 1.35em; }
h4 { font-size: 1.15em; }
p, blockquote, ul, ol, dl, table, pre {
  margin-top: 0;
  margin-bottom: 18px;
}
a {
  color: #3182CE;
  text-decoration: none;
}
a:hover {
  text-decoration: underline;
}
blockquote {
  padding: 8px 16px;
  color: #4A5568;
  background-color: #F7FAFC;
  border-left: 4px solid #CBD5E0;
  margin: 0 0 18px 0;
  border-radius: 0 4px 4px 0;
}
code {
  font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, Courier, monospace;
  font-size: 85%;
  background-color: #EDF2F7;
  color: #2D3748;
  padding: 0.2em 0.4em;
  border-radius: 4px;
}
pre {
  background-color: #F7FAFC;
  border-radius: 6px;
  padding: 14px;
  overflow-x: auto;
  border: 1px solid #E2E8F0;
  max-width: 100%;
}
pre code {
  font-size: 78%;
  line-height: 1.35;
  background-color: transparent;
  padding: 0;
  border-radius: 0;
  white-space: pre-wrap;
  word-break: break-all;
  overflow-wrap: break-word;
}
table {
  border-collapse: collapse;
  width: 100%;
  margin-bottom: 18px;
}
table th, table td {
  padding: 10px 14px;
  border: 1px solid #E2E8F0;
}
table th {
  background-color: #F7FAFC;
  font-weight: 600;
  text-align: left;
}
table tr:nth-child(even) {
  background-color: #F8FAFC;
}
img {
  max-width: 100%;
  border-radius: 6px;
  margin: 12px 0;
}
/* Typography & Layout page breaks */
.page-break {
  page-break-before: always;
  break-before: page;
}
h1, h2, h3, h4, h5, h6 {
  page-break-after: avoid;
  break-after: avoid;
}
table, pre, blockquote {
  page-break-inside: avoid;
  break-inside: avoid;
}

/* GitHub style alerts */
.alert-blockquote {
  border-left: 0.25em solid #dfe2e5;
  padding: 0.5em 1em;
  margin: 0 0 16px 0;
  border-radius: 0 6px 6px 0;
}
.alert-blockquote p {
  margin: 0;
}
.alert-note { border-left-color: #0969da; background-color: #f6fafe; }
.alert-tip { border-left-color: #1a7f37; background-color: #f4fbf5; }
.alert-important { border-left-color: #8250df; background-color: #fbf8ff; }
.alert-warning { border-left-color: #9a6700; background-color: #fffdf5; }
.alert-caution { border-left-color: #cf222e; background-color: #fffbfa; }

.alert-blockquote::before {
  font-weight: 600;
  display: block;
  margin-bottom: 4px;
}
.alert-note::before { content: "ℹ️ Note"; color: #0969da; }
.alert-tip::before { content: "💡 Tip"; color: #1a7f37; }
.alert-important::before { content: "📢 Important"; color: #8250df; }
.alert-warning::before { content: "⚠️ Warning"; color: #9a6700; }
.alert-caution::before { content: "🚫 Caution"; color: #cf222e; }

/* Mermaid styling adjustments */
.mermaid {
  display: flex;
  justify-content: center;
  margin: 20px 0;
}

/* Explicit list styles to prevent inline rendering */
ul, ol {
  display: block !important;
  margin-top: 0 !important;
  margin-bottom: 18px !important;
  padding-left: 28px !important;
  list-style-position: outside !important;
}
li {
  display: list-item !important;
  text-align: left !important;
  margin-bottom: 6px !important;
}
ul { list-style-type: disc !important; }
ol { list-style-type: decimal !important; }
ul ul, ul ol, ol ul, ol ol {
  margin-top: 0 !important;
  margin-bottom: 0 !important;
  padding-left: 20px !important;
}
  ]],

  github = [[
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji";
  font-size: 16px;
  line-height: 1.5;
  color: #24292e;
  background-color: #ffffff;
  padding: 40px;
  max-width: 880px;
  margin: 0 auto;
}
@page {
  size: A4;
  margin: 25mm 20mm 20mm 20mm;
  @top-left {
    content: "{{TITLE}}";
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
    font-size: 9pt;
    color: #a0aec0;
  }
  @top-right {
    content: counter(page);
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
    font-size: 9pt;
    color: #a0aec0;
  }
}
@page:first {
  @top-left {
    content: none !important;
  }
  @top-right {
    content: none !important;
  }
}
h1, h2, h3, h4, h5, h6 {
  margin-top: 24px;
  margin-bottom: 16px;
  font-weight: 600;
  line-height: 1.25;
  color: #24292e;
}
h1 { font-size: 2em; padding-bottom: 0.3em; border-bottom: 1px solid #eaecef; }
h2 { font-size: 1.5em; padding-bottom: 0.3em; border-bottom: 1px solid #eaecef; }
h3 { font-size: 1.25em; }
h4 { font-size: 1em; }
a { color: #0366d6; text-decoration: none; }
a:hover { text-decoration: underline; }
blockquote {
  padding: 0 1em;
  color: #6a737d;
  border-left: 0.25em solid #dfe2e5;
  margin: 0 0 16px 0;
}
code {
  padding: 0.2em 0.4em;
  margin: 0;
  font-size: 85%;
  background-color: rgba(27,31,35,0.05);
  border-radius: 3px;
  font-family: SFMono-Regular, Consolas, Liberation Mono, Menlo, monospace;
}
pre {
  padding: 16px;
  overflow: auto;
  font-size: 85%;
  line-height: 1.45;
  background-color: #f6f8fa;
  border-radius: 6px;
  margin: 0 0 16px 0;
}
pre code {
  background-color: transparent;
  padding: 0;
  margin: 0;
  font-size: 100%;
  white-space: pre;
}
table {
  border-spacing: 0;
  border-collapse: collapse;
  margin: 0 0 16px 0;
  width: 100%;
}
table th { font-weight: 600; background-color: #fafbfc; }
table th, table td {
  padding: 6px 13px;
  border: 1px solid #dfe2e5;
}
table tr {
  background-color: #fff;
  border-top: 1px solid #c6cbd1;
}
table tr:nth-child(even) { background-color: #f6f8fa; }
img { max-width: 100%; }
.page-break {
  page-break-before: always;
  break-before: page;
}
h1, h2, h3, h4, h5, h6 {
  page-break-after: avoid;
  break-after: avoid;
}
table, pre, blockquote {
  page-break-inside: avoid;
  break-inside: avoid;
}

/* GitHub style alerts */
.alert-blockquote {
  border-left: 0.25em solid #dfe2e5;
  padding: 0.5em 1em;
  margin: 0 0 16px 0;
  border-radius: 0 6px 6px 0;
}
.alert-blockquote p {
  margin: 0;
}
.alert-note { border-left-color: #0969da; background-color: #f6fafe; }
.alert-tip { border-left-color: #1a7f37; background-color: #f4fbf5; }
.alert-important { border-left-color: #8250df; background-color: #fbf8ff; }
.alert-warning { border-left-color: #9a6700; background-color: #fffdf5; }
.alert-caution { border-left-color: #cf222e; background-color: #fffbfa; }

.alert-blockquote::before {
  font-weight: 600;
  display: block;
  margin-bottom: 4px;
}
.alert-note::before { content: "ℹ️ Note"; color: #0969da; }
.alert-tip::before { content: "💡 Tip"; color: #1a7f37; }
.alert-important::before { content: "📢 Important"; color: #8250df; }
.alert-warning::before { content: "⚠️ Warning"; color: #9a6700; }
.alert-caution::before { content: "🚫 Caution"; color: #cf222e; }

/* Mermaid styling adjustments */
.mermaid {
  display: flex;
  justify-content: center;
  margin: 20px 0;
}

/* Explicit list styles to prevent inline rendering */
ul, ol {
  display: block !important;
  margin-top: 0 !important;
  margin-bottom: 18px !important;
  padding-left: 28px !important;
  list-style-position: outside !important;
}
li {
  display: list-item !important;
  text-align: left !important;
  margin-bottom: 6px !important;
}
ul { list-style-type: disc !important; }
ol { list-style-type: decimal !important; }
ul ul, ul ol, ol ul, ol ol {
  margin-top: 0 !important;
  margin-bottom: 0 !important;
  padding-left: 20px !important;
}
  ]],

  academic = [[
body {
  font-family: "Times New Roman", Times, "Garamond", Georgia, serif;
  font-size: 12pt;
  line-height: 1.6;
  color: #000000;
  background-color: #ffffff;
  padding: 1in;
  text-align: justify;
}
@page {
  size: letter;
  margin: 1.2in 1in 1in 1in;
  @top-left {
    content: "{{TITLE}}";
    font-family: "Times New Roman", Times, serif;
    font-size: 10pt;
    color: #7f7f7f;
  }
  @top-right {
    content: counter(page);
    font-family: "Times New Roman", Times, serif;
    font-size: 10pt;
    color: #7f7f7f;
  }
}
@page:first {
  @top-left {
    content: none !important;
  }
  @top-right {
    content: none !important;
  }
}
h1, h2, h3, h4, h5, h6 {
  font-family: "Times New Roman", Times, "Garamond", Georgia, serif;
  color: #000000;
  font-weight: bold;
  text-align: left;
  margin-top: 1.5em;
  margin-bottom: 0.5em;
}
h1 { font-size: 18pt; text-align: center; margin-bottom: 1em; }
h2 { font-size: 14pt; border-bottom: 1px solid #000; padding-bottom: 3px; }
h3 { font-size: 12pt; font-style: italic; }
p {
  margin-top: 0;
  margin-bottom: 1.5em;
  text-indent: 0.5in;
}
h1 + p, h2 + p, h3 + p, h4 + p {
  text-indent: 0;
}
blockquote {
  margin: 1.5em 0.5in;
  font-size: 11pt;
  line-height: 1.5;
  text-align: justify;
}
code, pre {
  font-family: "Courier New", Courier, monospace;
  font-size: 10pt;
}
pre {
  padding: 0.8em;
  border: 1px solid #666;
  margin: 1.5em 0;
  white-space: pre-wrap;
  background-color: #fcfcfc;
}
table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1.5em;
  margin-bottom: 1.5em;
}
table th, table td {
  border-top: 1px solid black;
  border-bottom: 1px solid black;
  padding: 8px;
  text-align: left;
}
table th { font-weight: bold; }
.page-break {
  page-break-before: always;
  break-before: page;
}
h1, h2, h3, h4, h5, h6 {
  page-break-after: avoid;
  break-after: avoid;
}
table, pre, blockquote {
  page-break-inside: avoid;
  break-inside: avoid;
}

/* GitHub style alerts (Academic theme) */
.alert-blockquote {
  border-left: 3px double #000000;
  padding: 0.5em 1em;
  margin-bottom: 1.5em;
  background-color: transparent;
}
.alert-blockquote p {
  margin: 0;
}
.alert-blockquote::before {
  font-weight: bold;
  display: block;
  margin-bottom: 4px;
}
.alert-note::before { content: "Note"; }
.alert-tip::before { content: "Tip"; }
.alert-important::before { content: "Important"; }
.alert-warning::before { content: "Warning"; }
.alert-caution::before { content: "Caution"; }

/* Mermaid styling adjustments */
.mermaid {
  display: flex;
  justify-content: center;
  margin: 20px 0;
}

/* Explicit list styles to prevent inline rendering */
ul, ol {
  display: block !important;
  margin-top: 0 !important;
  margin-bottom: 18px !important;
  padding-left: 28px !important;
  list-style-position: outside !important;
}
li {
  display: list-item !important;
  text-align: left !important;
  margin-bottom: 6px !important;
}
ul { list-style-type: disc !important; }
ol { list-style-type: decimal !important; }
ul ul, ul ol, ol ul, ol ol {
  margin-top: 0 !important;
  margin-bottom: 0 !important;
  padding-left: 20px !important;
}
  ]],
}

-- JavaScript helper script for MathJax, Mermaid diagrams, and GitHub alerts parsing
local EXTRA_HTML = [[
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';

  mermaid.initialize({ 
    startOnLoad: false,
    theme: 'default',
    securityLevel: 'loose'
  });

  document.addEventListener("DOMContentLoaded", async function() {
    // 1. Find all pre blocks with mermaid class and convert to <div class="mermaid">
    const mermaidBlocks = document.querySelectorAll(
      "pre.mermaid, pre.sourceCode.mermaid, code.sourceCode.mermaid, pre.sourceCode.language-mermaid, pre.sourceCode.language-mermaid code"
    );
    mermaidBlocks.forEach(function(block) {
      let code = block.textContent || block.innerText;
      
      const div = document.createElement("div");
      div.className = "mermaid";
      div.textContent = code.trim();
      
      let toReplace = block;
      if (block.tagName === "CODE" && block.parentNode.tagName === "PRE") {
        toReplace = block.parentNode;
      }
      toReplace.parentNode.replaceChild(div, toReplace);
    });

    // 2. Parse GitHub-style alerts: [!NOTE], [!TIP], [!IMPORTANT], [!WARNING], [!CAUTION]
    const blockquotes = document.querySelectorAll("blockquote");
    blockquotes.forEach(function(bq) {
      const firstParagraph = bq.querySelector("p");
      if (!firstParagraph) return;
      
      const html = firstParagraph.innerHTML;
      const match = html.match(/^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\](?:\s*<br\s*\/?>)?(?:\s*)?/i);
      if (match) {
        const alertType = match[1].toUpperCase();
        bq.classList.add("alert-blockquote", "alert-" + alertType.toLowerCase());
        firstParagraph.innerHTML = html.replace(/^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\](?:\s*<br\s*\/?>)?(?:\s*)?/i, "");
      }
    });

    // 3. Render Mermaid diagrams programmatically with unique IDs to prevent ID collisions
    const divs = document.querySelectorAll('div.mermaid');
    for (let i = 0; i < divs.length; i++) {
      const el = divs[i];
      const code = el.textContent || el.innerText;
      const uniqueId = 'mermaid-svg-' + i;
      try {
        const { svg } = await mermaid.render(uniqueId, code);
        el.innerHTML = svg;
      } catch (err) {
        console.error("Mermaid rendering failed for diagram " + i, err);
      }
    }
  });
</script>
]]

-- Keep track of buffers with auto-compiling active
local auto_compile_buffers = {}

-- Clean up temporary files helper
local function cleanup(files)
  for _, f in ipairs(files) do
    if f then
      os.remove(f)
    end
  end
end

-- Find Chrome executable on the system
local function find_chrome()
  local candidates = {}
  if _G.Config.markdown_to_pdf.chrome_path then
    table.insert(candidates, _G.Config.markdown_to_pdf.chrome_path)
  end
  for _, c in ipairs({ 'google-chrome-stable', 'google-chrome', 'chromium-browser', 'chromium' }) do
    table.insert(candidates, c)
  end

  for _, candidate in ipairs(candidates) do
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return nil
end

-- Verify dependencies for selected engine
local function check_dependencies(engine)
  if vim.fn.executable(_G.Config.markdown_to_pdf.pandoc_path) == 0 then
    vim.notify('❌ Pandoc is not installed or not in PATH!', vim.log.levels.ERROR, { title = 'Markdown to PDF' })
    return false
  end

  if engine == 'chrome' then
    if not find_chrome() then
      vim.notify('❌ Google Chrome or Chromium is not installed (needed for "chrome" engine)!', vim.log.levels.ERROR, { title = 'Markdown to PDF' })
      return false
    end
  else
    if vim.fn.executable(engine) == 0 then
      vim.notify(string.format('❌ LaTeX engine "%s" is not installed or not in PATH!', engine), vim.log.levels.ERROR, { title = 'Markdown to PDF' })
      return false
    end
  end
  return true
end

-- Open generated PDF in system default viewer
local function open_pdf(path)
  local open_cmd
  local viewer = _G.Config.markdown_to_pdf.pdf_viewer
  if viewer and viewer ~= '' then
    open_cmd = { viewer, path }
  elseif vim.fn.executable('zathura') == 1 then
    open_cmd = { 'zathura', path }
  elseif vim.fn.has('mac') == 1 then
    open_cmd = { 'open', path }
  elseif vim.fn.has('win32') == 1 then
    open_cmd = { 'cmd.exe', '/c', 'start', '""', path }
  else
    open_cmd = { 'xdg-open', path }
  end

  vim.system(open_cmd, {}, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        vim.notify('⚠️ Could not open PDF automatically.', vim.log.levels.WARN, { title = 'Markdown to PDF' })
      end)
    end
  end)
end

-- Format a filename string into proper Title Case
local function title_case(str)
  local s = str:gsub('[_-]', ' ')
  local minor_words = {
    ['a'] = true, ['an'] = true, ['the'] = true,
    ['and'] = true, ['but'] = true, ['for'] = true, ['or'] = true, ['nor'] = true, ['so'] = true, ['yet'] = true,
    ['of'] = true, ['to'] = true, ['by'] = true, ['in'] = true, ['on'] = true, ['at'] = true, ['from'] = true, ['with'] = true, ['as'] = true, ['into'] = true, ['like'] = true,
  }
  local words = {}
  for word in s:gmatch('%S+') do
    table.insert(words, word)
  end
  if #words == 0 then return "" end

  words[1] = words[1]:sub(1, 1):upper() .. words[1]:sub(2):lower()
  if #words > 1 then
    words[#words] = words[#words]:sub(1, 1):upper() .. words[#words]:sub(2):lower()
  end
  for i = 2, #words - 1 do
    local w = words[i]:lower()
    if minor_words[w] then
      words[i] = w
    else
      words[i] = w:sub(1, 1):upper() .. w:sub(2)
    end
  end
  return table.concat(words, ' ')
end

-- Preprocess lines to normalize spaces, CRLF, bullet characters, Unicode tables, and trailing break tags
local function preprocess_markdown_lines(lines)
  local cleaned = {}
  local in_code_block = false

  for _, line in ipairs(lines) do
    local l = line:gsub('\r', '')

    -- Track fenced code blocks
    if l:match('^%s*```') or l:match('^%s*~~~') then
      in_code_block = not in_code_block
      table.insert(cleaned, l)
    elseif in_code_block then
      table.insert(cleaned, l)
    else
      -- Outside code block: normalize bullet points (•), unicode spaces, unicode table borders, and <br/>
      if l:match('^%s*\xe2\x80\xa2') then
        l = l:gsub('^%s*\xe2\x80\xa2', function(match)
          local indent = match:sub(1, -4)
          return indent .. '-'
        end)
      end

      l = l:gsub('\xc2\xa0', ' ')
           :gsub('\xe2\x80\xaf', ' ')
           :gsub('\xe3\x80\x80', ' ')
           :gsub('\xef\xbb\xbf', '')

      -- Convert unicode table box characters (│, ┼, ───)
      if l:match('\xe2\x94\x82') or l:match('\xe2\x94\xbc') then
        l = l:gsub('\xe2\x94\x82', '|'):gsub('\xe2\x94\xbc', '|'):gsub('\xe2\x94\x80', '-')
        local trimmed = l:gsub('%s+$', '')
        if trimmed:match('|') then
          if not trimmed:match('^%s*|') then
            l = '| ' .. l
          end
          if not trimmed:match('|$') then
            l = l .. ' |'
          end
        end
      else
        l = l:gsub('[\xe2\x94\x80]+', '---')
      end

      -- Strip trailing <br/> tags
      l = l:gsub('%s*<%s*br%s*/?%s*>%s*$', ''):gsub('%s*<%s*br%s*/?%s*>', ' ')

      -- Trim leading spaces before ATX headings (#)
      if l:match('^%s+#') then
        l = l:gsub('^%s+', '')
      end

      table.insert(cleaned, l)
    end
  end

  return cleaned
end

-- Core Markdown to PDF compilation function
local function export_pdf(start_line, end_line, output_path, opts)
  opts = opts or {}
  local engine = _G.Config.markdown_to_pdf.engine or 'chrome'

  if not check_dependencies(engine) then
    return
  end

  -- Get markdown lines
  local lines
  if start_line and end_line then
    lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  else
    lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end

  lines = preprocess_markdown_lines(lines)

  local content = table.concat(lines, '\n')
  if not content or content:match('^%s*$') then
    vim.notify('⚠️ Current content/selection is empty!', vim.log.levels.WARN, { title = 'Markdown to PDF' })
    return
  end

  -- Warn if filetype is not markdown
  if vim.bo.filetype ~= 'markdown' then
    vim.notify('⚠️ Filetype is not markdown, attempting conversion anyway...', vim.log.levels.WARN, { title = 'Markdown to PDF' })
  end

  -- Resolve absolute output path
  local resolved_output_path
  if output_path and output_path ~= '' then
    resolved_output_path = vim.fn.expand(output_path)
    if not (resolved_output_path:sub(1, 1) == '/' or resolved_output_path:match('^%a+:')) then
      local buf_name = vim.api.nvim_buf_get_name(0)
      local base_dir = buf_name ~= '' and vim.fn.fnamemodify(buf_name, ':h') or vim.fn.getcwd()
      resolved_output_path = base_dir .. '/' .. resolved_output_path
    end
  else
    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name ~= '' then
      resolved_output_path = vim.fn.fnamemodify(buf_name, ':r') .. '.pdf'
    else
      resolved_output_path = vim.fn.getcwd() .. '/output.pdf'
    end
  end

  -- Ensure target directory exists
  local target_dir = vim.fn.fnamemodify(resolved_output_path, ':h')
  if vim.fn.isdirectory(target_dir) == 0 then
    vim.fn.mkdir(target_dir, 'p')
  end

  -- Write markdown to temp file
  local temp_md = vim.fn.tempname() .. '.md'
  local f = io.open(temp_md, 'w')
  if not f then
    vim.notify('❌ Failed to write temporary markdown file!', vim.log.levels.ERROR, { title = 'Markdown to PDF' })
    return
  end
  f:write(content)
  f:close()

  if engine == 'chrome' then
    -- Retrieve the title first (used in CSS replacement and metadata)
    local buf_name = vim.api.nvim_buf_get_name(0)
    local title = 'Markdown Export'
    if buf_name ~= '' then
      local base_name = vim.fn.fnamemodify(buf_name, ':t:r')
      title = title_case(base_name)
    end

    -- Retrieve CSS theme styling
    local style = _G.Config.markdown_to_pdf.style or 'modern'
    local temp_css
    local is_temp_css = false
    local css_content = BUILTIN_CSS[style]

    if css_content then
      -- Safely escape any Lua pattern characters in the title
      local escaped_title = title:gsub('%%', '%%%%')
      local processed_css = css_content:gsub('{{TITLE}}', escaped_title)
      temp_css = vim.fn.tempname() .. '.css'
      local cf = io.open(temp_css, 'w')
      if cf then
        cf:write(processed_css)
        cf:close()
        is_temp_css = true
      end
    else
      local expanded_style = vim.fn.expand(style)
      if vim.fn.filereadable(expanded_style) == 1 then
        temp_css = expanded_style
      else
        vim.notify(string.format('⚠️ CSS file/theme "%s" not found! Defaulting to "modern".', style), vim.log.levels.WARN, { title = 'Markdown to PDF' })
        temp_css = vim.fn.tempname() .. '.css'
        local cf = io.open(temp_css, 'w')
        if cf then
          local escaped_title = title:gsub('%%', '%%%%')
          local processed_css = BUILTIN_CSS.modern:gsub('{{TITLE}}', escaped_title)
          cf:write(processed_css)
          cf:close()
          is_temp_css = true
        end
      end
    end

    local temp_html = vim.fn.tempname() .. '.html'
    local temp_extra = vim.fn.tempname() .. '_extra.html'

    -- Write Mermaid and Alert helper scripts
    local ef = io.open(temp_extra, 'w')
    if ef then
      ef:write(EXTRA_HTML)
      ef:close()
    end

    -- Pandoc command with MathJax and script injection
    local pandoc_cmd = {
      _G.Config.markdown_to_pdf.pandoc_path,
      '-s',
      '--from=markdown+lists_without_preceding_blankline',
      '--to=html',
      '--mathjax',
      '-A', temp_extra,
      '--metadata', 'title=' .. title,
      '--metadata', 'charset=utf-8',
      '--highlight-style=' .. (_G.Config.markdown_to_pdf.highlight_style or 'tango'),
      '-c', temp_css,
      temp_md,
      '-o', temp_html,
    }

    if not opts.is_auto then
      vim.notify('⚙️ Compiling markdown to HTML...', vim.log.levels.INFO, { title = 'Markdown to PDF' })
    end

    -- Run Pandoc asynchronously
    vim.system(pandoc_cmd, { text = true }, function(pandoc_res)
      if pandoc_res.code ~= 0 then
        vim.schedule(function()
          vim.notify('❌ Pandoc compilation failed:\n' .. (pandoc_res.stderr or ''), vim.log.levels.ERROR, { title = 'Markdown to PDF' })
          cleanup({ temp_md, is_temp_css and temp_css or nil, temp_html, temp_extra })
        end)
        return
      end

      -- Succeeded compiling to HTML, now compile to PDF with Google Chrome
      local chrome_bin = find_chrome()
      if not chrome_bin then
        vim.schedule(function()
          vim.notify('❌ Chrome/Chromium executable not found!', vim.log.levels.ERROR, { title = 'Markdown to PDF' })
          cleanup({ temp_md, is_temp_css and temp_css or nil, temp_html, temp_extra })
        end)
        return
      end

      local chrome_cmd = {
        chrome_bin,
        '--headless',
        '--disable-gpu',
        '--no-pdf-header-footer',
        '--print-to-pdf-no-header',
        '--run-all-compositor-stages-before-draw',
        '--virtual-time-budget=10000',
        '--print-to-pdf=' .. resolved_output_path,
        temp_html,
      }

      if not opts.is_auto then
        vim.schedule(function()
          vim.notify('⚙️ Rendering HTML to PDF with Chrome...', vim.log.levels.INFO, { title = 'Markdown to PDF' })
        end)
      end

      -- Run Google Chrome asynchronously
      vim.system(chrome_cmd, { text = true }, function(chrome_res)
        cleanup({ temp_md, is_temp_css and temp_css or nil, temp_html, temp_extra })

        vim.schedule(function()
          if chrome_res.code ~= 0 then
            vim.notify('❌ Chrome PDF rendering failed:\n' .. (chrome_res.stderr or ''), vim.log.levels.ERROR, { title = 'Markdown to PDF' })
            return
          end

          -- Success!
          if not opts.is_auto then
            vim.notify('✅ PDF exported successfully:\n' .. resolved_output_path, vim.log.levels.INFO, { title = 'Markdown to PDF' })
            if _G.Config.markdown_to_pdf.open_on_export then
              open_pdf(resolved_output_path)
            end
          else
            -- Print subtle confirmation in echo area for auto-compiles to avoid notification spam
            vim.api.nvim_echo({{ '✅ PDF auto-updated: ' .. vim.fn.fnamemodify(resolved_output_path, ':t'), 'Normal' }}, false, {})
          end
        end)
      end)
    end)

  else
    -- LaTeX-based engine (tectonic, xelatex, pdflatex, lualatex)
    local pandoc_cmd = {
      _G.Config.markdown_to_pdf.pandoc_path,
      '--from=markdown+lists_without_preceding_blankline',
      '--pdf-engine=' .. engine,
      temp_md,
      '-o', resolved_output_path,
    }

    if not opts.is_auto then
      vim.notify(string.format('⚙️ Compiling PDF with %s...', engine), vim.log.levels.INFO, { title = 'Markdown to PDF' })
    end

    -- Run Pandoc asynchronously
    vim.system(pandoc_cmd, { text = true }, function(res)
      cleanup({ temp_md })

      vim.schedule(function()
        if res.code ~= 0 then
          vim.notify(string.format('❌ %s compilation failed:\n%s', engine, res.stderr or ''), vim.log.levels.ERROR, { title = 'Markdown to PDF' })
          return
        end

        -- Success!
        if not opts.is_auto then
          vim.notify('✅ PDF exported successfully:\n' .. resolved_output_path, vim.log.levels.INFO, { title = 'Markdown to PDF' })
          if _G.Config.markdown_to_pdf.open_on_export then
            open_pdf(resolved_output_path)
          end
        else
          vim.api.nvim_echo({{ '✅ PDF auto-updated: ' .. vim.fn.fnamemodify(resolved_output_path, ':t'), 'Normal' }}, false, {})
        end
      end)
    end)
  end
end

-- Core Markdown to DOCX compilation function
local function export_docx(start_line, end_line, output_path, opts)
  opts = opts or {}

  if vim.fn.executable(_G.Config.markdown_to_pdf.pandoc_path) == 0 then
    vim.notify('❌ Pandoc is not installed or not in PATH!', vim.log.levels.ERROR, { title = 'Markdown to DOCX' })
    return
  end

  local lines
  if start_line and end_line then
    lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  else
    lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end

  lines = preprocess_markdown_lines(lines)

  local content = table.concat(lines, '\n')
  if not content or content:match('^%s*$') then
    vim.notify('⚠️ Current content/selection is empty!', vim.log.levels.WARN, { title = 'Markdown to DOCX' })
    return
  end

  local resolved_output_path
  if output_path and output_path ~= '' then
    resolved_output_path = vim.fn.expand(output_path)
    if not (resolved_output_path:sub(1, 1) == '/' or resolved_output_path:match('^%a+:')) then
      local buf_name = vim.api.nvim_buf_get_name(0)
      local base_dir = buf_name ~= '' and vim.fn.fnamemodify(buf_name, ':h') or vim.fn.getcwd()
      resolved_output_path = base_dir .. '/' .. resolved_output_path
    end
  else
    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name ~= '' then
      resolved_output_path = vim.fn.fnamemodify(buf_name, ':r') .. '.docx'
    else
      resolved_output_path = vim.fn.getcwd() .. '/output.docx'
    end
  end

  local target_dir = vim.fn.fnamemodify(resolved_output_path, ':h')
  if vim.fn.isdirectory(target_dir) == 0 then
    vim.fn.mkdir(target_dir, 'p')
  end

  local temp_md = vim.fn.tempname() .. '.md'
  local f = io.open(temp_md, 'w')
  if not f then
    vim.notify('❌ Failed to write temporary markdown file!', vim.log.levels.ERROR, { title = 'Markdown to DOCX' })
    return
  end
  f:write(content)
  f:close()

  local pandoc_cmd = {
    _G.Config.markdown_to_pdf.pandoc_path,
    '-s',
    '--from=markdown+lists_without_preceding_blankline',
    temp_md,
    '-o', resolved_output_path,
  }

  if not opts.is_auto then
    vim.notify('⚙️ Compiling markdown to DOCX...', vim.log.levels.INFO, { title = 'Markdown to DOCX' })
  end

  vim.system(pandoc_cmd, { text = true }, function(res)
    cleanup({ temp_md })

    vim.schedule(function()
      if res.code ~= 0 then
        vim.notify('❌ Pandoc DOCX compilation failed:\n' .. (res.stderr or ''), vim.log.levels.ERROR, { title = 'Markdown to DOCX' })
        return
      end

      vim.notify('✅ DOCX exported successfully:\n' .. resolved_output_path, vim.log.levels.INFO, { title = 'Markdown to DOCX' })
    end)
  end)
end

-- Expose functions globally
_G.Config.markdown_to_pdf.export = export_pdf
_G.Config.markdown_to_pdf.export_docx = export_docx

-- Create Neovim user commands
vim.api.nvim_create_user_command('MarkdownToPDF', function(cmd_opts)
  local start_line, end_line = nil, nil
  if cmd_opts.range > 0 then
    start_line = cmd_opts.line1
    end_line = cmd_opts.line2
  end
  local output_path = cmd_opts.args ~= '' and cmd_opts.args or nil
  export_pdf(start_line, end_line, output_path)
end, {
  range = true,
  nargs = '?',
  complete = 'file',
  desc = 'Export current markdown buffer (or visual selection) to PDF',
})

vim.api.nvim_create_user_command('MarkdownToDOCX', function(cmd_opts)
  local start_line, end_line = nil, nil
  if cmd_opts.range > 0 then
    start_line = cmd_opts.line1
    end_line = cmd_opts.line2
  end
  local output_path = cmd_opts.args ~= '' and cmd_opts.args or nil
  export_docx(start_line, end_line, output_path)
end, {
  range = true,
  nargs = '?',
  complete = 'file',
  desc = 'Export current markdown buffer (or visual selection) to DOCX',
})

vim.api.nvim_create_user_command('MarkdownToPDFStyle', function()
  local styles = { 'modern', 'github', 'academic' }
  vim.ui.select(styles, {
    prompt = 'Select Markdown PDF theme (for Chrome engine):',
    default = _G.Config.markdown_to_pdf.style,
  }, function(choice)
    if choice then
      _G.Config.markdown_to_pdf.style = choice
      vim.notify(string.format('Markdown PDF theme set to: %s', choice), vim.log.levels.INFO, { title = 'Markdown to PDF' })
    end
  end)
end, { desc = 'Select Markdown PDF CSS theme' })

vim.api.nvim_create_user_command('MarkdownToPDFEngine', function()
  local engines = { 'chrome', 'tectonic', 'xelatex', 'pdflatex', 'lualatex' }
  vim.ui.select(engines, {
    prompt = 'Select Markdown PDF engine:',
    default = _G.Config.markdown_to_pdf.engine,
  }, function(choice)
    if choice then
      _G.Config.markdown_to_pdf.engine = choice
      vim.notify(string.format('Markdown PDF engine set to: %s', choice), vim.log.levels.INFO, { title = 'Markdown to PDF' })
    end
  end)
end, { desc = 'Select Markdown PDF rendering engine' })

vim.api.nvim_create_user_command('MarkdownToPDFAutoToggle', function()
  local bufnr = vim.api.nvim_get_current_buf()
  if auto_compile_buffers[bufnr] then
    auto_compile_buffers[bufnr] = nil
    vim.notify('🔄 PDF Auto-compile: DISABLED for this buffer', vim.log.levels.INFO, { title = 'Markdown to PDF' })
  else
    auto_compile_buffers[bufnr] = true
    vim.notify('🔄 PDF Auto-compile: ENABLED for this buffer (compiles on save)', vim.log.levels.INFO, { title = 'Markdown to PDF' })
    -- Compile once immediately
    export_pdf(nil, nil, nil, { is_auto = true })
  end
end, { desc = 'Toggle PDF auto-compilation on save for current buffer' })

-- Set up keymaps and autocommands in later phase to prevent blocking startup
_G.Config.later(function()
  -- Keymaps for Normal and Visual/Select mode
  vim.keymap.set('n', '<Leader>op', '<Cmd>MarkdownToPDF<CR>', { desc = 'Export Markdown to PDF' })
  vim.keymap.set('n', '<Leader>ow', '<Cmd>MarkdownToDOCX<CR>', { desc = 'Export Markdown to DOCX' })

  vim.keymap.set('x', '<Leader>op', function()
    -- Exit visual mode to save '< and '> marks
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'x', true)
    -- Schedule execution to ensure marks are flushed
    vim.schedule(function()
      local start_line = vim.api.nvim_buf_get_mark(0, '<')[1]
      local end_line = vim.api.nvim_buf_get_mark(0, '>')[1]
      export_pdf(start_line, end_line)
    end)
  end, { desc = 'Export visual selection to PDF' })

  vim.keymap.set('x', '<Leader>ow', function()
    -- Exit visual mode to save '< and '> marks
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'x', true)
    -- Schedule execution to ensure marks are flushed
    vim.schedule(function()
      local start_line = vim.api.nvim_buf_get_mark(0, '<')[1]
      local end_line = vim.api.nvim_buf_get_mark(0, '>')[1]
      export_docx(start_line, end_line)
    end)
  end, { desc = 'Export visual selection to DOCX' })

  vim.keymap.set('n', '<Leader>oa', '<Cmd>MarkdownToPDFAutoToggle<CR>', { desc = 'Toggle PDF Auto-compile' })

  -- Autocommand for buffers with auto-compiling active
  vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = '*.md',
    callback = function(ev)
      if auto_compile_buffers[ev.buf] then
        export_pdf(nil, nil, nil, { is_auto = true })
      end
    end,
    desc = 'Auto-compile markdown to PDF on save',
  })
end)

