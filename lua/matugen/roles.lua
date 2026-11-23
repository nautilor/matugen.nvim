-- Optional per-colorscheme syntax roles.
--
-- A script that generates the palette from a colorscheme (see README) may also
-- write a roles file next to it: a table of role name -> "#rrggbb" or
-- { fg = "#rrggbb", bold = true, italic = true, underline = true }, plus the
-- scheme's `background`. The roles let the theme reproduce the exact syntax
-- layout of the scheme's own Neovim colorscheme (keywords red, functions green, ...).
--
-- The file is ignored unless its `background` equals the current bg0, so a stale
-- file from a previous colorscheme never leaks into a wallpaper-derived palette.
local M = {}

function M.path()
	return vim.g.matugen_roles_path or (vim.fn.stdpath("state") .. "/matugen/roles.lua")
end

local function valid_hex(v)
	return type(v) == "string" and v:match("^#%x%x%x%x%x%x$") ~= nil
end

---@param bg0 string current background color
---@return table<string, {fg: string, fmt: string?}>
function M.load(bg0)
	local path = M.path()
	if vim.fn.filereadable(path) == 0 then return {} end
	local chunk = loadfile(path)
	if not chunk then return {} end
	local ok, data = pcall(chunk)
	if not ok or type(data) ~= "table" or not valid_hex(data.background) then return {} end
	if data.background:lower() ~= bg0:lower() then return {} end

	local roles = {}
	for name, v in pairs(data.roles or {}) do
		local fg, styles = nil, {}
		if valid_hex(v) then
			fg = v
		elseif type(v) == "table" and valid_hex(v.fg) then
			fg = v.fg
			for _, s in ipairs({ "bold", "italic", "underline", "undercurl", "strikethrough" }) do
				if v[s] then styles[#styles + 1] = s end
			end
		end
		if fg then
			roles[name] = { fg = fg, fmt = type(v) == "table" and (#styles > 0 and table.concat(styles, ",") or "none") or nil }
		end
	end
	return roles
end

return M
