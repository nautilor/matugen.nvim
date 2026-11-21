# matugen.nvim

Neovim colorscheme generated from your [matugen](https://github.com/InioX/matugen) (Material You) palette.
Every color comes from matugen: surfaces and text from the Material roles, accents (`red`, `green`, `blue`, ...)
from matugen custom colors, which it blends toward your wallpaper so they stay recognisable but match your desktop.
The `dark_*`, `diff_*` and `bg_blue`/`bg_yellow` colors are derived from those.

Follows `vim.o.background` (dark/light). If matugen hasn't generated anything yet, a built-in fallback palette is used.

## 1. Matugen setup

Register the template in `~/.config/matugen/config.toml`:

```toml
[templates.nvim]
input_path  = '~/.local/share/nvim/lazy/matugen.nvim/matugen/nvim-palette.lua'
output_path = '~/.local/state/nvim/matugen/palette.lua'
```

- `input_path` is the template shipped with this plugin (adjust if you install elsewhere).
- `output_path` is `vim.fn.stdpath("state") .. "/matugen/palette.lua"`, where the plugin looks by default.
  To write somewhere else, set `vim.g.matugen_palette_path = "/your/path/palette.lua"` before loading the colorscheme.

The template also needs the accent colors declared as matugen custom colors (matugen blends them with your wallpaper):

```toml
[config.custom_colors]
red = "#e86671"
green = "#98c379"
yellow = "#e5c07b"
orange = "#d19a66"
blue = "#61afef"
cyan = "#56b6c2"
purple = "#c678dd"
```

Then run matugen as usual, e.g. `matugen image /path/to/wallpaper.png`.

## 2. Install with lazy.nvim

```lua
{
  "your-user/matugen.nvim", -- or dir = "~/Sources/PERSONAL/matugen.nvim" for a local checkout
  lazy = false,
  priority = 1000,
  config = function()
    require("matugen").setup({
      -- all options are optional, defaults shown below
    })
    vim.cmd.colorscheme("matugen")
  end,
}
```

## Usage

```lua
local colorscheme = require("matugen.colors")
print(colorscheme.bg0, colorscheme.fg, colorscheme.red)
```

Available names: `none`, `black`, `bg0`-`bg3`, `bg_d`, `bg_blue`, `bg_yellow`, `fg`, `purple`, `green`, `orange`,
`blue`, `yellow`, `cyan`, `red`, `grey`, `light_grey`, `dark_cyan`, `dark_red`, `dark_yellow`, `dark_purple`,
`diff_add`, `diff_delete`, `diff_change`, `diff_text`.

### Lualine / Barbecue

```lua
require("lualine").setup({ options = { theme = "matugen" } })
require("barbecue").setup({ theme = "matugen" })
```

### Toggle dark/light

`require("matugen").toggle()` flips `vim.o.background` and reloads the colorscheme.
Set `toggle_key = "<leader>tt"` in setup to bind it.

## Options

```lua
require("matugen").setup({
  toggle_key = nil,              -- normal-mode key that toggles dark/light
  transparent = false,           -- don't set background
  term_colors = true,            -- set terminal colors
  ending_tildes = false,         -- show end-of-buffer tildes
  cmp_itemkind_reverse = false,  -- reverse item kind highlights in cmp menu

  code_style = {
    comments = "italic",
    keywords = "none",
    functions = "none",
    strings = "none",
    variables = "none",
  },

  lualine = { transparent = false }, -- transparent center bar

  colors = {},      -- override individual colors, e.g. { red = "#ff0000" }
  highlights = {},  -- override highlight groups, e.g. { Comment = { fg = "#888888" } }

  diagnostics = {
    darker = true,     -- darker colors for diagnostics
    undercurl = true,  -- use undercurl
    background = true, -- background for virtual text
  },
})
```

## Reloading when the wallpaper changes

After matugen regenerates the palette, run `:colorscheme matugen` in open Neovim instances.
Lualine and Barbecue read colors when their theme loads, so call their `setup` again as well.
To do it automatically, watch the generated file:

```lua
local path = vim.g.matugen_palette_path or (vim.fn.stdpath("state") .. "/matugen/palette.lua")
local watcher = vim.uv.new_fs_event()
watcher:start(vim.fs.dirname(path), {}, vim.schedule_wrap(function(_, name)
  if name == vim.fs.basename(path) then
    vim.cmd.colorscheme("matugen")
    require("lualine").setup({ options = { theme = "matugen" } })
  end
end))
```
