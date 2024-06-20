local options = {
	lsp_fallback = true,

	formatters_by_ft = {
		lua = { "stylua" },

		javascript = { { "prettierd", "prettier" } },
		typescript = { { "prettierd", "prettier" } },
		jsx = { { "prettierd", "prettier" } },
		css = { { "prettierd", "prettier" } },
		scss = { { "prettierd", "prettier" } },
		md = { { "prettierd", "prettier" } },
		html = { { "prettierd", "prettier" } },
		json = { { "prettierd", "prettier" } },
		yaml = { { "prettierd", "prettier" } },

		go = { "gofumpt" },

		c = { "clang-format" },
		cs = { "clang-format" },
		cpp = { "clang-format" },
		java = { "clang-format" },

		sh = { "shfmt" },
	},

	formatters = {
		["clang-format"] = {
			command = "clang-format",
			args = {
				"--assume-filename",
				"$FILENAME",
				"--style",
				"{TabWidth: 4, IndentWidth: 4, UseTab: Always, ColumnLimit: 0}",
			},
		},
	},

	-- adding same formatter for multiple filetypes can look too much work for some
	-- instead of the above code you could just use a loop! the config is just a table after all!

	-- format_on_save = {
	--   -- These options will be passed to conform.format()
	--   timeout_ms = 500,
	--   lsp_fallback = true,
	-- },
}

require("conform").setup(options)
