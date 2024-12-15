---@module 'lazy'
---@type LazySpec
return {

	{
		"stevearc/conform.nvim",
		-- event = 'BufWritePre', -- uncomment for format on save
		opts = require "configs.conform",
	},

	{
		"Wansmer/langmapper.nvim",
		lazy = false,
		priority = 1, -- High priority is needed if you will use `autoremap()`
		config = function()
			require("langmapper").setup {
				custom_desc = function()
					return "which_key_ignore"
				end,
			}
		end,
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		-- https://github.com/Wansmer/langmapper.nvim/discussions/11#discussioncomment-11279662
		config = function(_, opts)
			local lmu = require "langmapper.utils"
			local wk_state = require "which-key.state"
			local check_orig = wk_state.check
			wk_state.check = function(state, key)
				if key ~= nil then
					key = lmu.translate_keycode(key, "default", "ru")
				end
				return check_orig(state, key)
			end
			require("which-key").setup(opts)
		end,
	},

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

	{
		"iamcco/markdown-preview.nvim",
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
