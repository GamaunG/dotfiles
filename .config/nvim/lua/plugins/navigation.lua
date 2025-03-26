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

	{ -- Overrides default nvchad config:
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
}
