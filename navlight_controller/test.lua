dofile("util/io_mock.lua")

property.setNumber("Sunset", 0.75)
property.setNumber("Sunrise", 0.25)
property.setNumber("Transition Time", 0.08)
property.setNumber("Enable Behaviour", 2)
property.setNumber("Min Weather", 0.1)

dofile "navlight_controller/script.lua"

input.setNumber(Channel.In.Num.Rain, 0.21)
input.setNumber(Channel.In.Num.Fog, 0.15)
for i =0,99 do
    if i == 50 then 
        input.setNumber(Channel.In.Num.Fog, 0.3)
    end
    if i % 10 == 0 then io.write("\n") end
    input.setNumber(Channel.In.Num.Time, i / 100)
    onTick()
    io.write(string.format("%1.2f  ", output.getNumber(Channel.Out.Num.Port)))
end
