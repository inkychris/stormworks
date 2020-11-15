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

function __assert_num(val) assert(tonumber(val), "value is not a number!") end
function __assert_str(val) assert(tostring(val), "value is not a string!") end

function __init_io_mock(label, table, key_assert)
    table.bool = {}
    table.number = {}
    for i=1,32 do
        table.bool[i] = false
        table.number[i] = 0
    end
    function table.getBool(key)
        key_assert(key)
        return table.bool[key]
    end
    function table.setBool(key, val)
        key_assert(key)
        table.bool[key] = val
    end
    function table.getNumber(key)
        key_assert(key)
        return table.number[key]
    end
    function table.setNumber(key, val)
        key_assert(key)
        __assert_num(val)
        table.number[key] = val
    end
    function table.printBool() __print_table(label, table.bool) end
    function table.printNumber() __print_table(label, table.number) end
end

__init_io_mock("input", input, __assert_num)
__init_io_mock("output", output, __assert_num)
__init_io_mock("property", property, __assert_str)
