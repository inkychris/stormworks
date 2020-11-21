dofile("util/io_mock.lua")

property.setNumber("Sunset", 0.75)
property.setNumber("Sunrise", 0.25)
property.setNumber("Transition Time", 0.08)
property.setNumber("Enable Behaviour", 2)
property.setNumber("Min Rain", 0.1)

property.setNumber("RGB R", 169)
property.setNumber("RGB G", 67)
property.setNumber("RGB B", 35)

dofile "lighting_controller/script.lua"

input.setBool(Channel.In.Bool.Enabled, true)
input.setNumber(Channel.In.Num.Rain, 0.21)
for i =0,99 do
    if i > 50 then input.setBool(Channel.In.Bool.Enabled, false) end
    if i % 10 == 0 then io.write("\n") end
    input.setNumber(Channel.In.Num.Time, i / 100)
    onTick()
    io.write(string.format("%1.2f  ", output.getNumber(Channel.Out.Num.Intensity)))
end
