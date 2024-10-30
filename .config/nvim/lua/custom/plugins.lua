local overrides = require("custom.configs.overrides")

-- require("dap").listeners.before.attach.dapui_config = function()
--   require("dapui").open()
-- end
-- require("dap").listeners.before.launch.dapui_config = function()
--   require("dapui").open()
-- end
-- require("dap").listeners.before.event_terminated.dapui_config = function()
--   require("dapui").close()
-- end
-- require("dap").listeners.before.event_exited.dapui_config = function()
--   require("dapui").close()
-- end

---@type NvPluginSpec[]
local plugins = {

	-- Override plugin definition options

	{
		"neovim/nvim-lspconfig",
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end, -- Override to setup mason-lspconfig
	},

	-- override plugin configs
	{
		"williamboman/mason.nvim",
		opts = overrides.mason,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = overrides.treesitter,
	},

	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"leoluz/nvim-dap-go",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			require("custom.configs.dap")
			-- require("dap-go").setup()
			-- require("dapui").setup()
			--
			-- require("dap").listeners.before.attach.dapui_config = function()
			-- 	require("dapui").open()
			-- end
			-- require("dap").listeners.before.launch.dapui_config = function()
			-- 	require("dapui").open()
			-- end
			-- require("dap").listeners.before.event_terminated.dapui_config = function()
			-- 	require("dapui").close()
			-- end
			-- require("dap").listeners.before.event_exited.dapui_config = function()
			-- 	require("dapui").close()
			-- end
		end,
	},

	{
		"nvim-tree/nvim-tree.lua",
		opts = overrides.nvimtree,
		enabled = false,
	},

	-- Install a plugin
	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		config = function()
			require("better_escape").setup()
		end,
		enabled = false,
	},

	{
		"stevearc/conform.nvim",
		--  for users those who want auto-save conform + lazyloading!
		-- event = "BufWritePre"
		cmd = { "ConformInfo" },
		config = function()
			require("custom.configs.conform")
		end,
		-- enabled = false,
	},

	-- To make a plugin not be loaded
	-- {
	--   "NvChad/nvim-colorizer.lua",
	--   enabled = false
	-- },

	{
		"mbbill/undotree",
		cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeFocus" },
	},

	{
		"theprimeagen/harpoon",
		lazy = false,
	},

	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},

	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	},

	-- All NvChad plugins are lazy-loaded by default
	-- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
	-- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
	-- {
	--   "mg979/vim-visual-multi",
	--   lazy = false,
	-- }
}

return plugins
