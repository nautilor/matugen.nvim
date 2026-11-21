for k in pairs(package.loaded) do
    if k:match(".*matugen.*") then package.loaded[k] = nil end
end

require('matugen').setup()
require('matugen').colorscheme()
