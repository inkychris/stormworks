dofile "util/pid.lua"

Channel = {
	In = {
		Bool = {active = 1},
		Num = {
			roll = 1,
			pitch = 2,
			yaw = 3,
			collective = 4,
			altitude = 18,
			yaw_rate = 20,
			roll_tilt = 21,
			pitch_tilt = 22
		},
	},
	Out = {
		Num = {
			roll = 1,
			pitch = 2,
			yaw = 3,
			collective = 4,
		},
	}
}

pgN = property.getNumber

function new_pid(name)
	local sf=string.format
	return PID:Create{
		kP = pgN(sf("%s PID (P)",name)),
		kI = pgN(sf("%s PID (I)",name)),
		kD = pgN(sf("%s PID (D)",name)),
		min = -1
	}
end

pid = {
	roll = new_pid("Roll"),
	pitch = new_pid("Pitch"),
	yaw = new_pid("Yaw"),
	collective = new_pid("Collective"),
}
pid.collective.min = pgN("Min Collective")

limit = {
	roll = pgN("Max Roll")/360,
	pitch = pgN("Max Pitch")/360,
	yaw = pgN("Yaw Rate"),
	ascent = pgN("Ascent Rate")
}

target = {}
previous = {}
for k,_ in pairs(Channel.In.Num) do
	target[k] = 0
	previous[k] = 0
end

igN = input.getNumber
function onTick()
	local current = {}
	for k,_ in pairs(Channel.In.Num) do
		current[k] = input.getNumber(Channel.In.Num[k])
	end

	if input.getBool(Channel.In.Bool.active) then
		output.setNumber(Channel.Out.Num.roll, -pid.roll:process(-current.roll*limit.roll, current.roll_tilt))
		output.setNumber(Channel.Out.Num.pitch, -pid.pitch:process(-current.pitch*limit.pitch, current.pitch_tilt))
		output.setNumber(Channel.Out.Num.yaw, pid.yaw:process(current.yaw*limit.yaw, current.yaw_rate))
		output.setNumber(Channel.Out.Num.collective, pid.collective:process(current.collective*limit.ascent, (current.altitude - previous.altitude)*60))
	else
		for _,v in pairs(pid) do v:reset() end
	end
	previous.altitude = current.altitude
end
