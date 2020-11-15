-- PID
-- Variable
-- Logger

logger = Logger:Create()
should_log = property.getBool("Log Engine RPS")

pid = PID:Create{
	kP = property.getNumber("Throttle PID (P)"),
	kI = property.getNumber("Throttle PID (I)"),
	kD = property.getNumber("Throttle PID (D)")
}

min_rps = property.getNumber("Min Engine RPS")
max_rps = property.getNumber("Max Engine RPS")
max_reverse_rps = property.getNumber("Max Reverse Engine RPS")
current_max_rps = max_rps
max_engine_temp = property.getNumber("Max Engine Temp")

thermal_protect = false

channel = {
	engine_rps = 1,
	target_rate = 2,
	engine_temp = 3,
	throttle = 1,
	--
	enabled = 1,
	reverse = 2,
	thermal_protect = 4,
	thermal_reset = 1,
}

function onTick()
	for i=1,32 do output.setNumber(i,input.getNumber(i)); output.setBool(i,input.getBool(i)) end
	logger:tick()

	local engine_rps = input.getNumber(channel.engine_rps)
	local target_rate = input.getNumber(channel.target_rate)

	local target_rps = min_rps + (max_rps - min_rps) * target_rate
	local throttle = 0
	if input.getBool(channel.enabled) then
		throttle = pid:process(target_rps, engine_rps)
		if should_log then logger:log(engine_rps) end
	else
		logger:reset()
	end

	if thermal_protect or input.getNumber(channel.engine_temp) > max_engine_temp then
		throttle = 0
		thermal_protect = true
	end
	if input.getBool(channel.thermal_reset) then
		thermal_protect = false
	end
	if input.getBool(channel.reverse) then
		current_max_rps = max_reverse_rps
	else
		current_max_rps = max_rps
	end
	output.setNumber(channel.throttle, throttle)
	output.setBool(channel.thermal_protect, thermal_protect)
end
