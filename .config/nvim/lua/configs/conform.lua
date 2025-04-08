local options = {
	lsp_fallback = true,
	formatters_by_ft = {
		lua = { "stylua" },

		python = { "black" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		jsx = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		scss = { "prettierd", "prettier", stop_after_first = true },
		md = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		htmldjango = { "djlint" },
		json = { "prettierd", "prettier", stop_after_first = true },
		yaml = { "prettierd", "prettier", stop_after_first = true },

		go = { "gofumpt" },

		c = { "clang-format" },
		cs = { "clang-format" },
		cpp = { "clang-format" },
		java = { "clang-format" },

		sh = { "shfmt" },

		tex = { "tex-fmt" },
	},

	formatters = {
		["clang-format"] = {
			command = "clang-format",
			args = {
				"--assume-filename",
				"$FILENAME",
				"--style",
				"{BasedOnStyle: Google, TabWidth: 4, IndentWidth: 4, UseTab: Always, ColumnLimit: 0}",
			},
		},
		["prettierd"] = {
			args = {
				"$FILENAME",
				"--use-tabs",
				"--tab-width 4",
			},
		},
		["shfmt"] = {
			args = {
				"--case-indent",
			},
		},
	},
	-- format_on_save = {
	--   -- These options will be passed to conform.format()
	--   timeout_ms = 500,
	--   lsp_fallback = true,
	-- },
}

return options
