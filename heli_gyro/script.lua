dofile"util/pid.lua"
dofile "util/input_smoothing/src.lua"
dofile "util/continuous_heading_sensor/src.lua"
dofile "util/rotate_vector.lua"

Channel = {
	In = {
		Bool = {active = 1},
		Num = {
			Roll = 1,
			Pitch = 2,
			Yaw = 3,
			Collective = 4,
			x = 16,
			y = 17,
			altitude = 18,
			heading = 19,
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
igN = input.getNumber
igB = input.getBool
osN = output.setNumber
osB = output.setBool

function new_pid(name)
	return PID{
		kP = pgN(name.." PID (P)")or 0,
		kI = pgN(name.." PID (I)")or 0,
		kD = pgN(name.." PID (D)")or 0,
		offset = pgN(name.." Offset") or 0,
		min = -1
	}
end

function Axis(label,limit,invert_in,invert_out)
	local t={
		_in=Smooth(pgN(label.." Sensitivity")),
		_pid=new_pid(label),
	}
	function t:reset() self._pid:reset() end
	function t:write(pv,modifier)
		local r=self._in:smooth(igN(Channel.In.Num[label]))
		if invert_in then r=r*-1 end
		if modifier and modifier.active then r=r+modifier.val end
		local out = self._pid:process(r*limit, pv)
		if invert_out then out=out*-1 end
		osN(Channel.Out.Num[label],out)
	end
	return t
end

pos_hold_speed=pgN("Pos Hold Speed")
max_r=pgN("Max Roll")/360
max_p=pgN("Max Pitch")/360
axes={
	r=Axis("Roll",max_r,true,true),
	p=Axis("Pitch",max_p,true,true),
	y=Axis("Yaw",pgN("Yaw Rate")),
	c=Axis("Collective",pgN("Ascent Rate"))
}

axes.c._pid.min = pgN("Min Collective")

null_pid={
	x=new_pid("X Hold"),
	y=new_pid("Y Hold")
}

mem_ids={"altitude","x","y"}
previous={}
heading = Heading()

function onTick()
	local current = {}
	for k,_ in pairs(Channel.In.Num) do
		current[k] = input.getNumber(Channel.In.Num[k])
	end

	function store_prev()
		for _,id in ipairs({"altitude","x","y"}) do previous[id]=current[id] end
	end

	heading:update(current.heading)
	current.heading_rads = heading:rads()

	if igB(Channel.In.Bool.active) then
		if previous.x==nil then store_prev() end
		local velocity=rotate_vector({x=previous.x-current.x,y=previous.y-current.y},-current.heading_rads)
		local below_hold_speed=math.sqrt(velocity.x^2+velocity.y^2)*60<pos_hold_speed
		function null_velocity(in_label,axis)
			local t={
				active=math.abs(igN(Channel.In.Num[in_label]))<0.9 and below_hold_speed}
			if t.active then t.val=null_pid[axis]:process(0,velocity[axis])
			else null_pid[axis]:reset() end
			return t
		end

		axes.r:write(current.roll_tilt, null_velocity("Roll","x"))
		axes.p:write(current.pitch_tilt, null_velocity("Pitch","y"))
		axes.y:write(current.yaw_rate)
		axes.c:write((current.altitude-previous.altitude)*60)
	else
		for _,axis in pairs(axes) do axis:reset() end
	end
	store_prev()
end
