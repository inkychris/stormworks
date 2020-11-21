dofile "util/io_mock.lua"
dofile "fluid_tank_controller/script.lua"

function tick()
    for i=1,2 do
        onTick()
        output.printBool()
    end
end

tick()
input.setBool(tank.Channel.Bool.RequestMode.Fill, true)
tick()
input.setBool(tank.Channel.Bool.RequestMode.Fill, false)
tick()
input.setBool(tank.Channel.Bool.RequestMode.Drain, true)
tick()
input.setBool(tank.Channel.Bool.RequestMode.Drain, false)
tick()
