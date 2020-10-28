-- Variable

engine_rps = Variable:Create()
ignition_rps = property.getNumber("Ignition RPS")

function onTick()
	local enabled = input.getBool(1)
	local thermal_protect = input.getBool(16)
	engine_rps:set(input.getNumber(1))

	if not thermal_protect and enabled and engine_rps.current < ignition_rps then
		output.setBool(1, true)
	else
		output.setBool(1, false)
	end
end
