dofile "util/pid.lua"

pid = PID:Create{
	kP = property.getNumber("Throttle PID (P)"),
	kI = property.getNumber("Throttle PID (I)"),
	kD = property.getNumber("Throttle PID (D)")
}

min_rps = property.getNumber("Min Engine RPS")
max_rps = property.getNumber("Max Engine RPS")
ignition_rps = property.getNumber("Ignition RPS")
max_reverse_rps = property.getNumber("Max Reverse Engine RPS")
current_max_rps = max_rps
max_engine_temp = property.getNumber("Max Engine Temp")

thermal_protect = false

Channel = {
	In = {
		Num = {
			EngineRPS = 1,
			TargetRate = 2,
			EngineTemp = 3
		},
		Bool = {
			Enabled = 1,
			Reverse = 2,
			ThermalReset = 3,
			CutThrottle = 4,
		}
	},
	Out = {
		Num = {Throttle = 1},
		Bool = {
			Starter = 1,
			ThermalProtect = 2
		}
	}	
}

function onTick()
	local engine_rps = input.getNumber(Channel.In.Num.EngineRPS)
	local target_rate = input.getNumber(Channel.In.Num.TargetRate)
	local enabled = input.getBool(Channel.In.Bool.Enabled)

	if input.getBool(Channel.In.Bool.Reverse) then
		current_max_rps = max_reverse_rps
	else
		current_max_rps = max_rps
	end
	
	if input.getBool(Channel.In.Bool.ThermalReset) then
		thermal_protect = false
	end

	local target_rps = 0
	if thermal_protect or input.getNumber(Channel.In.Num.EngineTemp) > max_engine_temp then
		thermal_protect = true
	elseif input.getBool(Channel.In.Bool.CutThrottle) then
		target_rps = min_rps
	else
		target_rps = min_rps + (current_max_rps - min_rps) * target_rate
	end

	local throttle = 0
	if enabled then
		throttle = pid:process(target_rps, engine_rps)
	end

	output.setBool(Channel.Out.Bool.Starter, not thermal_protect and enabled and engine_rps < ignition_rps)
	output.setNumber(Channel.Out.Num.Throttle, throttle)
	output.setBool(Channel.Out.Bool.ThermalProtect, thermal_protect)
end
