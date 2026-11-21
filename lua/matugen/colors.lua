-- local colorscheme = require("matugen.colors")
local selected = { none = "none" }
selected = vim.tbl_extend("force", selected, require("matugen.palette").get())
local cfg = vim.g.matugen_config
if cfg and cfg.colors then
	selected = vim.tbl_extend("force", selected, cfg.colors)
end
return selected
