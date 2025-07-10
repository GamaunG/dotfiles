---@module 'lazy'
---@type LazySpec
return {

	{
		"iamcco/markdown-preview.nvim", -- https://github.com/iamcco/markdown-preview.nvim
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function(plugin)
			if vim.fn.executable "npx" then
				vim.cmd("!cd " .. plugin.dir .. " && cd app && npx --yes yarn install")
			else
				vim.cmd [[Lazy load markdown-preview.nvim]]
				vim.fn["mkdp#util#install"]()
			end
		end,
		init = function()
			if vim.fn.executable "npx" then
				vim.g.mkdp_filetypes = { "markdown" }
			end
		end,
	},

	{ -- https://github.com/MeanderingProgrammer/render-markdown.nvim
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		ft = { "markdown" },
		config = function()
			dofile(vim.g.base46_cache .. "render-markdown")
			require "configs.markdown"
		end,
	},

	-- {
	-- 	"OXY2DEV/markview.nvim", -- https://github.com/OXY2DEV/markview.nvim
	-- 	-- lazy = false,
	-- 	ft = { "markdown" },
	--
	-- 	-- For blink.cmp's completion
	-- 	-- source
	-- 	-- dependencies = {
	-- 	--     "saghen/blink.cmp"
	-- 	-- },
	-- },

}
