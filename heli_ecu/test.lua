dofile("util/io_mock.lua")

property.setNumber("Throttle PID (P)", 0.1)
property.setNumber("Throttle PID (I)", 0.05)
property.setNumber("Target Engine RPS", 7.5)
property.setNumber("Min Engine RPS", 2.8)
property.setNumber("Spool Rate (ticks)", 5)
property.setNumber("Ignition RPS", 0.9)

dofile "heli_ecu/script.lua"

input.setBool(Channel.In.Bool.Enabled, true)

for i=0,10,0.25 do
    input.setNumber(Channel.In.Num.EngineRPS, i)
    onTick()
    print(i, "starter: ", output.getBool(Channel.Out.Bool.Starter), "throttle:", output.getNumber(Channel.Out.Num.Throttle))
end
