---@type MappingsTable
local M = {}

M.general = {
	n = {
		-- [";"] = { ":", "enter command mode", opts = { nowait = true } },
		["<F6>"] = { "<cmd> set spell! <CR>", "Toggle spellcheck", opts = { nowait = true } },
		["<F5>"] = { ':exec &nu==&rnu? "se nu!" : "se rnu!"<CR>', "Toggle nu and rnu" },
		["<leader>s"] = { [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Replace", opts = { nowait = true } },

		["<M-j>"] = { "<cmd>cnext<CR>", "cnext" },
		["<M-k>"] = { "<cmd>cprev<CR>", "cprev" },
		["<leader>j"] = { "<cmd>lnext<CR>", "lnext" },
		["<leader>k"] = { "<cmd>lprev<CR>", "lprev" },

		["<leader>u"] = { "<cmd>UndotreeToggle<CR><cmd>UndotreeFocus<CR>", "UndotreeToggle" },

		["<leader>rn"] = {
			function()
				require("nvchad.renamer").open()
			end,
			"LSP rename",
		},

		-- Remaping some defaults and adding new telescope binds
		["gr"] = {
			function()
				require("telescope.builtin").lsp_references()
			end,
			"LSP references",
		},

		["<leader>ds"] = {
			function()
				require("telescope.builtin").lsp_document_symbols()
			end,
			"Document Symbols",
		},

		["<leader>ws"] = {
			function()
				require("telescope.builtin").lsp_dynamic_workspace_symbols()
			end,
			"Workspace Symbols",
		},

		["<leader>q"] = {
			function()
				require("telescope.builtin").diagnostics()
			end,
			"Diagnostic",
		},

		["<leader>Q"] = {
			function()
				require("telescope.builtin").quickfix()
			end,
			"Quickfix list",
		},

		-- Harpoon bindings
		["<leader>h"] = {"",""},

		["<leader>hm"] = {
			function()
				require("harpoon.ui").toggle_quick_menu()
			end,
			"Harpoon Menu",
		},

		["<leader>ha"] = {
			function()
				require("harpoon.mark").add_file()
			end,
			"Harpoon Add file",
		},

		["<M-p>"] = {
			function()
				require("harpoon.ui").nav_prev()
			end,
			"Harpoon Prev file",
		},

		["<M-n>"] = {
			function()
				require("harpoon.ui").nav_next()
			end,
			"Harpoon Next file",
		},

		--  format with conform
		["<leader>fm"] = {
			function()
				require("conform").format()
			end,
			"formatting",
		},
	},
	i = {
		["<F5>"] = { '<C-o>:exec &nu==&rnu? "se nu!" : "se rnu!"<CR>', "Toggle nu and rnu" },
		["<F6>"] = { "<cmd> set spell! <CR>", "Toggle spellcheck", opts = { nowait = true } },
	},
	v = {
		[">"] = { ">gv", "indent" },
	},
}

-- more keybinds!

return M
