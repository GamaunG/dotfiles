-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "gruvbox",
	integrations = { "render-markdown" },
	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

M.colorify = {
	enabled = true,
	-- mode = "virtual", -- fg, bg, virtual
	mode = "bg", -- fg, bg, virtual
	virt_text = "󱓻 ",
	highlight = { hex = true, lspvars = true },
}

M.ui = {
	statusline = {
		theme = "default",
		separator_style = "default",
		order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cwd", "cursor" },
		modules = {
			cursor = "%#St_pos_sep#" .. "" .. "%#St_pos_icon# %#St_pos_text# %p%% %c",
			-- modflag = " %M",
		},
	},
}

return M
