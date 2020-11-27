dofile "util/io_mock.lua"
dofile "fluid_tank_controller/script.lua"

input.setNumber(tank.Channel.Num.Tank.Level, 0)
input.setNumber(tank.Channel.Num.Tank.Capacity, 1)

input.setBool(tank.Channel.Bool.RequestMode.Fill, true)

for i = 1, 120 do
    input.setNumber(tank.Channel.Num.Tank.Level, i/100)
    onTick()
    print(
        "Level:", output.getNumber(tank.Channel.Num.Tank.Level),
        "Capacity:", output.getNumber(tank.Channel.Num.Tank.Capacity),
        "Rate:", output.getNumber(tank.Channel.Num.Tank.Rate))
end
