-- Rewind video when unpaused if it was paused for >10sec AND wasn't seeked/frame-stepped
local rewind_seconds = 5
local pause_threshold = 10

local pause_start_time = nil
local pause_start_pos = nil
local user_seeked = false

mp.observe_property("pause", "bool", function(_, paused)
	if paused then
		pause_start_time = os.time()
		pause_start_pos = mp.get_property_number("time-pos", nil)
		user_seeked = false
	elseif pause_start_time ~= nil then
		local pause_duration = os.time() - pause_start_time

		if pause_duration >= pause_threshold and not user_seeked then
			local current_pos = mp.get_property_number("time-pos", 0)
			mp.set_property_number("time-pos", math.max(0, current_pos - rewind_seconds))
		end

		pause_start_time = nil
		pause_start_pos = nil
		user_seeked = false
	end
end)

mp.observe_property("time-pos", "number", function(_, pos)
	if pause_start_pos ~= nil and pos ~= nil then
		if math.abs(pos - pause_start_pos) >= 0.001 then
			user_seeked = true
		end
	end
end)
