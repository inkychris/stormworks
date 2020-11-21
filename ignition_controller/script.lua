ignition_rps = property.getNumber("Ignition RPS")

channel = {
	engine_rps = 1,
	enabled = 1,
	starter = 2,
	thermal_protect = 3,
}

function onTick()
	for i=1,32 do output.setNumber(i,input.getNumber(i)); output.setBool(i,input.getBool(i)) end

	local enabled = input.getBool(channel.enabled)
	local thermal_protect = input.getBool(channel.thermal_protect)
	local engine_rps = input.getNumber(channel.engine_rps)

	if not thermal_protect and enabled and engine_rps < ignition_rps then
		output.setBool(channel.starter, true)
	else
		output.setBool(channel.starter, false)
	end
end
