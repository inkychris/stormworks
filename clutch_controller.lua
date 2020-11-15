-- PID
-- clamp

min_rps = property.getNumber("Min RPS")
clutch_range = property.getNumber("Clutch Range (RPS)")

clutch_pid = PID:Create{
	kP = property.getNumber("Clutch PID (P)"),
	kI = property.getNumber("Clutch PID (I)"),
	kD = property.getNumber("Clutch PID (D)")
}

Channel = {
	In = {
		Bool = {Enabled = 1, Reverse = 2},
		Num = {InputRPS = 1, OutputRPS = 2, TargetRate = 3}
	},
	Out = {
		Num = {Clutch = 1},
	}
}

function reset()
	clutch_pid:reset()
	output.setNumber(Channel.Out.Num.Clutch, 0)
end

reverse_previous = false
changing_direction = false
function onTick()
	local enabled = input.getBool(Channel.In.Bool.Enabled)
	local reverse = input.getBool(Channel.In.Bool.Reverse)
	local input_rps = input.getNumber(Channel.In.Num.InputRPS)
	local output_rps = input.getNumber(Channel.In.Num.OutputRPS)
	local target_rate = input.getNumber(Channel.In.Num.TargetRate)

	if reverse ~= reverse_previous then changing_direction = true end
	changing_direction = changing_direction and (output_rps ~= 0)
	if changing_direction then
		reset()
		return
	end

	if target_rate > 0 and enabled then
		local offset = min_rps * (clutch_range - clamp(input_rps - min_rps, 0, clutch_range)) / clutch_range
		output.setNumber(Channel.Out.Num.Clutch, clutch_pid:process(input_rps, output_rps + offset))
	else reset() end
	reverse_previous = reverse
end
