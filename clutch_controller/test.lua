dofile "util/pid.lua"
dofile "util/clamp.lua"
dofile "util/io_mock.lua"

property.setNumber("Clutch RPS", 3)
property.setNumber("Clutch Engage Ratio", 0.77)
property.setNumber("Clutch Slip", 0.6)
dofile "clutch_controller/script.lua"

input.setBool(Channel.In.Bool.Enabled, true)
input.setNumber(Channel.In.Num.TargetRate, 1)
for i = 1, 16 do
    onTick()
    print(output.getNumber(Channel.Out.Num.Clutch))
    input.setNumber(Channel.In.Num.OutputRPS, i)
end