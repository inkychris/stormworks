Mode = {
    Disabled = 0,
    Fill = 1,
    Drain = 2,
}

Tank = {}
function Tank:Create(start_channel)
    local sc = start_channel
    local this = {
        mode = Mode.Disabled,
        prev_mode_req = Mode.Disabled,
        Channel = {
            Bool = {
                RequestMode = {Fill = sc, Drain = sc + 1},
                CurrentMode = {Fill = sc + 2, Drain = sc + 3},
                Pump = {Fill = sc + 4, Drain = sc + 5}
            },
            Num = {
                Valve = sc,
                Tank = {Level = sc + 1, Capacity = sc + 2}
            }
        }
    }
    function this:fill()
        output.setNumber(self.Channel.Num.Valve, 1)
        output.setBool(self.Channel.Bool.Pump.Fill, true)
        output.setBool(self.Channel.Bool.CurrentMode.Fill, true)
    end
    function this:drain()
        output.setNumber(self.Channel.Num.Valve, 1)
        output.setBool(self.Channel.Bool.Pump.Drain, true)
        output.setBool(self.Channel.Bool.CurrentMode.Drain, true)
    end
    function this:process()
        local new_mode = Mode.Disabled
        if input.getBool(self.Channel.Bool.RequestMode.Fill) then new_mode = Mode.Fill
        elseif input.getBool(self.Channel.Bool.RequestMode.Drain) then new_mode = Mode.Drain end
        
        if new_mode == self.prev_mode_req then return end
        
        if new_mode == self.mode then self:disable()
        elseif new_mode == Mode.Fill then self:fill()
        elseif new_mode == Mode.Drain then self:drain() end

        self.prev_mode_req = self.mode
    end
    return this
end

fuel_tank = Tank:Create(1)
chemical_tank = Tank:Create(16)

function onTick()
    for i = 1,32 do
        output.setBool(i, false)
        output.setNumber(i, 0)
    end

    fuel_tank:process()
    chemical_tank:process()
end
