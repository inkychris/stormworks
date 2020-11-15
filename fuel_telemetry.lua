-- clamp
-- FIFO

output_rate = property.getNumber("Update Rate (ticks)") or 12
max_usage = property.getNumber("Max Fuel Usage") or 10
max_range = property.getNumber("Max Range (km)") or 250

fifo = {
    fuel_level = FIFO:Create(60),
    fuel_usage = FIFO:Create(60),
    speed = FIFO:Create(60),
}

previous_fuel_level = 0
function onTick()
    fifo.fuel_level:push(input.getNumber(1))
    local fuel_level = fifo.fuel_level:average()
    fifo.fuel_usage:push(previous_fuel_level - fuel_level)

    local fuel_usage = clamp(fifo.fuel_usage:average() * 60, 0, max_usage)
    if fuel_usage < 0 then fuel_usage = 0 end

    fifo.speed:push(input.getNumber(2))
    local predicted_range = fifo.speed:average() / (fuel_usage + 0.01) * fuel_level / 1000
    predicted_range = clamp(predicted_range, 0, max_range)
   
    output.setNumber(1, fuel_level)
    output.setNumber(2, fuel_usage)
    output.setNumber(3, predicted_range)
    
    previous_fuel_level = fuel_level
end
