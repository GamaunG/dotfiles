---@module 'lazy'
---@type LazySpec
return {

	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup {
				-- Configuration here, or leave empty to use defaults
			}
		end,
	},

	{
		"laytan/cloak.nvim",
		lazy = false,
		config = function()
			require "configs.cloak"
		end,
	},

	{
		"mbbill/undotree",
		cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeFocus" },
	},
}
