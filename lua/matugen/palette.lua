-- Builds the color palette from a matugen-generated file.
local util = require("matugen.util")

-- Fallback colors, used when no matugen output exists and as the hue/tone
-- seeds for the accent colors (red, green, ...).
local seeds = {
	dark = {
		black = "#181a1f",
		bg0 = "#282c34",
		bg1 = "#31353f",
		bg2 = "#393f4a",
		bg3 = "#3b3f4c",
		bg_d = "#21252b",
		bg_blue = "#73b8f1",
		bg_yellow = "#ebd09c",
		fg = "#abb2bf",
		purple = "#c678dd",
		green = "#98c379",
		orange = "#d19a66",
		blue = "#61afef",
		yellow = "#e5c07b",
		cyan = "#56b6c2",
		red = "#e86671",
		grey = "#5c6370",
		light_grey = "#848b98",
		dark_cyan = "#2b6f77",
		dark_red = "#993939",
		dark_yellow = "#93691d",
		dark_purple = "#8a3fa0",
		diff_add = "#31392b",
		diff_delete = "#382b2c",
		diff_change = "#1c3448",
		diff_text = "#2c5372",
	},
	light = {
		black = "#101012",
		bg0 = "#fafafa",
		bg1 = "#f0f0f0",
		bg2 = "#e6e6e6",
		bg3 = "#dcdcdc",
		bg_d = "#c9c9c9",
		bg_blue = "#68aee8",
		bg_yellow = "#e2c792",
		fg = "#383a42",
		purple = "#a626a4",
		green = "#50a14f",
		orange = "#c18401",
		blue = "#4078f2",
		yellow = "#986801",
		cyan = "#0184bc",
		red = "#e45649",
		grey = "#a0a1a7",
		light_grey = "#818387",
		dark_cyan = "#2b5d63",
		dark_red = "#833b3b",
		dark_yellow = "#7c5c20",
		dark_purple = "#79428a",
		diff_add = "#e2fbe4",
		diff_delete = "#fce2e5",
		diff_change = "#e2ecfb",
		diff_text = "#cad3e0",
	},
}

local M = {}

function M.path()
	return vim.g.matugen_palette_path or (vim.fn.stdpath("state") .. "/matugen/palette.lua")
end

local function load_file()
	local path = M.path()
	if vim.fn.filereadable(path) == 0 then return nil end
	local chunk = loadfile(path)
	if not chunk then return nil end
	local ok, data = pcall(chunk)
	return ok and type(data) == "table" and data or nil
end

local accents = { "purple", "green", "orange", "blue", "yellow", "cyan", "red" }

---@param mode? "dark"|"light" defaults to vim.o.background
function M.get(mode)
	mode = mode or (vim.o.background == "light" and "light" or "dark")
	local ref = vim.deepcopy(seeds[mode])
	local data = load_file()
	local m = data and data[mode]
	if not m then return ref end -- no matugen output yet: fall back to seeds

	local p = ref
	p.bg0 = m.surface
	p.bg1 = m.surface_container_low
	p.bg2 = m.surface_container
	p.bg3 = m.surface_container_high
	p.bg_d = mode == "dark" and m.surface_container_lowest or m.surface_dim
	p.black = mode == "dark" and util.darken(m.surface_container_lowest, 0.5) or seeds.light.black
	p.fg = m.on_surface
	p.light_grey = m.on_surface_variant
	p.grey = m.outline

	-- Accents come straight from matugen's red/green/... colors. With a colorscheme
	-- they are the scheme's own hues (see matugen-scheme.py in quickshell-notch);
	-- missing ones keep the seed color.
	for _, name in ipairs(accents) do p[name] = m[name] or ref[name] end
	p.bg_blue = util.blend(p.blue, p.fg, 0.85)
	p.bg_yellow = util.blend(p.yellow, p.fg, 0.85)
	for _, name in ipairs({ "cyan", "red", "yellow", "purple" }) do
		p["dark_" .. name] = util.blend(p[name], p.bg0, 0.45)
	end
	p.diff_add = util.blend(p.green, p.bg0, 0.15)
	p.diff_delete = util.blend(p.red, p.bg0, 0.15)
	p.diff_change = util.blend(p.blue, p.bg0, 0.15)
	p.diff_text = util.blend(p.blue, p.bg0, 0.3)
	return p
end

return M
