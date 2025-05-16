---@module 'lazy'
---@type LazySpec
return {

	{
		"neovim/nvim-lspconfig",
		config = function()
			require "configs.lspconfig"
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"vim",
				"lua",
				"vimdoc",
				"html",
				"css",
				"go",
				"printf",
			},
			highlight = {
				enable = true,
				-- disable = { "bash" },
			},
		},
	},

	{
		"williamboman/mason.nvim",
		opts = function(_, conf)
			conf.ensure_installed = {
				"lua-language-server",
				"prettierd",
				"gopls",
				"clangd",
				"clang-format",
			}
		end,
	},

	{
		"stevearc/conform.nvim",
		-- event = 'BufWritePre', -- uncomment for format on save
		opts = require "configs.conform",
	},

	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			require "configs.dap"
		end,
	},

	-- Disabled defaults:
	{ "nvim-tree/nvim-tree.lua", enabled = false },
}
