function clamp(val,min,max)
	if val>max then val=max
	elseif val<min then val=min end
	return val
end

function __scale_cos(val,xcross,other)
	return xcross+(other-xcross)*((1-math.cos(math.pi*val))/2)
end

function smooth_clamp(val,min,max)
	val = clamp(val,min,max)
	if val>0 and val<max then val=__scale_cos(val,0,max)
	elseif val<0 and val>min then val=__scale_cos(val,0,min) end
	return val
end

PID={}function PID:Create(a)local b={kP=a.kP or 1,kI=a.kI or 0,kD=a.kD or 0,min=a.min or 0,max=a.max or 1,_preverr=0,_integral=0}function b:reset()self._preverr=0;self._integral=0 end;function b:process(c,d)local e=c-d;local f=self.kP*e;self._integral=self._integral+e/60;local g=self.kI*self._integral;local h=self.kD*(e-self._preverr)*60;local i=f+g+h;if i>self.max then self._integral=self._integral-e/60;i=self.max elseif i<self.min then self._integral=self._integral-e/60;i=self.min end;self._preverr=e;return i end;return b end
function Heading()local a={_r=0,_h={cur=0,prev=0}}function a:update(b,c)if b<0 and a._h.prev>0 and c<0 then a._r=a._r+1 elseif b>0 and a._h.prev<0 and c>0 then a._r=a._r-1 end;a._h.cur=b;a._h.prev=b end;function a:rads()return math.pi+(a._r+a._h.cur-0.5)*2*math.pi end;return a end

function rotate_vector(vector, angle)
	local cos_heading = math.cos(-angle)
	local sin_heading = math.sin(-angle)
	return {
		x=(vector.x * cos_heading) - (vector.y * sin_heading),
		y=(vector.x * sin_heading) + (vector.y * cos_heading),
		z=vector.z
	}
end

Channel = {
	In = {
		Num = {
			roll = 1,
			pitch = 2,
			yaw = 3,
			collective = 4,
			x = 16,
			y = 17,
			altitude = 18,
			heading = 19,
			yaw_angular_speed = 20,
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

pid = {
	pitch = PID:Create{
		kP = pgN("Pitch PID (P)"),
		kI = pgN("Pitch PID (I)"),
		kD = pgN("Pitch PID (D)"),
		min = -1
	},
	roll = PID:Create{
		kP = pgN("Roll PID (P)"),
		kI = pgN("Roll PID (I)"),
		kD = pgN("Roll PID (D)"),
		min = -1
	},
	yaw = PID:Create{
		kP = pgN("Yaw PID (P)"),
		kI = pgN("Yaw PID (I)"),
		kD = pgN("Yaw PID (D)"),
		min = -1
	},
	collective = PID:Create{
		kP = pgN("Collective PID (P)"),
		kI = pgN("Collective PID (I)"),
		kD = pgN("Collective PID (D)"),
		min = -1
	},
}
max_tilt = {
	roll = pgN("Max Roll"),
	pitch = pgN("Max Pitch")
}

decel_distance = {
	roll = 10,
	pitch = 20,
}

heading = Heading()

target = {}
for k,_ in pairs(Channel.In.Num) do
	target[k] = 0
end

tick_index = 0
function onTick()
	local current = {}
	for k,_ in pairs(Channel.In.Num) do
		current[k] = input.getNumber(Channel.In.Num[k])
	end

	heading:update(current.heading, current.yaw_angular_speed)

	if tick_index < 10 then
		target.x = current.x
		target.y = current.y
		target.altitude = current.altitude
		target.heading = heading:rads()
	end

	local abs_displacement = {
		x=current.x - target.x,
		y=current.y - target.y,
		z=current.altitude - target.altitude,
	}
	local rel_displacement = rotate_vector(abs_displacement, -current.heading)

	target.roll_tilt = smooth_clamp(rel_displacement.x / decel_distance.roll, -max_tilt.roll, max_tilt.roll)
	target.pitch_tilt = 0

	output.setNumber(Channel.Out.Num.roll, -pid.roll:process(target.roll_tilt, current.roll_tilt))
	output.setNumber(Channel.Out.Num.pitch, pid.pitch:process(target.pitch_tilt, current.pitch_tilt))
	output.setNumber(Channel.Out.Num.yaw, pid.yaw:process(target.heading, heading:rads()))
	output.setNumber(Channel.Out.Num.collective, pid.collective:process(0, rel_displacement.z))

	tick_index = tick_index + 1
end
