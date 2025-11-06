---@module 'lazy'
---@type LazySpec
return {

	{
		"theprimeagen/harpoon", -- https://github.com/theprimeagen/harpoon
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon").setup()
		end,
	},

	{ -- Overrides default nvchad config:
		"nvim-telescope/telescope.nvim", -- https://github.com/nvim-telescope/telescope.nvim
		opts = function(_, conf)
			conf.defaults.layout_config = {
				horizontal = {
					prompt_position = "top",
					preview_width = 0.55,
				},
				width = 0.9,
				height = 0.90,
			}

			conf.defaults.mappings.i = {
				["<C-q>"] = require("telescope.actions").smart_send_to_qflist,
				["<C-Tab>"] = require("telescope.actions").toggle_all,
				["jj"] = function(prompt_bufnr)
					require("telescope.actions").move_selection_next(prompt_bufnr)
					vim.cmd "stopinsert"
				end,
			}
			conf.defaults.mappings.n = {
				["<C-q>"] = require("telescope.actions").smart_send_to_qflist,
				["<C-Tab>"] = require("telescope.actions").toggle_all,
				["q"] = require("telescope.actions").close,
				["<A-k>"] = {
					require("telescope.actions").move_selection_previous,
					type = "action",
					opts = { nowait = true, silent = true },
				},
				["<A-j>"] = {
					require("telescope.actions").move_selection_next,
					type = "action",
					opts = { nowait = true, silent = true },
				},
			}
			-- or
			-- table.insert(conf.defaults.mappings.i, your table)
			return conf
		end,

		-- Useful default bindings:
		-- ["<C-x>"] = actions.select_horizontal,
		-- ["<C-v>"] = actions.select_vertical,
		-- ["<C-r><C-w>"] = actions.insert_original_cword,
		-- ["<C-r><C-a>"] = actions.insert_original_cWORD,
		-- ["<C-r><C-f>"] = actions.insert_original_cfile,
		-- ["<C-r><C-l>"] = actions.insert_original_cline,
		-- C-l -- autocomplete in LSP diagnostics menu, C-n/C-p to switch suggestion
	},

	{
		"rolv-apneseth/tfm.nvim", -- https://github.com/rolv-apneseth/tfm.nvim
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
