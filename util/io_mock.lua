input = {}
output = {}
property = {}

function __print_table(label, table)
    io.write(label..": ")
    for i=1,32 do
        if table[i] == false then io.write("-")
        elseif table[i] == true then io.write("+")
        else io.write(string.format("%1.3f", table[i])) end
        if i % 4 == 0 then io.write("   ") else io.write(" ") end
    end
    io.write("\n")
end

function __init_io_mock(label, table)
    table.bool = {}
    table.number = {}
    for i=1,32 do
        table.bool[i] = false
        table.number[i] = 0
    end
    function _assert_num(val) assert(tonumber(val), "value is not a number!") end
    function table.getBool(chan)
        return table.bool[chan]
    end
    function table.setBool(chan, val)
        table.bool[chan] = val
    end
    function table.getNumber(chan)
        return table.number[chan]
    end
    function table.setNumber(chan, val)
        assert(tonumber(val), "value is not a number!")
        table.number[chan] = val
    end
    function table.printBool() __print_table(label, table.bool) end
    function table.printNumber() __print_table(label, table.number) end
end

__init_io_mock("input", input)
__init_io_mock("output", output)
__init_io_mock("property", property)
