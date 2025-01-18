-- Rewind video when unpaused if it's paused for >10sec
local rewind_seconds = 5
local pause_start_time = nil
local pause_threshold = 10

mp.observe_property("pause", "bool", function(_, paused)
	if paused then
		pause_start_time = os.time()
	elseif pause_start_time ~= nil then
		local pause_duration = os.time() - pause_start_time
		if pause_duration >= pause_threshold then
			local current_pos = mp.get_property_number("time-pos", 0)
			mp.set_property_number("time-pos", math.max(0, current_pos - rewind_seconds))
		end
		pause_start_time = nil
	end
end)
