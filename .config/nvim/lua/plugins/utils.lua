---@module 'lazy'
---@type LazySpec
return {

	{
		"kylechui/nvim-surround", -- https://github.com/kylechui/nvim-surround
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup {
				-- Configuration here, or leave empty to use defaults
			}
		end,
	},

	{
		"laytan/cloak.nvim", -- https://github.com/laytan/cloak.nvim
		lazy = false,
		config = function()
			require "configs.cloak"
		end,
	},

	{
		"mbbill/undotree", -- https://github.com/mbbill/undotree
		cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeFocus" },
	},

}
