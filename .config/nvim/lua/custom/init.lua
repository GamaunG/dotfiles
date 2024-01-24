-- local autocmd = vim.api.nvim_create_autocmd
require "custom.shortcuts"
local opt = vim.opt
local cmd = vim.cmd
local g   = vim.g
cmd("set spelllang=en_us,ru")

opt.langmap = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'
opt.scrolloff=10
opt.number = true
opt.relativenumber = true
opt.clipboard = "unnamed"

opt.whichwrap= "" --disable


g.netrw_browse_split = 0
g.netrw_liststyle = 3
g.netrw_banner = 0
-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
