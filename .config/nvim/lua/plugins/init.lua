return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"leoluz/nvim-dap-go",
			"mfussenegger/nvim-dap-python",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			require "configs.dap"
		end,
	},
	{
		"theprimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon").setup()
		end,
	},

	{
		"mbbill/undotree",
		cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeFocus" },
	},

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

	-- { -- Broken?
	-- 	"iamcco/markdown-preview.nvim",
	-- 	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	-- 	ft = { "markdown" },
	-- 	build = function()
	-- 		vim.fn["mkdp#util#install"]()
	-- 	end,
	-- },

	{
		"stevearc/conform.nvim",
		-- event = 'BufWritePre', -- uncomment for format on save
		opts = require "configs.conform",
	},

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
				disable = { "bash" },
			},
		},
	},

	-- Overrides:
	{
		"nvim-telescope/telescope.nvim",
		opts = function(_, conf)
			conf.defaults.mappings.i = {
				["<C-q>"] = require("telescope.actions").smart_send_to_qflist,
			}
			conf.defaults.mappings.n = {
				["<C-q>"] = require("telescope.actions").smart_send_to_qflist,
				["q"] = require("telescope.actions").close,
			}
			-- or
			-- table.insert(conf.defaults.mappings.i, your table)
			return conf
		end,
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

	-- Disabled defaults:
	{ "nvim-tree/nvim-tree.lua", enabled = false },
}
