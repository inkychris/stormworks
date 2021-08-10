dofile "util/pid.lua"

pid = PID:Create{
	kP = property.getNumber("Throttle PID (P)"),
	kI = property.getNumber("Throttle PID (I)")
}

target_rps = property.getNumber("Target Engine RPS")
ignition_rps = property.getNumber("Ignition RPS")

Channel = {
	In = {
		Num = {EngineRPS = 1},
		Bool = {Enabled = 1}
	},
	Out = {
		Num = {Throttle = 1},
		Bool = {Starter = 1}
	}	
}

function onTick()
	local engine_rps = input.getNumber(Channel.In.Num.EngineRPS)
	local enabled = input.getBool(Channel.In.Bool.Enabled)

	local throttle = 0
	if enabled then
		throttle = pid:process(target_rps, engine_rps)
	end

	output.setBool(Channel.Out.Bool.Starter, enabled and engine_rps < ignition_rps)
	output.setNumber(Channel.Out.Num.Throttle, throttle)
end
