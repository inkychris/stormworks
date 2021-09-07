dofile("util/io_mock.lua")

property.setNumber("Roll PID (P)", 0.1)
property.setNumber("Roll PID (I)", 0.05)
property.setNumber("Roll Sensitivity", 10)

property.setNumber("Pitch PID (P)", 0.1)
property.setNumber("Pitch PID (I)", 0.05)
property.setNumber("Pitch Sensitivity", 10)

property.setNumber("Yaw PID (P)", 0.1)
property.setNumber("Yaw PID (I)", 0.05)
property.setNumber("Yaw Sensitivity", 10)

property.setNumber("Collective PID (P)", 0.1)
property.setNumber("Collective PID (I)", 0.05)
property.setNumber("Collective Sensitivity", 10)

property.setNumber("Max Roll", 20)
property.setNumber("Max Pitch", 20)
property.setNumber("Yaw Rate", 0.15)
property.setNumber("Min Collective", 0.1)
property.setNumber("Ascent Rate", 10)
property.setNumber("Pos Hold Speed", 5)

property.setNumber("Roll Offset", 0.01)
property.setNumber("Pitch Offset", 0.01)
property.setNumber("Yaw Offset", 0.01)

dofile "heli_gyro/script.lua"

for i=1,4 do
	onTick()
	output.printNumber(1,4)
end

input.setBool(Channel.In.Bool.active, true)

for i=1,4 do
	onTick()
	output.printNumber(1,4)
end
