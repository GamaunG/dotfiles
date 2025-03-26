pcall(function()
	require("dap-go").setup()
end)
pcall(function()
	require("dap-python").setup "python"
end)
require("dapui").setup()

require("dap").listeners.before.attach.dapui_config = function()
	require("dapui").open()
end
require("dap").listeners.before.launch.dapui_config = function()
	require("dapui").open()
end
require("dap").listeners.before.event_terminated.dapui_config = function()
	require("dapui").close()
end
require("dap").listeners.before.event_exited.dapui_config = function()
	require("dapui").close()
end
