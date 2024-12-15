---@module 'lazy'
---@type LazySpec
return {

	{
		"theprimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon").setup()
		end,
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

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
	},

	{
		"rolv-apneseth/tfm.nvim",
		-- lazy = false,
		cmd = { "Tfm", "TfmSplit", "TfmVsplit", "TfmTabedit" },
		opts = {
			file_manager = "lf",
			-- replace_netrw = true,
			enable_cmds = true,
			keybindings = {
				["<ESC>"] = "q",
			},
			ui = {
				border = "rounded",
				height = 0.92,
				width = 0.95,
				x = 0.5,
				y = 0.5,
			},
		},
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"vim",
				"lua",
				"printf",
			},
			highlight = {
				enable = true,
				disable = { "bash" },
			},
		},
	},

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

	{ "nvim-tree/nvim-tree.lua", enabled = false },
	{ "neovim/nvim-lspconfig", enabled = false },
	{ "nvzone/volt", enabled = false },
	{ "nvzone/minty", enabled = false },
	{ "hrsh7th/cmp-nvim-lsp", enabled = false },
	{ "williamboman/mason.nvim", enabled = false },
	{ "L3MON4D3/LuaSnip", enabled = false },
	{ "stevearc/conform.nvim", enabled = false },
}
