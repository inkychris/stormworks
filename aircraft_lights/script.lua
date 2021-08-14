input_channels = {
	nav_active = 1,
	beacon_active = 2,
	strobe_active = 3,
}

output_channels = {
	beacon = 1,
	tail_strobe = 4,
	wing_strobe = 7,
	nav_left = 10,
	nav_right = 13,
	nav_rear = 16
}

TICK_INDEX = 0
function tick_range(lower, upper)
	return TICK_INDEX >= lower and TICK_INDEX < upper
end

OFF = {r=0,g=0,b=0}
WHITE = {r=1,g=1,b=1}
RED = {r=1,g=0,b=0}
GREEN = {r=0,g=1,b=0}

function onTick()
	local signals = {}
	for k,_ in pairs(output_channels) do
		signals[k] = OFF
	end

	if input.getBool(input_channels.nav_active) then
		signals.nav_left = RED
		signals.nav_right = GREEN
		signals.nav_rear = WHITE
	end
	
	if input.getBool(input_channels.strobe_active) and (tick_range(0, 3) or tick_range(6, 9)) then
		signals.wing_strobe = WHITE
	end

	if input.getBool(input_channels.strobe_active) and tick_range(0, 6) then
		signals.tail_strobe = WHITE
	end

	if input.getBool(input_channels.beacon_active) and tick_range(30, 36) then
		signals.beacon = RED
	end

	for k,vals in pairs(signals) do
		for i=1,3 do
			output.setNumber(output_channels[k], vals.r)
			output.setNumber(output_channels[k]+1, vals.g)
			output.setNumber(output_channels[k]+2, vals.b)
		end
	end

	TICK_INDEX = TICK_INDEX + 1
	if TICK_INDEX == 60 then TICK_INDEX = 0 end
end
