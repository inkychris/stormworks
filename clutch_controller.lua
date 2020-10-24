-- clutch

min_rps = property.getNumber("Min Engine RPS")
clutch_increment = property.getNumber("Clutch Increment")

clutch = Clutch:Create(min_rps, clutch_increment)
engine_rps = Variable:Create()
target_rate = Variable:Create()

function onTick()
	local enabled = input.getBool(1)
	engine_rps:set(input.getNumber(1))
	target_rate:set(input.getNumber(2))

	if not enabled then
		clutch.value = 0
		return
	end

	if enabled and (engine_rps.current < min_rps) then
		clutch.value = 0
	end

	clutch:process(engine_rps, target_rate)
	output.setNumber(1, clutch.value)
end
