dofile "util/io_mock.lua"
dofile "aircraft_lights/script.lua"

input.setBool(1, true)
input.setBool(2, true)
input.setBool(3, true)

for i=1,120 do
    onTick()
    local result = string.format("%3d:", i)
    for k,v in pairs(output_channels) do
        result = result .. string.format(
            " %s [%d %d %d]", k,
            output.getNumber(v),
            output.getNumber(v+1),
            output.getNumber(v+2))
    end
    print(result)
end
