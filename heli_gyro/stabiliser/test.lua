dofile("util/io_mock.lua")

property.setNumber("Roll PID (P)", 0.1)
property.setNumber("Roll PID (I)", 0.05)
property.setNumber("Pitch PID (P)", 0.1)
property.setNumber("Pitch PID (I)", 0.05)
property.setNumber("Roll PID (I)", 0.05)
property.setNumber("Yaw PID (P)", 0.1)
property.setNumber("Yaw PID (I)", 0.05)
property.setNumber("Collective PID (P)", 0.1)
property.setNumber("Collective PID (I)", 0.05)

property.setNumber("Max Roll", 0.1)
property.setNumber("Max Pitch", 0.1)
property.setNumber("Yaw Rate", 0.25)
property.setNumber("Min Collective", 0.1)
property.setNumber("Ascent Rate", 0.1)

dofile "heli_gyro/stabiliser/script.lua"

for i=1,4 do
	onTick()
	output.printNumber(1,4)
end

input.setBool(Channel.In.Bool.active, true)

for i=1,4 do
	onTick()
	output.printNumber(1,4)
end
