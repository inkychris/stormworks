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
        _assert_num(chan)
        return table.bool[chan]
    end
    function table.setBool(chan, val)
        _assert_num(chan)
        table.bool[chan] = val
    end
    function table.getNumber(chan)
        _assert_num(chan)
        return table.number[chan]
    end
    function table.setNumber(chan, val)
        _assert_num(chan)
        assert(tonumber(val), "value is not a number!")
        table.number[chan] = val
    end
    function table.printBool() __print_table(label, table.bool) end
    function table.printNumber() __print_table(label, table.number) end
end

__init_io_mock("input", input)
__init_io_mock("output", output)
__init_io_mock("property", property)


Mode = {
    Disabled = 0,
    Ballast = {Fill = 1, Drain = 2},
    Chem = {Fill = 3, Drain = 4},
}

Bool = {
    RequestMode = {
        Ballast = {Fill = 1, Drain = 2},
        Chem = {Fill = 3, Drain = 4},
    },
    CurrentMode = {
        Ballast = {Fill = 5, Drain = 6},
        Chem = {Fill = 7, Drain = 8},
    },
    Pump = {
        Ballast = {Fill = 9, Drain = 10},
    },
}
Num = {
    Valve = {
        Ballast = 1,
        Chem = {Fill = 2, Drain = 3},
    },
    ValveRGB = {
        Chem = {
            Fill = {On = 4, Off = 5},
            Drain = {On = 6, Off = 7}},
    },
    Tank = {Level = 8, Capacity = 9}
}

function setTrue(...)
    for _,chan in ipairs{...} do
        output.setBool(chan, true)
    end
end

function setNum(val, ...)
    for _,chan in ipairs{...} do
        output.setNumber(chan, val)
    end
end

function ballast_fill()
    setTrue(Bool.Pump.Ballast.Fill, Bool.CurrentMode.Ballast.Fill)
    setNum(1, Num.Valve.Ballast)
    setNum(0.75, Num.ValveRGB.Chem.Fill.Off, Num.ValveRGB.Chem.Drain.Off)
end

function ballast_drain()
    setTrue(Bool.Pump.Ballast.Drain, Bool.CurrentMode.Ballast.Drain)
    setNum(1, Num.Valve.Ballast)
    setNum(0.75, Num.ValveRGB.Chem.Fill.Off, Num.ValveRGB.Chem.Drain.Off)
end

function chem_fill()
    setTrue(Bool.CurrentMode.Chem.Fill)
    setNum(1, Num.Valve.Chem.Fill)
    setNum(0.75, Num.ValveRGB.Chem.Fill.On, Num.ValveRGB.Chem.Drain.Off)
end

function chem_drain()
    setTrue(Bool.CurrentMode.Chem.Drain)
    setNum(1, Num.Valve.Chem.Drain)
    setNum(0.75, Num.ValveRGB.Chem.Drain.On, Num.ValveRGB.Chem.Fill.Off)
end

function disabled()
    setNum(0.75, Num.ValveRGB.Chem.Fill.Off, Num.ValveRGB.Chem.Drain.Off)
end

ModeFuncMap = {
    [Mode.Disabled] = disabled,
    [Mode.Ballast.Fill] = ballast_fill,
    [Mode.Ballast.Drain] = ballast_drain,
    [Mode.Chem.Fill] = chem_fill,
    [Mode.Chem.Drain] = chem_drain,
}

ChannelModeMap = {
    [Bool.RequestMode.Ballast.Fill] = Mode.Ballast.Fill,
    [Bool.RequestMode.Ballast.Drain] = Mode.Ballast.Drain,
    [Bool.RequestMode.Chem.Fill] = Mode.Chem.Fill,
    [Bool.RequestMode.Chem.Drain] = Mode.Chem.Drain,
}

current_mode = Mode.Disabled
request_previous = {
    [Bool.RequestMode.Ballast.Fill] = false,
    [Bool.RequestMode.Ballast.Drain] = false,
    [Bool.RequestMode.Chem.Fill] = false,
    [Bool.RequestMode.Chem.Drain] = false
}
function onTick()
    for i = 1,32 do
        output.setBool(i, false)
        output.setNumber(i, 0)
    end

    for channel = Bool.RequestMode.Ballast.Fill, Bool.RequestMode.Chem.Drain do
        local channel_value = input.getBool(channel)
        if channel_value and not request_previous[channel] then
            local new_mode = ChannelModeMap[channel]
            if current_mode == new_mode then
                current_mode = Mode.Disabled
            else
                current_mode = new_mode
            end
        end
        request_previous[channel] = channel_value
    end

    ModeFuncMap[current_mode]()
end

function tick()
    for i=1,2 do
        onTick()
        output.printBool()
        -- output.printNumber()
    end
end


tick()

input.setBool(Bool.RequestMode.Ballast.Fill, true)
tick()
input.setBool(Bool.RequestMode.Ballast.Drain, true)
tick()
input.setBool(Bool.RequestMode.Chem.Fill, true)
tick()
input.setBool(Bool.RequestMode.Chem.Drain, true)
tick()
input.setBool(Bool.RequestMode.Chem.Drain, false)
tick()
input.setBool(Bool.RequestMode.Chem.Drain, true)
tick()