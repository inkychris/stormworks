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
        prev_mode_req = nil,
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
        local mode_req = nil
        if input.getBool(self.Channel.Bool.RequestMode.Fill) then mode_req = Mode.Fill
        elseif input.getBool(self.Channel.Bool.RequestMode.Drain) then mode_req = Mode.Drain end
        
        if mode_req and mode_req ~= self.prev_mode_req then
            if mode_req == self.mode then
                self.mode = Mode.Disabled
            else
                self.mode = mode_req
            end
        end

        if self.mode == Mode.Fill then
            self:fill()
            if input.getNumber(self.Channel.Num.Tank.Level) >= input.getNumber(self.Channel.Num.Tank.Capacity) then
                self.mode = Mode.Disabled
            end
        elseif self.mode == Mode.Drain then
            self:drain()
            if input.getNumber(self.Channel.Num.Tank.Level) == 0 then
                self.mode = Mode.Disabled
            end
        end

        self.prev_mode_req = mode_req
    end
    return this
end

tank = Tank:Create(1)

function onTick()
    for i = 1,32 do
        output.setBool(i, false)
        output.setNumber(i, 0)
    end

    tank:process()
end
