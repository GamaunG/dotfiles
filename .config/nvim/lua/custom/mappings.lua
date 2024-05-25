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
		["<leader>n"] = { "<cmd>bn<CR>", "Next buffer" },
		["<leader>p"] = { "<cmd>bp<CR>", "Prev buffer" },

		["<leader>u"] = { "<cmd>UndotreeToggle<CR><cmd>UndotreeFocus<CR>", "Toggle Undotree" },

		-- Harpoon bindings
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
			"Format",
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
