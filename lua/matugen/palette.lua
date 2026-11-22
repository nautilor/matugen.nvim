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

local function hex_to_hsl(hex)
	local r, g, b = hex:match("^#(%x%x)(%x%x)(%x%x)$")
	r, g, b = tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local l, h, s = (max + min) / 2, 0, 0
	local d = max - min
	if d ~= 0 then
		s = l > 0.5 and d / (2 - max - min) or d / (max + min)
		if max == r then
			h = ((g - b) / d) % 6
		elseif max == g then
			h = (b - r) / d + 2
		else
			h = (r - g) / d + 4
		end
		h = h * 60
	end
	return h, s, l
end

local function hsl_to_hex(h, s, l)
	local c = (1 - math.abs(2 * l - 1)) * s
	local x = c * (1 - math.abs((h / 60) % 2 - 1))
	local m = l - c / 2
	local r, g, b
	if h < 60 then
		r, g, b = c, x, 0
	elseif h < 120 then
		r, g, b = x, c, 0
	elseif h < 180 then
		r, g, b = 0, c, x
	elseif h < 240 then
		r, g, b = 0, x, c
	elseif h < 300 then
		r, g, b = x, 0, c
	else
		r, g, b = c, 0, x
	end
	return string.format("#%02X%02X%02X",
		math.floor((r + m) * 255 + 0.5), math.floor((g + m) * 255 + 0.5), math.floor((b + m) * 255 + 0.5))
end

local function load_file()
	local path = M.path()
	if vim.fn.filereadable(path) == 0 then return nil end
	local chunk = loadfile(path)
	if not chunk then return nil end
	local ok, data = pcall(chunk)
	return ok and type(data) == "table" and data or nil
end

-- Max degrees a candidate hue may be from an accent's seed hue to claim it.
local match_range = 50
-- Max degrees an unmatched accent drifts toward the primary hue.
local drift = 20

local accents = { "purple", "green", "orange", "blue", "yellow", "cyan", "red" }

local function hue_diff(a, b)
	return ((a - b + 180) % 360) - 180
end

-- Colors the scheme itself defines (primary/secondary/tertiary/error) are the
-- only per-scheme signal matugen gives us: its custom colors (red, green, ...)
-- are fixed regardless of scheme. Assign each scheme color to the accent slot
-- with the closest seed hue (greedy, one slot per color), keeping its hue and
-- (mostly) its saturation. Unclaimed slots keep the seed hue, nudged toward primary.
local function pick_accents(m, mode)
	local out, seed = {}, seeds[mode]
	local cands = {}
	for _, key in ipairs({ "error", "primary", "secondary", "tertiary" }) do
		if m[key] then
			local h, s = hex_to_hsl(m[key])
			if s > 0.08 then cands[#cands + 1] = { h = h, s = s } end
		end
	end
	local pairs_ = {}
	for ci, c in ipairs(cands) do
		for _, name in ipairs(accents) do
			local d = math.abs(hue_diff(c.h, (hex_to_hsl(seed[name]))))
			if d <= match_range then pairs_[#pairs_ + 1] = { ci = ci, name = name, d = d } end
		end
	end
	table.sort(pairs_, function(x, y) return x.d < y.d end)
	local used = {}
	for _, pr in ipairs(pairs_) do
		if not used[pr.ci] and not out[pr.name] then
			used[pr.ci], out[pr.name] = true, pr.ci
		end
	end
	for _, name in ipairs(accents) do
		local sh, ss, sl = hex_to_hsl(seed[name])
		if out[name] then
			local c = cands[out[name]]
			out[name] = hsl_to_hex(c.h, math.max(c.s, ss * 0.6), sl)
		else
			local ph = m.primary and hex_to_hsl(m.primary) or sh
			local d = math.max(-drift, math.min(drift, hue_diff(ph, sh) * 0.5))
			out[name] = hsl_to_hex((sh + d) % 360, ss, sl)
		end
	end
	return out
end

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

	for name, hex in pairs(pick_accents(m, mode)) do p[name] = hex end
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
