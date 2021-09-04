dofile "util/pid.lua"
dofile "util/input_smoothing/src.lua"

Channel = {
	In = {
		Bool = {active = 1},
		Num = {
			Roll = 1,
			Pitch = 2,
			Yaw = 3,
			Collective = 4,
			altitude = 18,
			yaw_rate = 20,
			roll_tilt = 21,
			pitch_tilt = 22
		},
	},
	Out = {
		Num = {
			Roll = 1,
			Pitch = 2,
			Yaw = 3,
			Collective = 4,
		},
	}
}

pgN = property.getNumber
pgN = property.getNumber
igN = input.getNumber
igB = input.getBool
osN = output.setNumber
osB = output.setBool

function new_pid(name)
	return PID{
		kP = pgN(name.." PID (P)"),
		kI = pgN(name.." PID (I)"),
		kD = pgN(name.." PID (D)"),
		min = -1
	}
end

function Axis(label,limit,invert_in,invert_out)
	polarity=polarity or 1
	local t={
		_in=Smooth(pgN(label.." Sensitivity")),
		_ctl_pid=new_pid(label),
	}
	function t:reset() self._ctl_pid:reset() end
	function t:write(pv)
		local r=self._in:smooth(igN(Channel.In.Num[label]))
		if invert_in then r=r*-1 end
		local out = self._ctl_pid:process(r*limit, pv)
		if invert_out then out=out*-1 end
		osN(Channel.Out.Num[label],out)
	end
	return t
end

axes={
	r=Axis("Roll",pgN("Max Roll")/360,true,true),
	p=Axis("Pitch",pgN("Max Pitch")/360,true,true),
	y=Axis("Yaw",pgN("Yaw Rate")),
	c=Axis("Collective",pgN("Ascent Rate"))
}

axes.c._ctl_pid.min = pgN("Min Collective")

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
		axes.r:write(current.roll_tilt)
		axes.p:write(current.pitch_tilt)
		axes.y:write(current.yaw_rate)
		axes.c:write((current.altitude - previous.altitude)*60)
	else
		for _,axis in pairs(axes) do axis:reset() end
	end
	previous.altitude = current.altitude
end
