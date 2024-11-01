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
		["<C-1>"] = { "<cmd>b 1<CR>", "Buffer 1" },
		["<C-2>"] = { "<cmd>b 2<CR>", "Buffer 2" },
		["<C-3>"] = { "<cmd>b 3<CR>", "Buffer 3" },
		["<C-4>"] = { "<cmd>b 4<CR>", "Buffer 4" },
		["<C-5>"] = { "<cmd>b 5<CR>", "Buffer 5" },
		["<C-6>"] = { "<cmd>b 6<CR>", "Buffer 6" },
		["<C-7>"] = { "<cmd>b 7<CR>", "Buffer 7" },
		["<C-8>"] = { "<cmd>b 8<CR>", "Buffer 8" },
		["<C-9>"] = { "<cmd>b 9<CR>", "Buffer 9" },
		["<C-0>"] = { "<cmd>b 10<CR>", "Buffer 10" },

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

		-- Debugger
		["<leader>db"] = {
			function()
				require("dap").toggle_breakpoint()
			end,
			"DAP toggle breakpoint",
		},

		["<leader>dB"] = {
			function()
				require("dap").set_breakpoint()
			end,
			"DAP set breakpoint",
		},

		["<leader>dl"] = {
			function()
				require("dap").run_last()
			end,
			"DAP run last",
		},

		["<leader>dh"] = {
			function()
				require('dap.ui.widgets').hover()
			end,
			"DAP hover",
		},

		["<leader>de"] = {
			function()
				require("dapui").eval()
			end,
			"DAP evaluate expression",
		},

		["<leader>dc"] = {
			function()
				require("dap").continue()
			end,
			"Debug continue",
		},

		["<F7>"] = {
			function()
				require("dap").continue()
			end,
			"DAP continue",
		},

		["<F10>"] = {
			function()
				require("dap").step_over()
			end,
			"Step over",
		},

		["<F11>"] = {
			function()
				require("dap").step_into()
			end,
			"Step into",
		},

		["<F12>"] = {
			function()
				require("dap").step_out()
			end,
			"Step out",
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
