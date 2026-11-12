local get_files = ya.sync(function()
	local files = {}
	for _, file in pairs(cx.active.selected) do
		files[#files + 1] = tostring(file.url)
	end
	if #files == 0 then
		local hovered = cx.active.current.hovered
		if hovered then
			files[1] = tostring(hovered.url)
		end
	end
	return files
end)

return {
	entry = function()
		local files = get_files()
		if #files == 0 then
			ya.notify({ title = "Clipboard", content = "No files to copy", timeout = 2, level = "warn" })
			return
		end

		local uris = {}
		for _, path in ipairs(files) do
			local encoded = path:gsub("([^A-Za-z0-9/_.~-])", function(c)
				return string.format("%%%02X", string.byte(c))
			end)
			uris[#uris + 1] = "file://" .. encoded
		end

		local sh_args = { "-c", [[printf '%s\r\n' "$@" | wl-copy -t text/uri-list]], "--" }
		for _, uri in ipairs(uris) do
			table.insert(sh_args, uri)
		end

		local child, err = Command("sh")
			:arg(sh_args)
			:stdout(Command.NULL)
			:stderr(Command.NULL)
			:spawn()
		if err then
			ya.notify({ title = "Clipboard", content = "Spawn failed: " .. tostring(err), timeout = 3, level = "error" })
			return
		end
		local status, werr = child:wait()
		if werr then
			ya.notify({ title = "Clipboard", content = "Wait failed: " .. tostring(werr), timeout = 3, level = "error" })
			return
		end
		if status and not status.success then
			ya.notify({ title = "Clipboard", content = "wl-copy exited " .. tostring(status.code), timeout = 3, level = "error" })
			return
		end

		ya.notify({ title = "Clipboard", content = "Copied " .. #files .. " file(s)", timeout = 2 })
	end,
}
