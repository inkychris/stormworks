-- PID

clutch_rps = property.getNumber("Clutch RPS")

clutch_pid = PID:Create{
	kP = property.getNumber("Clutch PID (P)"),
	kI = property.getNumber("Clutch PID (I)"),
	kD = property.getNumber("Clutch PID (D)")
}

function onTick()
	for i=1,32 do output.setNumber(i,input.getNumber(i)); output.setBool(i,input.getBool(i)) end

	local enabled = input.getBool(1)
	local engine_rps = input.getNumber(1)
	local target_rate = input.getNumber(2)

	if (not enabled) or (target_rate == 0) then
		output.setNumber(4, 0)
	else
		output.setNumber(4, clutch_pid:process(engine_rps, clutch_rps))
	end
end
