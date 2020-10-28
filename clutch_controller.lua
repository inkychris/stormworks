-- Variable
-- PID

clutch_rps = property.getNumber("Clutch RPS")

clutch_pid = PID:Create()
clutch_pid.clamp_output = true
clutch_pid.min = -1
clutch_pid.max = 0
clutch_pid.clamp_integral = true
clutch_pid.kP = property.getNumber("Clutch PID (P)")
clutch_pid.kI = property.getNumber("Clutch PID (I)")
clutch_pid.kD = property.getNumber("Clutch PID (D)")

engine_rps = Variable:Create()
target_rate = Variable:Create()

function onTick()
	local enabled = input.getBool(1)
	engine_rps:set(input.getNumber(1))
	target_rate:set(input.getNumber(2))

	if not enabled or target_rate.current == 0 then
		output.setNumber(1, 0)
	else
		output.setNumber(1, -clutch_pid:process(clutch_rps, engine_rps.current))
	end
end
