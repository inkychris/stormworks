dofile "util/io_mock.lua"

property.setNumber("Input Threshold", 0.01)

property.setNumber("Pivot Increment", 0.01)
property.setNumber("Primary Hinge Increment", 0.01)
property.setNumber("Secondary Hinge Increment",0.01)

property.setNumber("Pivot Min", -0.5)
property.setNumber("Pivot Max", 0.5)

property.setNumber("Primary Hinge Min", 0)
property.setNumber("Primary Hinge Max", 0.5)

property.setNumber("Secondary Hinge Min", 0)
property.setNumber("Secondary Hinge Max", 0.5)

dofile "crane_controller/script.lua"

value = 0
for i = 0,60 do
    value = value + 0.01
    if i > 20 then
        value = value - 0.02
    end
    input.setNumber(1, value)
    onTick()
    print(i, output.getNumber(1))
end
