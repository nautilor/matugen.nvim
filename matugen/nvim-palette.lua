-- Matugen template. Register in ~/.config/matugen/config.toml:
--
--   [templates.nvim]
--   input_path  = '<path-to-this-plugin>/matugen/nvim-palette.lua'
--   output_path = '~/.local/state/nvim/matugen/palette.lua'
--
-- Needs these custom colors in config.toml (see README):
--   [config.custom_colors]
--   red = "#e86671" ... green, yellow, orange, blue, cyan, purple
--
-- (output path = vim.fn.stdpath("state") .. "/matugen/palette.lua",
--  or set vim.g.matugen_palette_path to wherever you write it)
return {
	dark = {
		surface = "{{colors.surface.dark.hex}}",
		surface_dim = "{{colors.surface_dim.dark.hex}}",
		surface_container_lowest = "{{colors.surface_container_lowest.dark.hex}}",
		surface_container_low = "{{colors.surface_container_low.dark.hex}}",
		surface_container = "{{colors.surface_container.dark.hex}}",
		surface_container_high = "{{colors.surface_container_high.dark.hex}}",
		on_surface = "{{colors.on_surface.dark.hex}}",
		on_surface_variant = "{{colors.on_surface_variant.dark.hex}}",
		outline = "{{colors.outline.dark.hex}}",
		primary = "{{colors.primary.dark.hex}}",
		error = "{{colors.error.dark.hex}}",
		red = "{{colors.red.dark.hex}}",
		green = "{{colors.green.dark.hex}}",
		yellow = "{{colors.yellow.dark.hex}}",
		orange = "{{colors.orange.dark.hex}}",
		blue = "{{colors.blue.dark.hex}}",
		cyan = "{{colors.cyan.dark.hex}}",
		purple = "{{colors.purple.dark.hex}}",
	},
	light = {
		surface = "{{colors.surface.light.hex}}",
		surface_dim = "{{colors.surface_dim.light.hex}}",
		surface_container_lowest = "{{colors.surface_container_lowest.light.hex}}",
		surface_container_low = "{{colors.surface_container_low.light.hex}}",
		surface_container = "{{colors.surface_container.light.hex}}",
		surface_container_high = "{{colors.surface_container_high.light.hex}}",
		on_surface = "{{colors.on_surface.light.hex}}",
		on_surface_variant = "{{colors.on_surface_variant.light.hex}}",
		outline = "{{colors.outline.light.hex}}",
		primary = "{{colors.primary.light.hex}}",
		error = "{{colors.error.light.hex}}",
		red = "{{colors.red.light.hex}}",
		green = "{{colors.green.light.hex}}",
		yellow = "{{colors.yellow.light.hex}}",
		orange = "{{colors.orange.light.hex}}",
		blue = "{{colors.blue.light.hex}}",
		cyan = "{{colors.cyan.light.hex}}",
		purple = "{{colors.purple.light.hex}}",
	},
}
