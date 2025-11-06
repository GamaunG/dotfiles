require "nvchad.options"
local o = vim.o
local g = vim.g
local cmd = vim.cmd


cmd "set spelllang=en_us,ru"
o.scrolloff = 10
o.number = true
o.relativenumber = true
o.clipboard = "unnamed"
o.expandtab = false
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.title = true
o.fileencodings = "ucs-bom,utf-8,default,cp1251,latin1"
o.foldminlines = 5
o.linebreak = true
o.breakindent = true
o.showbreak = "⤷ "
o.timeoutlen = 300

o.whichwrap = ""

g.netrw_browse_split = 0
g.netrw_liststyle = 3
g.netrw_banner = 0

-- o.cursorlineopt ='both' -- to enable cursorline!
