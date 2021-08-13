dofile "util/clamp.lua"
dofile "util/pulse/src.lua"

Channel = {
	In = {
		Num = {Length = 8},
		Bool = {
			Up = 1,
			Down = 2,
			Retract = 3,
			Extend = 4,
		}
	},
	Out = {
		Num = {
			CurrentLength = 1,
			TargetLength = 2,
		},
		Bool = {
			WinchUp = 1,
			WinchDown = 2,
		},
	}
}

min_length = property.getNumber("Min Length")
max_length = property.getNumber("Max Length")
starting_state = property.getNumber("Starting State")

extend = Pulse()
retract = Pulse()

extend_momentary = false
retract_momentary = false

extend_latch = starting_state == 2
retract_latch = starting_state == 1

loop_index = 0
function onTick()
	extend_momentary = false
	retract_momentary = false
	local current_length = input.getNumber(Channel.In.Num.Length)

	local up = input.getBool(Channel.In.Bool.Up)
	local down = input.getBool(Channel.In.Bool.Down)
	extend:update(input.getBool(Channel.In.Bool.Extend))
	retract:update(input.getBool(Channel.In.Bool.Retract))

	if loop_index > 10 then -- current_length not set on initial ticks
		if extend_latch and (max_length - current_length) <= 0 then
			extend_latch = false
		end

		if retract_latch and (current_length - min_length) <= 0 then
			retract_latch = false
		end
	end

	if up and not down then
		extend_momentary = false
		retract_momentary = true
		extend_latch = false
		retract_latch = false
	elseif down and not up then
		extend_momentary = true
		retract_momentary = false
		extend_latch = false
		retract_latch = false
	end

	if extend:off_on() then
		extend_momentary = false
		retract_momentary = false
		extend_latch = not extend_latch
		retract_latch = false
	elseif retract:off_on() then
		extend_momentary = false
		retract_momentary = false
		extend_latch = false
		retract_latch = not retract_latch
	end

	output.setBool(Channel.Out.Bool.WinchDown, extend_latch or extend_momentary)
	output.setBool(Channel.Out.Bool.WinchUp, retract_latch or retract_momentary)
	loop_index = loop_index + 1
end
