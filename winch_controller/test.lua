dofile "util/clamp.lua"
dofile "util/io_mock.lua"

property.setNumber("Min Length", 0)
property.setNumber("Max Length", 20)

dofile "winch_controller/script.lua"

function Winch(t)
    local this = {
        rate = t.rate or 1,
        length = 0,
        min = t.min or 0,
        max = t.max or 0
    }
    function this:up()
        this.length = clamp(this.length - this.rate, this.min, this.max)
    end
    function this:down()
        this.length = clamp(this.length + this.rate, this.min, this.max)
    end
    return this
end

winch = Winch{max=20}

function tick(up, down, retract, extend)
    input.setBool(Channel.In.Bool.Up, up or false)
    input.setBool(Channel.In.Bool.Down, down or false)
    input.setBool(Channel.In.Bool.Retract, retract or false)
    input.setBool(Channel.In.Bool.Extend, extend or false)
    onTick()
    if output.getBool(Channel.Out.Bool.WinchUp) then winch:up() end
    if output.getBool(Channel.Out.Bool.WinchDown) then winch:down() end
    input.setNumber(Channel.In.Num.Length, winch.length)
    print(winch.length)
end

print("!!!")
tick(false, false, false, false)
for i=1,4 do tick() end
print("!!!")
for i=1,4 do tick(false, true, false, false) end
print("!!!")
tick(false, false, false, true)
for i=1,5 do tick() end
print("!!!")
tick(true, false, false, false)
for i=1,5 do tick() end
print("!!!")
tick(false, false, true, false)
for i=1,10 do tick() end
print("!!!")