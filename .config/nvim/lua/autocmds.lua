local autocmd = vim.api.nvim_create_autocmd

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

autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank {
			higroup = "PmenuThumb",
			priority = 1025, -- ibl.config.scope.priority + 1
			-- timeout = 100,
		}
	end,
})

autocmd("FileType", {
	pattern = "man",
	callback = function()
		vim.wo.signcolumn = "no"
	end,
})

-- autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained", "FileChangedShellPost" }, {
-- 	command = "if mode() != 'c' | checktime | endif",
-- 	pattern = { "*" },
-- })
