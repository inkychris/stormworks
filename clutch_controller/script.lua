clutch_rps = property.getNumber("Clutch RPS")
full_engage_ratio = property.getNumber("Clutch Engage Ratio")
clutch_slip = property.getNumber("Clutch Slip")

Channel = {
	In = {
		Bool = {Enabled = 1, Reverse = 2, CutThrottle = 4},
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
	local cut_throttle = input.getBool(Channel.In.Bool.CutThrottle)
	local output_rps = input.getNumber(Channel.In.Num.OutputRPS)
	local target_rate = input.getNumber(Channel.In.Num.TargetRate)

	local result = 0

	if reverse ~= reverse_previous then changing_direction = true end
	changing_direction = changing_direction and (output_rps ~= 0)
	if enabled and (not changing_direction) and (not cut_throttle) then
		if target_rate > 0 then
			if output_rps > clutch_rps * full_engage_ratio then
				result = 1
			else
				result = clutch_slip
			end
		end
	end
	output.setNumber(Channel.Out.Num.Clutch, result)
	reverse_previous = reverse
end
