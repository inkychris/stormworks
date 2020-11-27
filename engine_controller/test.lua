dofile("util/io_mock.lua")

property.setNumber("Throttle PID (P)", 0.1)
property.setNumber("Throttle PID (I)", 0.05)
property.setNumber("Min Engine RPS", 2.8)
property.setNumber("Max Engine RPS", 20)
property.setNumber("Ignition RPS", 0.9)
property.setNumber("Max Reverse Engine RPS", 6)
property.setNumber("Max Engine Temp", 100)

dofile "engine_controller/script.lua"

onTick()
print(output.getNumber(Channel.Out.Num.Throttle))

onTick()
print(output.getNumber(Channel.Out.Num.Throttle))
