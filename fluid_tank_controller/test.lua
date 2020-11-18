dofile "util/io_mock.lua"
dofile "fluid_tank_controller/script.lua"

function tick()
    for i=1,2 do
        onTick()
        output.printBool()
    end
end

tick()
input.setBool(fuel_tank.Channel.Bool.RequestMode.Fill, true)
tick()
input.setBool(fuel_tank.Channel.Bool.RequestMode.Fill, true)
tick()