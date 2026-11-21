local M = {}

---Change matugen option (vim.g.matugen_config.option)
---It can't be changed directly by modifying that field due to a Neovim lua bug with global variables (matugen_config is a global variable)
---@param opt string: option name
---@param value any: new value
function M.set_options(opt, value)
    local cfg = vim.g.matugen_config
    cfg[opt] = value
    vim.g.matugen_config = cfg
end

---Apply the colorscheme (same as ':colorscheme matugen')
function M.colorscheme()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
    vim.o.termguicolors = true
    vim.g.colors_name = "matugen"
    require('matugen.highlights').setup()
    require('matugen.terminal').setup()
end

---Toggle between the dark and light matugen scheme
function M.toggle()
    vim.o.background = vim.o.background == 'light' and 'dark' or 'light'
    vim.api.nvim_command('colorscheme matugen')
end

local default_config = {
    -- Main options --
    toggle_key = nil,    -- keymap (normal mode) that toggles dark/light
    transparent = false,     -- don't set background
    term_colors = true,      -- if true enable the terminal
    ending_tildes = false,    -- show the end-of-buffer tildes
    cmp_itemkind_reverse = false,    -- reverse item kind highlights in cmp menu

    -- Changing Formats --
    code_style = {
        comments = 'italic',
        keywords = 'none',
        functions = 'none',
        strings = 'none',
        variables = 'none'
    },

    -- Lualine options --
    lualine = {
        transparent = false, -- center bar (c) transparency
    },

    -- Custom Highlights --
    colors = {}, -- Override default colors
    highlights = {}, -- Override highlight groups

    -- Plugins Related --
    diagnostics = {
        darker = true, -- darker colors for diagnostic
        undercurl = true,   -- use undercurl for diagnostics
        background = true,    -- use background color for virtual text
    },
}

---Setup matugen.nvim options, without applying colorscheme
---@param opts table: a table containing options
function M.setup(opts)
    if not vim.g.matugen_config or not vim.g.matugen_config.loaded then    -- if it's the first time setup() is called
        vim.g.matugen_config = vim.tbl_deep_extend('keep', vim.g.matugen_config or {}, default_config)
        M.set_options('loaded', true)
    end
    if opts then
        vim.g.matugen_config = vim.tbl_deep_extend('force', vim.g.matugen_config, opts)
    end
    if vim.g.matugen_config.toggle_key then
      vim.api.nvim_set_keymap('n', vim.g.matugen_config.toggle_key, '<cmd>lua require("matugen").toggle()<cr>', { noremap = true, silent = true })
    end
end

function M.load()
  vim.api.nvim_command('colorscheme matugen')
end

return M
