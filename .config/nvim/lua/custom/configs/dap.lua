require("dap-go").setup()
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
