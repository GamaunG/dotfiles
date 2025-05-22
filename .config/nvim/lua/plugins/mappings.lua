---@module 'lazy'
---@type LazySpec
return {

	{
		"Wansmer/langmapper.nvim", -- https://github.com/Wansmer/langmapper.nvim
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

	-- { -- breaks "<leader>/" mapping
	-- 	"folke/which-key.nvim", -- https://github.com/folke/which-key.nvim
	-- 	event = "VeryLazy",
	-- 	-- https://github.com/Wansmer/langmapper.nvim/discussions/11#discussioncomment-11279662
	-- 	config = function(_, opts)
	-- 		local lmu = require "langmapper.utils"
	-- 		local wk_state = require "which-key.state"
	-- 		local check_orig = wk_state.check
	-- 		wk_state.check = function(state, key)
	-- 			if key ~= nil then
	-- 				key = lmu.translate_keycode(key, "default", "ru")
	-- 			end
	-- 			return check_orig(state, key)
	-- 		end
	-- 		require("which-key").setup(opts)
	-- 	end,
	-- },

}
