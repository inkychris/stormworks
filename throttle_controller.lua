-- PID
-- Variable

idler_pid = PID:Create()
idler_pid.kP = property.getNumber("Idler PID (P)")
idler_pid.kI = property.getNumber("Idler PID (I)")
idler_pid.kD = property.getNumber("Idler PID (D)")

limiter_pid = PID:Create()
limiter_pid.kP = property.getNumber("Limiter PID (P)")
limiter_pid.kI = property.getNumber("Limiter PID (I)")
limiter_pid.kD = property.getNumber("Limiter PID (D)")
limiter_pid.clamp_integral = true

target_rate = Variable:Create()
engine_rps = Variable:Create()
min_rps = property.getNumber("Min Engine RPS")
max_rps = property.getNumber("Max Engine RPS")
max_reverse_rps = property.getNumber("Max Reverse Engine RPS")
current_max_rps = max_rps
max_engine_temp = property.getNumber("Max Engine Temp")

idler_enabled = false
limiter_enabled = false
limiter_enable_target_rate = 0
limiter_antirepeat = nil
thermal_protect = false

engine_rps_channel = property.getNumber("Engine RPS Channel (Number)")
target_rate_channel = property.getNumber("Target Rate Channel (Number)")
throttle_channel = property.getNumber("Throttle Channel (Number)")
engine_temp_channel = property.getNumber("Engine Temp Channel (Number)")

enabled_channel = property.getNumber("Enabled Channel (Bool)")
reverse_channel = property.getNumber("Reverse Channel (Bool)")
therm_reset_channel = property.getNumber("Thermal Reset Channel (Bool)")
therm_protect_channel = property.getNumber("Thermal Protect Enabled Channel (Bool)")

function onTick()
	engine_rps:set(input.getNumber(engine_rps_channel))
	target_rate:set(input.getNumber(target_rate_channel))

	local throttle = target_rate.current
	if limiter_antirepeat then
		limiter_antirepeat = limiter_antirepeat + 1
		if limiter_antirepeat > 20 then
			limiter_antirepeat = nil
		end
	end
	if input.getBool(enabled_channel) then
		if engine_rps.current < min_rps then
			idler_enabled = true
		elseif not limiter_antirepeat and (engine_rps.current > current_max_rps) then
			limiter_enabled = true
			limiter_antirepeat = 0
			limiter_enable_target_rate = target_rate.current
		end
	else
		idler_enabled = false
		limiter_enabled = false
		throttle = 0
	end
	if idler_enabled then
		throttle = idler_pid:process(min_rps, engine_rps.current)
		if target_rate.current > throttle then
			idler_enabled = false
		end
	end
	if limiter_enabled then
		throttle = limiter_pid:process(current_max_rps, engine_rps.current)
		if target_rate.current < limiter_enable_target_rate then
			limiter_enabled = false
		end
	end
	if thermal_protect or input.getNumber(engine_temp_channel) > max_engine_temp then
		throttle = 0
		thermal_protect = true
	end
	if input.getBool(therm_reset_channel) then
		thermal_protect = false
	end
	if input.getBool(reverse_channel) then
		current_max_rps = max_reverse_rps
	else
		current_max_rps = max_rps
	end
	output.setNumber(throttle_channel, throttle)
	output.setBool(therm_protect_channel, thermal_protect)
end
