-- Variable

engine_rps = Variable:Create()
ignition_rps = property.getNumber("Ignition RPS")

engine_rps_channel = property.getNumber("Engine RPS Channel (Number)")
therm_protect_channel = property.getNumber("Thermal Protect Enabled Channel (Bool)")
enabled_channel = property.getNumber("Enabled Channel (Bool)")
starter_channel = property.getNumber("Starter Channel (Bool)")

function onTick()
	local enabled = input.getBool(enabled_channel)
	local thermal_protect = input.getBool(therm_protect_channel)
	engine_rps:set(input.getNumber(engine_rps_channel))

	if not thermal_protect and enabled and engine_rps.current < ignition_rps then
		output.setBool(starter_channel, true)
	else
		output.setBool(starter_channel, false)
	end
end
