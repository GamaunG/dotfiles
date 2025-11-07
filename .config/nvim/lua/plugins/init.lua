---@module 'lazy'
---@type LazySpec
return {

	{
		"neovim/nvim-lspconfig", -- https://github.com/neovim/nvim-lspconfig
		config = function()
			require "configs.lspconfig"
		end,
	},

	{ import = "nvchad.blink.lazyspec" },
	{
		"Saghen/blink.cmp", -- https://github.com/Saghen/blink.cmp
		opts = {
			completion = {
				-- documentation = { auto_show = true },
				-- keyword = { range = "full" },
				ghost_text = { enabled = true },
				list = { selection = { preselect = true, auto_insert = false } },
				menu = {
					max_height = 30,
				},
			},

			sources = {
				providers = {
					path = {
						opts = {
							get_cwd = function(_)
								return vim.fn.getcwd()
							end,
						},
					},
				},
			},

			fuzzy = {
				sorts = {
					"exact",
					"score",
					"sort_text",
				},
			},
		},
	},

	{
		"nvim-treesitter/nvim-treesitter", -- https://github.com/nvim-treesitter/nvim-treesitter
		opts = {
			ensure_installed = {
				"vim",
				"lua",
				"vimdoc",
				"html",
				"css",
				"go",
				"printf",
				"bash",
			},
			highlight = {
				enable = true,
				-- disable = { "bash" },
			},
		},
	},

	{
		"stevearc/conform.nvim", -- https://github.com/stevearc/conform.nvim
		-- event = 'BufWritePre', -- uncomment for format on save
		opts = require "configs.conform",
	},

	{
		"mfussenegger/nvim-dap", -- https://github.com/mfussenegger/nvim-dap
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			require "configs.dap"
		end,
	},

	-- Disabled defaults:
	{ "nvim-tree/nvim-tree.lua", enabled = false }, -- https://github.com/nvim-tree/nvim-tree.lua
}
