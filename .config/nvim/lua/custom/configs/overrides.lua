local M = {}

M.treesitter = {
	ensure_installed = {
		"vim",
		"lua",
		-- "html",
		"css",
		-- "javascript",
		-- "typescript",
		-- "tsx",
		"c",
		"markdown",
		"markdown_inline",
		"go",
		"printf",
	},
	highlight = {
		enable = true,
		disable = { "bash" },
	},
	indent = {
		enable = true,
		-- disable = {
		--   "python"
		-- },
	},
}

M.mason = {
	ensure_installed = {
		"lua-language-server",

		"prettierd",

		"gopls",
		-- c/cpp stuff
		"clangd",
		"clang-format",
	},
}

-- git support in nvimtree
--[[ M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
} ]]
return M
