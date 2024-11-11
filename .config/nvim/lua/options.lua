require "nvchad.options"
require "shortcuts"
-- add yours here!
local o = vim.o
local g = vim.g
local cmd = vim.cmd
local autocmd = vim.api.nvim_create_autocmd
cmd "set spelllang=en_us,ru"

o.langmap =
	"ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"
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

o.whichwrap = ""

g.netrw_browse_split = 0
g.netrw_liststyle = 3
g.netrw_banner = 0

-- o.cursorlineopt ='both' -- to enable cursorline!

autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line "'\""
    if
      line > 1
      and line <= vim.fn.line "$"
      and vim.bo.filetype ~= "commit"
      and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
    then
      vim.cmd 'normal! g`"zz'
    end
  end,
})

