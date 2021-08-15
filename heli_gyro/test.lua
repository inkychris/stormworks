dofile("util/io_mock.lua")

property.setNumber("Collective PID (P)", 0.1)
property.setNumber("Collective PID (I)", 0.05)
property.setNumber("Roll PID (P)", 0.1)
property.setNumber("Roll PID (I)", 0.05)
property.setNumber("Pitch PID (P)", 0.1)
property.setNumber("Pitch PID (I)", 0.05)

dofile "heli_gyro/script.lua"

local vector = rotate_vector({x=1, y=2, z=0}, -math.pi)
print(string.format("[ %1.3f %1.3f %1.3f ]", vector.x, vector.y, vector.z))

onTick()