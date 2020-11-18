clutch_rps = property.getNumber("Clutch RPS")

Channel = {
	In = {
		Bool = {Enabled = 1, Reverse = 2},
		Num = {OutputRPS = 4, TargetRate = 2}
	},
	Out = {
		Num = {Clutch = 1},
	}
}

reverse_previous = false
changing_direction = false
function onTick()
	local enabled = input.getBool(Channel.In.Bool.Enabled)
	local reverse = input.getBool(Channel.In.Bool.Reverse)
	local output_rps = input.getNumber(Channel.In.Num.OutputRPS)
	local target_rate = input.getNumber(Channel.In.Num.TargetRate)

	local result = 0

	if reverse ~= reverse_previous then changing_direction = true end
	changing_direction = changing_direction and (output_rps ~= 0)
	if enabled and (not changing_direction) then
		if target_rate > 0 then
			if output_rps > clutch_rps * 0.722 then
				result = 1
			else
				result = 0.57
			end
		end
	end
	output.setNumber(Channel.Out.Num.Clutch, result)
	reverse_previous = reverse
end
