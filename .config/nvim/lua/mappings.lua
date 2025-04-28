-- require "nvchad.mappings"
local map = vim.keymap.set
-- local nomap = vim.keymap.del
-- unmap defaults ($XDG_DATA_HOME/nvim/lazy/NvChad/lua/nvchad/mappings.lua):
-- nomap("n", "<C-n>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- General
map("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "Toggle nvcheatsheet" })
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear highlights" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "Copy whole file to system clipboard" })
map("v", "<C-c>", '"+y', { desc = "Copy selection to system clipboard" })
map({ "n", "v", "x" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
map({ "n", "v", "x" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })


map("i", "<C-h>", "<Left>", { desc = "Move left" })
map("i", "<C-l>", "<Right>", { desc = "Move right" })
map("i", "<C-j>", "<Down>", { desc = "Move down" })
map("i", "<C-k>", "<Up>", { desc = "Move up" })

map("n", "<C-h>", "<C-w>h", { desc = "Switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "Switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Switch window up" })
map("n", "<C-S-h>", "2<C-w><", { desc = "Decrease width" })
map("n", "<C-S-l>", "2<C-w>>", { desc = "Increase width" })
map("n", "<C-S-j>", "<C-w>+", { desc = "Increase height" })
map("n", "<C-S-k>", "<C-w>-", { desc = "Decrease height" })

map("n", "<leader>rs", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace" })

map("n", "<leader>sc", "<cmd>set spell!<CR>", { desc = "Toggle spellcheck" })
map("n", "<leader>tw", "<cmd>set wrap!<CR>", { desc = "Toggle line wrapping" })
map("n", "<F5>", ':exec &nu==&rnu? "se nu!" : "se rnu!"<CR>', { desc = "Toggle nu and rnu" })
map("n", "<leader>tn", ':exec &nu==&rnu? "se nu!" : "se rnu!"<CR>', { desc = "Toggle nu and rnu" })

map("n", "<A-j>", "<cmd>cnext<CR>", { desc = "cnext" })
map("n", "<A-k>", "<cmd>cprev<CR>", { desc = "cprev" })
map("n", "<C-1>", "<cmd>b 1<CR>",  { desc = "Buffer 1" })
map("n", "<C-2>", "<cmd>b 2<CR>",  { desc = "Buffer 2" })
map("n", "<C-3>", "<cmd>b 3<CR>",  { desc = "Buffer 3" })
map("n", "<C-4>", "<cmd>b 4<CR>",  { desc = "Buffer 4" })
map("n", "<C-5>", "<cmd>b 5<CR>",  { desc = "Buffer 5" })
map("n", "<C-6>", "<cmd>b 6<CR>",  { desc = "Buffer 6" })
map("n", "<C-7>", "<cmd>b 7<CR>",  { desc = "Buffer 7" })
map("n", "<C-8>", "<cmd>b 8<CR>",  { desc = "Buffer 8" })
map("n", "<C-9>", "<cmd>b 9<CR>",  { desc = "Buffer 9" })
map("n", "<C-0>", "<cmd>b 10<CR>", { desc = "Buffer 10" })


-- TFM
map("n", "<leader>o", function() require("tfm").open() end, { desc = "LF" })

-- Harpoon
local harpoon = require("harpoon")
map("n", "<leader>hm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon Menu" })
map("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon Add file" })
map("n", "<A-p>", function() harpoon:list():prev({ui_nav_wrap = true}) end, { desc = "Harpoon Prev file" })
map("n", "<A-n>", function() harpoon:list():next({ui_nav_wrap = true}) end, { desc = "Harpoon Next file" })
map("n", "<A-1>", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
map("n", "<A-2>", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
map("n", "<A-3>", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
map("n", "<A-4>", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
map("n", "<A-5>", function() harpoon:list():select(5) end, { desc = "Harpoon file 5" })
map("n", "<A-6>", function() harpoon:list():select(6) end, { desc = "Harpoon file 6" })
map("n", "<A-7>", function() harpoon:list():select(7) end, { desc = "Harpoon file 7" })
map("n", "<A-8>", function() harpoon:list():select(8) end, { desc = "Harpoon file 8" })
map("n", "<A-9>", function() harpoon:list():select(9) end, { desc = "Harpoon file 9" })
map("n", "<A-0>", function() harpoon:list():select(10) end, { desc = "Harpoon file 10" })


-- Undotree
map("n", "<leader>u", "<cmd>UndotreeToggle<CR><cmd>UndotreeFocus<CR>", { desc = "Toggle Undotree" })


-- Conform
map("n", "<leader>fm", function() require("conform").format { lsp_fallback = true } end, { desc = "Format" })
map("v", "<leader>fm", function() require("conform").format { lsp_fallback = true } end, { desc = "Format selection" })


-- Telescope
local telescope = require("telescope.builtin")
map("n", "<leader>fw", function() telescope.live_grep() end, { desc = "Telescope live grep" })
map("n", "<leader>fb", function() telescope.buffers() end, { desc = "Telescope find buffers" })
map("n", "<leader>fh", function() telescope.help_tags() end, { desc = "Telescope help page" })
map("n", "<leader>fo", function() telescope.oldfiles() end, { desc = "Telescope find oldfiles" })
map("n", "<leader>ff", function() telescope.find_files()  end, { desc = "Telescope find files" })
map("n", "<leader>fa", function() telescope.find_files { follow = true, no_ignore = true, hidden = true } end, { desc = "Telescope find all files" })
map("n", "<leader>ma", function() telescope.marks() end, { desc = "Telescope find marks" })
map("n", "<leader>tt", "<cmd>Telescope terms<CR>", { desc = "Telescope pick hidden term" })
map("n", "<leader>fz", function() telescope.current_buffer_fuzzy_find() end, { desc = "Telescope find in current buffer" })
map("n", "<leader>ds", function() telescope.lsp_document_symbols() end, { desc = "LSP Document Symbols" })
map("n", "<leader>ws", function() telescope.lsp_dynamic_workspace_symbols() end, { desc = "LSP Workspace Symbols" })
map("n", "<leader>ld", function() telescope.diagnostics() end, { desc = "LSP Diagnostic" })
map("n", "<leader>Q",  function() telescope.quickfixhistory() end, { desc = "Quickfix list history" })
map("n", "<leader>q",  function() telescope.quickfix() end, { desc = "Quickfix list" })
map("n", "<leader>gc", function() telescope.git_commits() end, { desc = "Git commits" })
map("n", "<leader>gC", function() telescope.git_bcommits() end, { desc = "Git commits in buf" })
map("n", "<leader>gs", function() telescope.git_status() end, { desc = "Git status" })
map("n", "<leader>gb", function() telescope.git_branches() end, { desc = "Git branches" })
map("n", "<A-r>", function() telescope.resume() end, { desc = "Telescope resume" })
map("n", "<leader>th", function() require("nvchad.themes").open() end, { desc = "Telescope nvchad themes" })
-- more in ./configs/lspconfig.lua

-- Gitsigns
map("n", "]c", function() if vim.wo.diff then return "]c" end vim.schedule(function() require("gitsigns").next_hunk() end) return "<Ignore>" end, { desc = "Next hunk", expr = true })
map("n", "[c", function() if vim.wo.diff then return "[c" end vim.schedule(function() require("gitsigns").prev_hunk() end) return "<Ignore>" end, { desc = "Prev hunk", expr = true })
map("n", "<leader>hr", function() require("gitsigns").reset_hunk() end, { desc = "Reset hunk" })
map("n", "<leader>hp", function() require("gitsigns").preview_hunk() end, { desc = "Preview hunk" })
map("n", "<leader>hR", function() require("gitsigns").reset_buffer() end, { desc = "Reset hunks in current buffer" })
map("n", "<leader>hb", function() require("gitsigns").blame_line{full=true} end, { desc = "Blame line verbose" })
map("n", "<leader>tb", function() require("gitsigns").toggle_current_line_blame() end, { desc = "Toggle Blame on line" })
map("n", "<leader>hB", function() package.loaded.gitsigns.blame_line() end, { desc = "Blame line" })
map("n", "<leader>td", function() require("gitsigns").toggle_deleted() end, { desc = "Toggle deleted" })


-- Tabufline
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })
map("n", "<tab>", function() require("nvchad.tabufline").next() end, { desc = "Buffer goto next" })
map("n", "<S-tab>", function() require("nvchad.tabufline").prev() end, { desc = "Buffer goto prev" })
map("n", "<leader>x", function() require("nvchad.tabufline").close_buffer() end, { desc = "Buffer close" })


-- Comment
map("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "Toggle comment", remap = true })


-- Terminal
map("t", "<C-x>", "<C-\\><C-N>", { desc = "Terminal escape terminal mode" })
map({ "n", "t" }, "<A-h>", function() require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" } end, { desc = "Terminal toggle horizontal" })
map({ "n", "t" }, "<A-i>", function() require("nvchad.term").toggle { pos = "float", id = "floatTerm" } end, { desc = "Terminal toggle floating" })


-- Debugger
map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "DAP toggle breakpoint" })
map("n", "<leader>dl", function() require("dap").run_last() end, { desc = "DAP run last" })
map("n", "<leader>dH", function() require("dap.ui.widgets").hover() end, { desc = "DAP hover" })
map("n", "<leader>dut", function() require("dapui").toggle() end, { desc = "DAPUI toggle" })
map("n", "<leader>dh", function() require("dapui").eval() end, { desc = "DAPUI hover" })
map("n", "<leader>dc", function() require("dap").continue() end, { desc = "Debug continue" })
map("n", "<F7>", function() require("dap").continue() end, { desc = "DAP continue" })
map("n", "<F9>", function() require("dap").toggle_breakpoint() end, { desc = "DAP toggle breakpoint" })
map("n", "<F10>", function() require("dap").step_over() end, { desc = "DAP Step over" })
map("n", "<F11>", function() require("dap").step_into() end, { desc = "DAP Step into" })
map("n", "<F23>", function() require("dap").step_into() end, { desc = "DAP Step into" })
map("n", "<F12>", function() require("dap").step_out() end, { desc = "DAP Step out" })


-- Minty
map("n", "<leader>cp", "<cmd>Huefy <CR>", { desc = "Minty color picker" })
map("n", "<leader>cs", "<cmd>Shades <CR>", { desc = "Minty color shades" })


-- WhichKey
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "Whichkey all keymaps" })
map("n", "<leader>wk", function() vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ") end, { desc = "Whichkey query lookup" })


-- IBL
map({"n", "v" }, "<space>cc", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local config = require("ibl.config").get_config(bufnr)
	local scope = require("ibl.scope").get(bufnr, config)
	if scope then
		local row, column = scope:start()
		vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { row + 1, column })
	end
end, { desc = "Jump to current context" })
