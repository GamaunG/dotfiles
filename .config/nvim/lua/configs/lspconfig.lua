-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()
local configs = require "nvchad.configs.lspconfig"

local servers = {
	html = {},
	cssls = {
		settings = {
			css = { validate = true, lint = {
				unknownAtRules = "ignore",
			} },
			scss = { validate = true, lint = {
				unknownAtRules = "ignore",
			} },
			less = { validate = true, lint = {
				unknownAtRules = "ignore",
			} },
		},
	},
	clangd = {},
	gopls = {},
	basedpyright = {
		setting = {
			python = {
				analysis = {
					autoSearchPaths = true,
					typeCheckingMode = "basic",
				},
			},
		},
	},
	lua_ls = { -- copied from $XDG_DATA_HOME/nvim/lazy/NvChad/lua/nvchad/configs/lspconfig.lua
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = {
						vim.fn.expand "$VIMRUNTIME/lua",
						vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
						vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
						vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
						"${3rd}/luv/library",
					},
					maxPreload = 100000,
					preloadFileSize = 10000,
				},
			},
		},
	},
}

-- local remaps = function(client, bufnr)
-- 	configs.on_attach(client, bufnr)
local on_attach = function(_, bufnr)
	local function opts(desc)
		return { buffer = bufnr, desc = "LSP " .. desc }
	end
	local map = vim.keymap.set
	map("n", "gr", function() require("telescope.builtin").lsp_references { include_current_line = true } end, opts "References")
	map("n", "gd", function() require("telescope.builtin").lsp_definitions {} end, opts "Go to definition")
	map("n", "gi", function() require("telescope.builtin").lsp_implementations {} end, opts "Go to implementation")
	map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
	map("n", "<leader>D", function() require("telescope.builtin").lsp_type_definitions {} end, opts "Go to type definition")
	map("n", "<leader>lf", vim.diagnostic.open_float, opts "Floating diagnostics")
	map("n", "<leader>ls", vim.lsp.buf.signature_help, opts "Show signature help")
	map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
	map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
	map("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts "List workspace folders")
	map("n", "<leader>rn", require "nvchad.lsp.renamer", opts "NvRenamer")
	map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts "Code action")
end

for name, opts in pairs(servers) do
	opts.on_init = configs.on_init
	opts.on_attach = on_attach
	opts.capabilities = configs.capabilities

	require("lspconfig")[name].setup(opts)
end
