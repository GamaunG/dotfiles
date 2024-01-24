---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<F6>"] = { "<cmd> set spell! <CR>", "Toggle spellcheck", opts = { nowait = true } },
    ["<F5>"] = { ':exec &nu==&rnu? "se nu!" : "se rnu!"<CR>', "Toggle nu and rnu" },

    --  format with conform
    ["<leader>fm"] = {
      function()
        require("conform").format()
      end,
      "formatting",
    }

  },
  i = {
    ["<F5>"] = { '<C-o>:exec &nu==&rnu? "se nu!" : "se rnu!"<CR>', "Toggle nu and rnu" },
    ["<F6>"] = { "<cmd> set spell! <CR>", "Toggle spellcheck", opts = { nowait = true } },
  },
  v = {
    [">"] = { ">gv", "indent"},
  },
}

-- more keybinds!

return M
