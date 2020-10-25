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
max_engine_temp = property.getNumber("Max Engine Temp")

idler_enabled = false
limiter_enabled = false
limiter_enable_target_rate = 0
limiter_antirepeat = nil

function onTick()
	engine_rps:set(input.getNumber(1))
	target_rate:set(input.getNumber(2))
	local ecu_enabled = input.getBool(1)
	local engine_temp = input.getNumber(3)

	local throttle = target_rate.current

	if limiter_antirepeat then
		limiter_antirepeat = limiter_antirepeat + 1
		if limiter_antirepeat > 20 then
			limiter_antirepeat = nil
		end
	end

	if not ecu_enabled then
		idler_enabled = false
		limiter_enabled = false
		throttle = 0
	end

	if ecu_enabled then
		if engine_rps.current < min_rps then
			idler_enabled = true
		elseif not limiter_antirepeat and (engine_rps.current > max_rps) then
			limiter_enabled = true
			limiter_antirepeat = 0
			limiter_enable_target_rate = target_rate.current
		end
	end

	if idler_enabled then
		throttle = idler_pid:process(min_rps, engine_rps.current)
		if target_rate.current > throttle then
			idler_enabled = false
		end
	end

	if limiter_enabled then
		throttle = limiter_pid:process(max_rps, engine_rps.current)
		if target_rate.current < limiter_enable_target_rate then
			limiter_enabled = false
		end
	end

	if engine_temp > max_engine_temp then
		throttle = 0
	end

	output.setNumber(1, throttle)
end
