-- Gearbox
-- Variable

gearbox = Gearbox:Create(property.getNumber("Max Gear"))
gearbox.min_rps = property.getNumber("Min RPS")
gearbox.shift_up_rps = property.getNumber("Shift-up RPS")
gearbox.shift_down_rps = property.getNumber("Shift-down RPS")
target_rate = Variable:Create()
input_rps = Variable:Create()

input_rps_channel = property.getNumber("Drivetrain RPS Channel (Number)")
target_rate_channel = property.getNumber("Target Rate Channel (Number)")
enabled_channel = property.getNumber("Enabled Channel (Bool)")
reverse_channel = property.getNumber("Reverse Channel (Bool)")
gear_channel = property.getNumber("Gear Channel (Number)")

function onTick()
	local enabled = input.getBool(enabled_channel)
	local reverse = input.getBool(reverse_channel)
	input_rps:set(input.getNumber(input_rps_channel))
	target_rate:set(input.getNumber(target_rate_channel))
	gearbox:tick()

	if enabled and reverse then
		output.setNumber(gear_channel, -1)
	elseif enabled then
		output.setNumber(gear_channel, gearbox:process(input_rps, target_rate))
	else
		output.setNumber(gear_channel, 0)
	end
end
